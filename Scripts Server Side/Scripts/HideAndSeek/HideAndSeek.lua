local HideAndSeek = {}

-- ==========================================================
-- CONFIG (SEPARADO)
-- ==========================================================
local CONFIG = require("Scripts\\HideAndSeek\\Config")
HideAndSeek.Config = HideAndSeek.Config or CONFIG

-- ==========================================================
-- STATE
-- ==========================================================
HideAndSeek.State = HideAndSeek.State or {
	phase = "idle", -- idle | prestart | running
	prestartRemaining = 0,
	eventRemaining = 0,
	npcIndex = -1,
	spawn = nil,
	hintLevel = 0,
	hintCountdown = 0,
	timers = { prestartTick = -1, runningTick = -1 },
	monthly = { lastAwardDateKey = "" },
}

-- ==========================================================
-- HELPERS
-- ==========================================================
local PREFIX = "[Esconde-Esconde]"

local function dbg(text)
	if not (HideAndSeek.Config.Log and HideAndSeek.Config.Log.Enabled) then return end
	LogColor(tonumber(HideAndSeek.Config.Log.Level) or 3, "[HideAndSeek] " .. tostring(text))
end

local function warn(text)
	LogColor(2, "[HideAndSeek] " .. tostring(text))
end

local function msgAll(text)
	NoticeGlobalSend(0, text)
	NoticeSendToAll(0, text)
end

local function msgPlayer(aIndex, text)
	NoticeSend(aIndex, 0, text)
end

local function cancelTimer(id)
	if id ~= nil and id ~= -1 then Timer.Cancel(id) end
end

local function clearTimers()
	cancelTimer(HideAndSeek.State.timers.prestartTick)
	cancelTimer(HideAndSeek.State.timers.runningTick)
	HideAndSeek.State.timers.prestartTick = -1
	HideAndSeek.State.timers.runningTick = -1
end

local function shouldAnnounce(list, value)
	if type(list) ~= "table" then return false end
	for i = 1, #list do
		if value == list[i] then return true end
	end
	return false
end

local function pad3(n)
	n = tonumber(n) or 0
	if n < 10 then return "00" .. n end
	if n < 100 then return "0" .. n end
	return tostring(n)
end

local function applyMask3(value, mask)
	local s = pad3(value)
	local out = {}
	for i = 1, 3 do
		local m = mask:sub(i, i)
		if m == "X" then
			out[i] = "X"
		elseif m == "#" then
			out[i] = s:sub(i, i)
		else
			out[i] = "X"
		end
	end
	return table.concat(out)
end

local function getPossibleMapNames()
	local points = HideAndSeek.Config.SpawnPoints
	if type(points) ~= "table" then return "" end
	local seen, names = {}, {}
	for i = 1, #points do
		local p = points[i]
		if type(p) == "table" then
			local name = p.name or ("Map " .. tostring(p.map))
			if not seen[name] then
				seen[name] = true
				names[#names + 1] = name
			end
		end
	end
	return table.concat(names, ", ")
end

local function formatStartCountdownMessage(seconds)
	seconds = tonumber(seconds) or 0
	if seconds >= 60 and seconds % 60 == 0 then
		return string.format("%s Evento Iniciará em %d minuto(s).", PREFIX, math.floor(seconds / 60))
	end
	return string.format("%s Evento Iniciará em %d segundo(s).", PREFIX, seconds)
end

local function dateKeyNow()
	return os.date("%Y-%m-%d")
end

local function isLastDayOfMonthNow()
	local t = os.time()
	local tomorrow = t + 86400
	return os.date("%m", t) ~= os.date("%m", tomorrow)
end

local function hourNow() return tonumber(os.date("%H")) end
local function minuteNow() return tonumber(os.date("%M")) end

local function normalizeKey(s)
	s = tostring(s or "")
	if HideAndSeek.Config.Staff and HideAndSeek.Config.Staff.CaseInsensitive then
		return string.lower(s)
	end
	return s
end

local function listHas(list, value)
	if type(list) ~= "table" then return false end
	value = normalizeKey(value)
	for i = 1, #list do
		if normalizeKey(list[i]) == value then return true end
	end
	return false
end

local function getAccountNameIfPossible(aIndex)
	if GetObjectAccountID then return tostring(GetObjectAccountID(aIndex)) end
	if GetObjectAccount then return tostring(GetObjectAccount(aIndex)) end
	if GetObjectAccountName then return tostring(GetObjectAccountName(aIndex)) end
	return nil
end

-- ==========================================================
-- STAFF CHECK (Louis Emulator): GM/ADM + WHITELIST
-- ==========================================================
local function isGmOrAdmin_Louis(aIndex)
	if CommandCheckGameMasterLevel then
		local ok = CommandCheckGameMasterLevel(aIndex, 1)
		if ok == 1 or ok == true then
			return true
		end
	end

	if GetObjectAuthority then
		return (tonumber(GetObjectAuthority(aIndex)) or 0) > 0
	end

	return false
end

local function HideAndSeek_IsWhitelisted(aIndex)
	local staff = HideAndSeek.Config.Staff
	if not staff or not staff.Enabled then
		return true
	end

	local name = GetObjectName and GetObjectName(aIndex) or ""
	local acc = getAccountNameIfPossible(aIndex)

	if staff.OnlyAdmin then
		return listHas(staff.AdminCharNames, name)
	end

	if listHas(staff.CharNames, name) then
		return true
	end

	if acc and listHas(staff.Accounts, acc) then
		return true
	end

	return false
end

local function HideAndSeek_IsStaff(aIndex)
	local staff = HideAndSeek.Config.Staff
	if not staff or not staff.Enabled then
		return true
	end

	if not isGmOrAdmin_Louis(aIndex) then
		return false
	end

	return HideAndSeek_IsWhitelisted(aIndex)
end

-- ==========================================================
-- SQL HELPERS
-- ==========================================================
local function sqlCloseSafe()
	if SQLClose then SQLClose() end
end

local function sqlExec(q)
	local ret = SQLQuery(q)
	sqlCloseSafe()
	if ret == 0 then
		warn("SQL ret=0: " .. tostring(q))
	end
	return ret
end

local function sqlEscape(s)
	return (tostring(s or ""):gsub("'", "''"))
end

-- ==========================================================
-- SPAWN VALIDATION
-- ==========================================================
local function isBlockedByAttr(map, x, y)
	local sf = HideAndSeek.Config.SpawnFind
	if not sf or not sf.Enabled then return false end
	local attrs = sf.BlockedAttrs
	if type(attrs) ~= "table" or #attrs == 0 then return false end
	for i = 1, #attrs do
		if MapCheckAttr(map, x, y, attrs[i]) ~= 0 then return true end
	end
	return false
end

local function isValidNpcTile(map, x, y)
	if map == nil or x == nil or y == nil then return false end
	if x < 0 or y < 0 or x > 255 or y > 255 then return false end
	if isBlockedByAttr(map, x, y) then return false end
	return true
end

local function pickSpawnValidated()
	local points = HideAndSeek.Config.SpawnPoints
	if type(points) ~= "table" or #points == 0 then return nil end

	local sf = HideAndSeek.Config.SpawnFind or {}
	local maxTries = sf.MaxTriesPerPoint or 200
	local maxSwaps = sf.MaxPointSwaps or 50

	for _ = 1, maxSwaps do
		local p = points[math.random(1, #points)]
		if type(p) == "table" then
			local minX, maxX = tonumber(p.minX) or 0, tonumber(p.maxX) or 0
			local minY, maxY = tonumber(p.minY) or 0, tonumber(p.maxY) or 0
			if maxX < minX then maxX = minX end
			if maxY < minY then maxY = minY end

			local map = tonumber(p.map) or 0
			for _t = 1, maxTries do
				local x = math.random(minX, maxX)
				local y = math.random(minY, maxY)
				if isValidNpcTile(map, x, y) then
					return { map = map, x = x, y = y, name = p.name or ("Map " .. tostring(map)) }
				end
			end
		end
	end
	return nil
end

local function pickSpawn()
	if HideAndSeek.Config.SpawnFind and HideAndSeek.Config.SpawnFind.Enabled then
		return pickSpawnValidated()
	end
	local points = HideAndSeek.Config.SpawnPoints
	local p = points[math.random(1, #points)]
	local minX, maxX = tonumber(p.minX) or 0, tonumber(p.maxX) or 0
	local minY, maxY = tonumber(p.minY) or 0, tonumber(p.maxY) or 0
	if maxX < minX then maxX = minX end
	if maxY < minY then maxY = minY end
	return { map = tonumber(p.map) or 0, x = math.random(minX, maxX), y = math.random(minY, maxY), name = p.name or ("Map " .. tostring(p.map)) }
end

-- ==========================================================
-- FIREWORKS
-- ==========================================================
local function clampTile(v)
	v = tonumber(v) or 0
	if v < 0 then return 0 end
	if v > 255 then return 255 end
	return v
end

local function sendRing(aIndex, cx, cy, radius, points, phase)
	phase = tonumber(phase) or 0
	points = tonumber(points) or 12
	if points < 4 then points = 4 end

	for i = 1, points do
		local ang = (2 * math.pi) * ((i - 1) / points) + phase
		local x = math.floor(cx + radius * math.cos(ang) + 0.5)
		local y = math.floor(cy + radius * math.sin(ang) + 0.5)
		FireworksSend(aIndex, clampTile(x), clampTile(y))
	end
end

local function doWinFireworks(aIndex)
	local fw = HideAndSeek.Config.WinFireworks
	if not fw or not fw.Enabled then return end
	if not FireworksSend then return end

	local cx = GetObjectMapX(aIndex)
	local cy = GetObjectMapY(aIndex)

	local baseRadius = tonumber(fw.Radius) or 1
	if baseRadius < 1 then baseRadius = 1 end

	local points = tonumber(fw.Count) or 6
	if points < 4 then points = 4 end

	sendRing(aIndex, cx, cy, baseRadius, points, 0)
	sendRing(aIndex, cx, cy, baseRadius + 2, points, math.pi / points)

	local sp = fw.Spiral or {}
	if not sp.Enabled then return end

	local ticks = tonumber(sp.Ticks) or 1
	if ticks < 1 then ticks = 1 end
	if ticks > 20 then ticks = 20 end

	local step = tonumber(sp.Step) or 1
	if step < 1 then step = 1 end
	if step > 5 then step = 5 end

	local t = 0
	local timerId = -1
	timerId = Timer.Interval(1, function()
		t = t + 1
		if t > ticks then
			if timerId ~= -1 then Timer.Cancel(timerId) end
			return
		end

		local maxR = baseRadius + 3
		local r = 1 + (maxR - 1) * (t / ticks)
		local phase = (2 * math.pi) * (t / ticks) * 2

		for k = 1, step do
			local ang = phase + (2 * math.pi) * ((k - 1) / step)
			local x = math.floor(cx + r * math.cos(ang) + 0.5)
			local y = math.floor(cy + r * math.sin(ang) + 0.5)
			FireworksSend(aIndex, clampTile(x), clampTile(y))
		end
	end)
end

-- ==========================================================
-- DELIVERY + ITEM BUILD (flex)
-- ==========================================================
local function shallowCopy(t)
	local out = {}
	if type(t) == "table" then
		for k, v in pairs(t) do out[k] = v end
	end
	return out
end

local function mergeTables(a, b)
	local out = shallowCopy(a)
	if type(b) == "table" then
		for k, v in pairs(b) do out[k] = v end
	end
	return out
end

local function normalizeItemReward(r, defaults)
	-- une defaults + reward
	local out = mergeTables(defaults or {}, r or {})
	if type(out.socket) ~= "table" then out.socket = { 255, 255, 255, 255, 255 } end
	return out
end

local function giveItemAuto(aIndex, r)
	-- r = reward item já normalizado
	local deliver = string.lower(tostring(r.deliver or "auto"))

	local deliveryCfg = HideAndSeek.Config.Delivery or {}
	local preferInv = (deliveryCfg.PreferInventory == true)
	local fallback = (deliveryCfg.FallbackToGremory == true)

	local function giveToInventory()
		-- check espaço por item (Louis oferece a função!)
		local okSpace = true
		if InventoryCheckSpaceByItem then
			local can = InventoryCheckSpaceByItem(aIndex, tonumber(r.index) or 0)
			-- convenção comum: 1 = pode, 0 = não pode
			okSpace = (can == 1 or can == true)
		end

		if not okSpace then return false end

		local socket = r.socket or {}
		ItemGiveEx(
			aIndex,
			tonumber(r.index) or 0,
			tonumber(r.level) or 0,
			tonumber(r.dur) or 255,
			tonumber(r.skill) or 0,
			tonumber(r.luck) or 0,
			tonumber(r.opt) or 0,
			tonumber(r.exc) or 0,
			tonumber(r.set) or 0,
			tonumber(r.jh) or 0,
			tonumber(r.exOpt) or 0,
			tonumber(socket[1]) or 255,
			tonumber(socket[2]) or 255,
			tonumber(socket[3]) or 255,
			tonumber(socket[4]) or 255,
			tonumber(socket[5]) or 255,
			tonumber(r.socketBonus) or 0,
			tonumber(r.duration) or 0
		)
		return true
	end

	local function giveToGremory()
		local socket = r.socket or {}
		local gType = tonumber(r.gremoryType) or tonumber(deliveryCfg.GremoryType) or 1
		local gNum = tonumber(r.gremoryNumber) or tonumber(deliveryCfg.GremoryNumber) or 10

		AddItemToGremoryCase(
			aIndex,
			gType,
			gNum,
			tonumber(r.index) or 0,
			tonumber(r.level) or 0,
			tonumber(r.dur) or 255,
			tonumber(r.skill) or 0,
			tonumber(r.luck) or 0,
			tonumber(r.opt) or 0,
			tonumber(r.exc) or 0,
			tonumber(r.set) or 0,
			tonumber(r.jh) or 0,
			tonumber(r.exOpt) or 0,
			tonumber(socket[1]) or 255,
			tonumber(socket[2]) or 255,
			tonumber(socket[3]) or 255,
			tonumber(socket[4]) or 255,
			tonumber(socket[5]) or 255,
			tonumber(r.socketBonus) or 0,
			tonumber(r.duration) or 0
		)
	end

	-- decisão:
	if deliver == "inventory" then
		if giveToInventory() then return end
		if fallback then
			giveToGremory()
			return
		end
		return
	end

	if deliver == "gremory" then
		giveToGremory()
		return
	end

	-- deliver == "auto"
	if preferInv then
		if giveToInventory() then return end
		if fallback then
			giveToGremory()
			return
		end
	else
		-- prefer gremory
		giveToGremory()
	end
end

-- ==========================================================
-- REWARDS BASICS
-- ==========================================================
local function giveZen(aIndex, amount)
	local money = GetObjectMoney(aIndex)
	SetObjectMoney(aIndex, money + (tonumber(amount) or 0))
	MoneySend(aIndex)
end

local function giveCoin(aIndex, coin1, coin2, coin3)
	ObjectAddCoin(aIndex, tonumber(coin1) or 0, tonumber(coin2) or 0, tonumber(coin3) or 0)
end

local function giveBuff(aIndex, r)
	EffectAdd(
		aIndex,
		tonumber(r.buffType) or 0,
		tonumber(r.effect) or 0,
		tonumber(r.seconds) or 0,
		tonumber(r.value1) or 0,
		tonumber(r.value2) or 0,
		tonumber(r.value3) or 0,
		tonumber(r.value4) or 0
	)
end

-- ==========================================================
-- KIT SYSTEM (flexível)
-- ==========================================================
local function giveKit(aIndex, kitDef, itemDefaults)
	if type(kitDef) ~= "table" then return end

	-- set completo
	if kitDef.setFull and type(kitDef.setFull.pieces) == "table" then
		for i = 1, #kitDef.setFull.pieces do
			local idx = kitDef.setFull.pieces[i]
			local r = normalizeItemReward({ type = "item", index = idx }, itemDefaults)
			giveItemAuto(aIndex, r)
		end
	end

	-- weapons (lista)
	if kitDef.weapons and type(kitDef.weapons.items) == "table" then
		for i = 1, #kitDef.weapons.items do
			local idx = kitDef.weapons.items[i]
			local r = normalizeItemReward({ type = "item", index = idx }, itemDefaults)
			giveItemAuto(aIndex, r)
		end
	end

	-- shield (único)
	if kitDef.shield and kitDef.shield.item then
		local r = normalizeItemReward({ type = "item", index = kitDef.shield.item }, itemDefaults)
		giveItemAuto(aIndex, r)
	end

	-- wings (único)
	if kitDef.wings and kitDef.wings.item then
		local r = normalizeItemReward({ type = "item", index = kitDef.wings.item }, itemDefaults)
		giveItemAuto(aIndex, r)
	end

	-- pet (único)
	if kitDef.pet and kitDef.pet.item then
		local r = normalizeItemReward({ type = "item", index = kitDef.pet.item }, itemDefaults)
		giveItemAuto(aIndex, r)
	end

	-- extras (lista de itens)
	if type(kitDef.extras) == "table" then
		for i = 1, #kitDef.extras do
			local it = kitDef.extras[i]
			if type(it) == "table" then
				local r = normalizeItemReward({ type = "item", index = it.index }, itemDefaults)
				-- sobrescreve com campos do item (level, luck etc)
				r = mergeTables(r, it)
				giveItemAuto(aIndex, r)
			end
		end
	end
end

local function giveClassKit(aIndex, kitName)
	local cr = HideAndSeek.Config.ClassKits
	if not cr or type(cr) ~= "table" then return end

	local kits = cr.Kits or {}
	local kitRoot = kits[kitName or "default"]
	if not kitRoot then
		warn("ClassKits: kit não encontrado: " .. tostring(kitName))
		return
	end

	local cls = GetObjectClass and tonumber(GetObjectClass(aIndex)) or -1
	local byClass = kitRoot.ByClassId or {}
	local kitDef = byClass[cls]
	if not kitDef then
		warn("ClassKits: sem configuração para ClassID=" .. tostring(cls) .. " (kit=" .. tostring(kitName) .. ")")
		return
	end

	local defaults = mergeTables(cr.ItemDefaults or {}, HideAndSeek.Config.Delivery or {})
	giveKit(aIndex, kitDef, defaults)
end

-- ==========================================================
-- giveRewardsList (agora com classkit/kit)
-- ==========================================================
local function giveRewardsList(aIndex, rewards)
	if type(rewards) ~= "table" then return end

	for i = 1, #rewards do
		local r = rewards[i]
		if type(r) == "table" then
			if r.type == "zen" then
				giveZen(aIndex, r.amount)

			elseif r.type == "coin" then
				local c1 = r.coin1 or r.wc or 0
				local c2 = r.coin2 or r.wp or 0
				local c3 = r.coin3 or r.gp or 0
				giveCoin(aIndex, c1, c2, c3)

			elseif r.type == "buff" then
				giveBuff(aIndex, r)

			elseif r.type == "item" then
				local defaults = (HideAndSeek.Config.ClassKits and HideAndSeek.Config.ClassKits.ItemDefaults) or {}
				local it = normalizeItemReward(r, defaults)
				giveItemAuto(aIndex, it)

			elseif r.type == "items" and type(r.list) == "table" then
				local defaults = (HideAndSeek.Config.ClassKits and HideAndSeek.Config.ClassKits.ItemDefaults) or {}
				for j = 1, #r.list do
					local ir = r.list[j]
					if type(ir) == "table" then
						local it = normalizeItemReward(ir, defaults)
						giveItemAuto(aIndex, it)
					end
				end

			elseif r.type == "kit" then
				-- kit genérico definido inline (r.setFull / r.weapons / r.wings / r.pet / r.extras)
				local defaults = (HideAndSeek.Config.ClassKits and HideAndSeek.Config.ClassKits.ItemDefaults) or {}
				local kitDef = r
				giveKit(aIndex, kitDef, defaults)

			elseif r.type == "classkit" then
				giveClassKit(aIndex, r.kit or "default")
			end
		end
	end
end

local function giveRoundRewards(aIndex)
	giveRewardsList(aIndex, HideAndSeek.Config.Rewards)
end

-- ==========================================================
-- HINTS
-- ==========================================================
function HideAndSeek.SendHint()
	if not HideAndSeek.Config.Hints or not HideAndSeek.Config.Hints.Enabled then return end
	local spawn = HideAndSeek.State.spawn
	if not spawn then return end

	local masks = HideAndSeek.Config.Hints.Masks
	if type(masks) ~= "table" or #masks == 0 then return end

	if HideAndSeek.State.hintLevel < #masks then
		HideAndSeek.State.hintLevel = HideAndSeek.State.hintLevel + 1
	end

	local mask = masks[HideAndSeek.State.hintLevel]
	if type(mask) ~= "table" then return end

	local xMasked = applyMask3(spawn.x, mask.x or "XXX")
	local yMasked = applyMask3(spawn.y, mask.y or "XXX")

	if (mask.x == "XXX" and mask.y == "XXX") then
		msgAll(string.format("%s DICA: O NPC está escondido no mapa %s.", PREFIX, spawn.name))
	else
		msgAll(string.format("%s DICA: O NPC está escondido em %s %s %s.", PREFIX, spawn.name, xMasked, yMasked))
	end
end

-- ==========================================================
-- NPC TALK VALIDATION
-- ==========================================================
local function isEventNpcTalk(aIndexNpc)
	if HideAndSeek.State.phase ~= "running" then return false end
	local sp = HideAndSeek.State.spawn
	if not sp then return false end

	if aIndexNpc == HideAndSeek.State.npcIndex then
		return true
	end

	if GetObjectMap and GetObjectMapX and GetObjectMapY then
		local map = GetObjectMap(aIndexNpc)
		local x = GetObjectMapX(aIndexNpc)
		local y = GetObjectMapY(aIndexNpc)
		if map ~= sp.map then return false end
		if math.abs(x - sp.x) > 1 then return false end
		if math.abs(y - sp.y) > 1 then return false end
	else
		return false
	end

	if GetObjectClass then
		if GetObjectClass(aIndexNpc) ~= HideAndSeek.Config.NpcClass then
			return false
		end
	end

	return true
end

-- ==========================================================
-- SQL (history + monthly rank)
-- ==========================================================
function HideAndSeek.SQL_InsertWin(winnerName, spawn)
	if not (HideAndSeek.Config.SQL and HideAndSeek.Config.SQL.Enabled) then return end
	local ht = HideAndSeek.Config.SQL.HistoryTable

	local serverCode = 0
	if GetGameServerCode then serverCode = GetGameServerCode() end

	winnerName = sqlEscape(winnerName)
	local map = tonumber(spawn and spawn.map) or 0
	local x = tonumber(spawn and spawn.x) or 0
	local y = tonumber(spawn and spawn.y) or 0

	sqlExec(string.format(
		"INSERT INTO %s (server_code,winner_name,map,x,y,event_time) VALUES (%d,'%s',%d,%d,%d,GETDATE())",
		ht, serverCode, winnerName, map, x, y
	))
end

function HideAndSeek.SQL_UpsertMonthlyRankWin(winnerName)
	if not (HideAndSeek.Config.SQL and HideAndSeek.Config.SQL.Enabled) then return end
	local rt = HideAndSeek.Config.SQL.RankMonthlyTable
	winnerName = sqlEscape(winnerName)

	sqlExec(string.format([[
IF EXISTS (SELECT 1 FROM %s WITH (NOLOCK) WHERE winner_name='%s')
	UPDATE %s SET wins=wins+1, last_update_time=GETDATE() WHERE winner_name='%s'
ELSE
	INSERT INTO %s (winner_name,wins,last_update_time) VALUES ('%s',1,GETDATE())
]], rt, winnerName, rt, winnerName, rt, winnerName))
end

function HideAndSeek.SQL_GetTopMonthly(topN)
	local rt = HideAndSeek.Config.SQL.RankMonthlyTable
	topN = tonumber(topN) or 3

	local res = {}
	local q = string.format([[
SELECT TOP %d winner_name, wins
FROM %s WITH (NOLOCK)
ORDER BY wins DESC, last_update_time ASC, winner_name ASC
]], topN, rt)

	local ok = SQLQuery(q)
	if ok == 0 then
		if HideAndSeek.Config.Log and HideAndSeek.Config.Log.Enabled then
			LogColor(2, "[HideAndSeek] SQLQuery falhou em SQL_GetTopMonthly")
		end
		if SQLClose then SQLClose() end
		return res
	end

	local fetch = SQLFetch()
	if fetch == 0 then
		repeat
			res[#res + 1] = { name = SQLGetString("winner_name"), wins = SQLGetNumber("wins") }
			fetch = SQLFetch()
		until fetch ~= 0
		if SQLClose then SQLClose() end
		return res
	end

	while fetch ~= 0 do
		res[#res + 1] = { name = SQLGetString("winner_name"), wins = SQLGetNumber("wins") }
		fetch = SQLFetch()
	end

	if SQLClose then SQLClose() end
	return res
end

function HideAndSeek.SQL_ResetMonthlyRank()
	local rt = HideAndSeek.Config.SQL.RankMonthlyTable
	sqlExec(string.format("DELETE FROM %s", rt))
end

function HideAndSeek.Monthly_AwardAndResetIfTime()
	if not (HideAndSeek.Config.MonthlyRank and HideAndSeek.Config.MonthlyRank.Enabled) then return end
	if not (HideAndSeek.Config.SQL and HideAndSeek.Config.SQL.Enabled) then return end

	local dk = dateKeyNow()
	if HideAndSeek.State.monthly.lastAwardDateKey == dk then return end

	if not isLastDayOfMonthNow() then return end
	if hourNow() ~= HideAndSeek.Config.MonthlyRank.Hour then return end
	if minuteNow() ~= HideAndSeek.Config.MonthlyRank.Minute then return end

	HideAndSeek.State.monthly.lastAwardDateKey = dk
	dbg("Monthly rank: award time reached.")

	local top = HideAndSeek.SQL_GetTopMonthly(HideAndSeek.Config.MonthlyRank.TopN or 3)
	if #top == 0 then
		msgAll(PREFIX .. " Ranking MENSAL: sem vencedores no período.")
		HideAndSeek.SQL_ResetMonthlyRank()
		msgAll(PREFIX .. " Ranking mensal foi zerado. Boa sorte no novo mês!")
		return
	end

	msgAll(string.format("%s Ranking MENSAL TOP %d:", PREFIX, #top))
	for place = 1, #top do
		local row = top[place]
		msgAll(string.format("%s #%d %s - %d vitórias", PREFIX, place, row.name, row.wins))

		local rewards = HideAndSeek.Config.MonthlyRank.RewardsByPlace[place]
		if type(rewards) == "table" and #rewards > 0 then
			local idx = GetObjectIndexByName(row.name)
			if idx ~= nil and idx >= 0 then
				giveRewardsList(idx, rewards)
				msgPlayer(idx, string.format("%s Você recebeu prêmio do ranking MENSAL (#%d).", PREFIX, place))
			end
		end
	end

	HideAndSeek.SQL_ResetMonthlyRank()
	msgAll(PREFIX .. " Ranking mensal foi zerado. Boa sorte no novo mês!")
end

-- ==========================================================
-- EVENT LIFECYCLE
-- ==========================================================
function HideAndSeek.Stop(reason, aIndex)
	if aIndex ~= nil then
		if not HideAndSeek_IsStaff(aIndex) then
			return
		end
	end

	if HideAndSeek.State.phase == "idle" then return end
	clearTimers()

	if HideAndSeek.State.npcIndex ~= -1 then
		MonsterDelete(HideAndSeek.State.npcIndex)
	end

	HideAndSeek.State.phase = "idle"
	HideAndSeek.State.prestartRemaining = 0
	HideAndSeek.State.eventRemaining = 0
	HideAndSeek.State.npcIndex = -1
	HideAndSeek.State.spawn = nil
	HideAndSeek.State.hintLevel = 0
	HideAndSeek.State.hintCountdown = 0

	if reason then
		msgAll(string.format("%s Evento encerrado (%s).", PREFIX, reason))
	else
		msgAll(string.format("%s Evento encerrado.", PREFIX))
	end
end

function HideAndSeek._StartRunning()
	if HideAndSeek.Config.Active == false then
		dbg("Start ignored: Active=false")
		HideAndSeek.Stop("desativado")
		return
	end

	if GetGameServerCurUser and GetGameServerCurUser() <= 0 then
		dbg("Start ignored: no players online.")
		HideAndSeek.Stop("sem jogadores online")
		return
	end

	HideAndSeek.State.phase = "running"
	HideAndSeek.State.eventRemaining = HideAndSeek.Config.DurationSeconds

	local spawn = pickSpawn()
	if not spawn then
		dbg("Falha ao encontrar coordenada válida.")
		HideAndSeek.Stop("erro ao gerar coordenada")
		return
	end

	HideAndSeek.State.spawn = spawn
	HideAndSeek.State.hintLevel = 0
	HideAndSeek.State.hintCountdown = (HideAndSeek.Config.Hints and HideAndSeek.Config.Hints.StartAfterSeconds) or 999999

	dbg(string.format("Running start: NPC class=%d map=%d x=%d y=%d", HideAndSeek.Config.NpcClass, spawn.map, spawn.x, spawn.y))

	HideAndSeek.State.npcIndex = MonsterCreate(HideAndSeek.Config.NpcClass, spawn.map, spawn.x, spawn.y, HideAndSeek.Config.NpcDir)
	dbg("MonsterCreate npcIndex=" .. tostring(HideAndSeek.State.npcIndex))

	msgAll(string.format("%s Evento Iniciado, Procure o NPC escondido.", PREFIX))

	local possibleMaps = getPossibleMapNames()
	if possibleMaps ~= "" then
		msgAll(string.format("%s O NPC pode estar escondido nos Mapas: %s.", PREFIX, possibleMaps))
	end

	HideAndSeek.State.timers.runningTick = Timer.Interval(1, function()
		if HideAndSeek.State.phase ~= "running" then return end

		HideAndSeek.State.eventRemaining = HideAndSeek.State.eventRemaining - 1
		if HideAndSeek.State.eventRemaining <= 0 then
			HideAndSeek.Stop("tempo esgotado")
			return
		end

		if shouldAnnounce(HideAndSeek.Config.RunningAnnouncements, HideAndSeek.State.eventRemaining) then
			msgAll(string.format("%s Tempo restante: %d segundo(s).", PREFIX, HideAndSeek.State.eventRemaining))
		end

		if HideAndSeek.Config.Hints and HideAndSeek.Config.Hints.Enabled then
			HideAndSeek.State.hintCountdown = HideAndSeek.State.hintCountdown - 1
			if HideAndSeek.State.hintCountdown <= 0 then
				HideAndSeek.SendHint()
				HideAndSeek.State.hintCountdown = HideAndSeek.Config.Hints.IntervalSeconds or 60
			end
		end
	end)
end

function HideAndSeek.Start(aIndex)
	if HideAndSeek.Config.Active == false then
		return false, "evento desativado"
	end

	if aIndex ~= nil then
		if not HideAndSeek_IsStaff(aIndex) then
			return false, "sem permissão"
		end
	end

	if HideAndSeek.State.phase ~= "idle" then
		return false, "já está em andamento"
	end

	if GetGameServerCurUser and GetGameServerCurUser() <= 0 then
		return false, "sem jogadores online"
	end

	math.randomseed(os.time())

	HideAndSeek.State.phase = "prestart"
	HideAndSeek.State.prestartRemaining = HideAndSeek.Config.PreStartSeconds

	dbg(string.format("Evento agendado. Inicia em %d segundo(s).", HideAndSeek.Config.PreStartSeconds))
	msgAll(formatStartCountdownMessage(HideAndSeek.State.prestartRemaining))

	HideAndSeek.State.timers.prestartTick = Timer.Interval(1, function()
		if HideAndSeek.State.phase ~= "prestart" then return end

		HideAndSeek.State.prestartRemaining = HideAndSeek.State.prestartRemaining - 1
		if HideAndSeek.State.prestartRemaining <= 0 then
			cancelTimer(HideAndSeek.State.timers.prestartTick)
			HideAndSeek.State.timers.prestartTick = -1
			HideAndSeek._StartRunning()
			return
		end

		if shouldAnnounce(HideAndSeek.Config.PreStartAnnouncements, HideAndSeek.State.prestartRemaining) then
			msgAll(formatStartCountdownMessage(HideAndSeek.State.prestartRemaining))
		end
	end)

	return true
end

-- ==========================================================
-- BRIDGES / EVENTS
-- ==========================================================
function HideAndSeek.OnNpcTalk(aIndexNpc, bIndexUser)
	dbg(string.format("OnNpcTalk fired: aIndexNpc=%d expectedNpc=%d phase=%s",
		tonumber(aIndexNpc) or -1,
		tonumber(HideAndSeek.State.npcIndex) or -1,
		tostring(HideAndSeek.State.phase)
	))

	if not isEventNpcTalk(aIndexNpc) then
		return 0
	end

	local winner = GetObjectName(bIndexUser)

	doWinFireworks(bIndexUser)
	msgAll(string.format("%s %s encontrou o NPC e venceu!", PREFIX, winner))

	HideAndSeek.SQL_InsertWin(winner, HideAndSeek.State.spawn)
	HideAndSeek.SQL_UpsertMonthlyRankWin(winner)

	giveRoundRewards(bIndexUser)

	dbg("Winner: " .. tostring(winner))
	HideAndSeek.Stop("vencedor: " .. winner)
	return 1
end

-- ==========================================================
-- COMMAND MANAGER
-- ==========================================================
function HideAndSeek.OnCommandManager(aIndex, arg)
	local cmd = string.lower(tostring(CommandGetArgString(arg, 0) or ""))

	local function requireStaff()
		if not HideAndSeek_IsStaff(aIndex) then
			msgPlayer(aIndex, PREFIX .. " Comando permitido apenas para GM/Admin.")
			return false
		end
		return true
	end

	-- DEBUG: descobrir ClassID
	if cmd == "/classid" then
		local cls = GetObjectClass and GetObjectClass(aIndex) or -1
		msgPlayer(aIndex, string.format("%s Sua ClassID = %s", PREFIX, tostring(cls)))
		dbg(string.format("DEBUG ClassID: name=%s class=%s", tostring(GetObjectName(aIndex)), tostring(cls)))
		return 1
	end

	if cmd == "/startescesc" then
		if not requireStaff() then return 1 end
		local ok, err = HideAndSeek.Start(aIndex)
		if ok then
			msgPlayer(aIndex, PREFIX .. " Evento agendado com sucesso.")
		else
			msgPlayer(aIndex, PREFIX .. " Não foi possível iniciar: " .. tostring(err))
		end
		return 1
	end

	if cmd == "/stopescesc" then
		if not requireStaff() then return 1 end
		HideAndSeek.Stop("parado por comando", aIndex)
		return 1
	end

	if cmd == "/rankescesc" then
		if not (HideAndSeek.Config.SQL and HideAndSeek.Config.SQL.Enabled) then
			msgPlayer(aIndex, PREFIX .. " SQL desativado.")
			return 1
		end

		local top = HideAndSeek.SQL_GetTopMonthly(HideAndSeek.Config.MonthlyRank.TopN or 3)
		msgAll(PREFIX .. " Ranking MENSAL (mês atual):")
		if #top == 0 then
			msgAll(PREFIX .. " (sem registros)")
			return 1
		end
		for i = 1, #top do
			msgAll(string.format("%s #%d %s - %d", PREFIX, i, top[i].name, top[i].wins))
		end
		return 1
	end

	if cmd == string.lower(tostring(HideAndSeek.Config.Command or "/hh")) then
		local sub = string.lower(tostring(CommandGetArgString(arg, 1) or ""))

		if sub == "start" then
			if not requireStaff() then return 1 end
			local ok, err = HideAndSeek.Start(aIndex)
			if ok then
				msgPlayer(aIndex, PREFIX .. " Evento agendado com sucesso.")
			else
				msgPlayer(aIndex, PREFIX .. " Não foi possível iniciar: " .. tostring(err))
			end
			return 1
		end

		if sub == "stop" then
			if not requireStaff() then return 1 end
			HideAndSeek.Stop("parado por comando", aIndex)
			return 1
		end

		if sub == "rank" then
			if not (HideAndSeek.Config.SQL and HideAndSeek.Config.SQL.Enabled) then
				msgPlayer(aIndex, PREFIX .. " SQL desativado.")
				return 1
			end
			local top = HideAndSeek.SQL_GetTopMonthly(HideAndSeek.Config.MonthlyRank.TopN or 3)
			msgAll(PREFIX .. " Ranking MENSAL (mês atual):")
			if #top == 0 then
				msgAll(PREFIX .. " (sem registros)")
				return 1
			end
			for i = 1, #top do
				msgAll(string.format("%s #%d %s - %d", PREFIX, i, top[i].name, top[i].wins))
			end
			return 1
		end

		msgPlayer(aIndex, PREFIX .. " Use: /startescesc | /stopescesc | /rankescesc | /classid")
		return 1
	end

	return 0
end

function HideAndSeek._ScheduleCallback()
	if HideAndSeek.Config.Active == false then
		dbg("Schedule ignored: Active=false")
		return
	end
	if HideAndSeek.State.phase ~= "idle" then
		dbg("Schedule ignored (already running).")
		return
	end
	dbg("Schedule callback -> Start()")
	HideAndSeek.Start()
end

function HideAndSeek.OnTimerThread()
	HideAndSeek.Monthly_AwardAndResetIfTime()
end

-- ==========================================================
-- INIT
-- ==========================================================
local function registerSchedules()
	local sch = HideAndSeek.Config.AutoSchedule
	if not sch or sch.Enabled ~= true then return end

	-- A) ByDayOfWeek
	if type(sch.ByDayOfWeek) == "table" then
		for dow, times in pairs(sch.ByDayOfWeek) do
			if type(times) == "table" then
				for i = 1, #times do
					local t = times[i]
					local hh = tonumber(t.Hour) or 0
					local mm = tonumber(t.Minute) or 0
					Schedule.SetDayOfWeek(tonumber(dow), hh, mm, HideAndSeek_Schedule_Bridge)
					dbg(string.format("Schedule: dow=%s %02d:%02d", tostring(dow), hh, mm))
				end
			end
		end
		return
	end

	-- B) Times (todo dia)
	local times = sch.Times
	if type(times) ~= "table" or #times == 0 then return end
	for i = 1, #times do
		local t = times[i]
		local hh = tonumber(t.Hour) or 0
		local mm = tonumber(t.Minute) or 0
		Schedule.SetHourAndMinute(hh, mm, HideAndSeek_Schedule_Bridge)
		dbg(string.format("Schedule: daily %02d:%02d", hh, mm))
	end
end

function HideAndSeek.Init()
	dbg("Script carregado. Registrando bridges...")

	BridgeFunctionAttach("OnCommandManager", "HideAndSeek_OnCommandManager_Bridge")
	BridgeFunctionAttach("OnNpcTalk", "HideAndSeek_OnNpcTalk_Bridge")
	BridgeFunctionAttach("OnTimerThread", "HideAndSeek_OnTimerThread_Bridge")

	dbg("type(FireworksSend)=" .. tostring(type(FireworksSend)))

	if HideAndSeek.Config.Active == false then
		dbg("Config.Active=false -> HideAndSeek desativado (bridges ok, schedule não será registrado).")
		return
	end

	registerSchedules()
	dbg("Ready.")
end

-- Bridge wrappers
function HideAndSeek_OnCommandManager_Bridge(aIndex, arg) return HideAndSeek.OnCommandManager(aIndex, arg) end
function HideAndSeek_OnNpcTalk_Bridge(aIndexNpc, bIndexUser) return HideAndSeek.OnNpcTalk(aIndexNpc, bIndexUser) end
function HideAndSeek_OnTimerThread_Bridge() HideAndSeek.OnTimerThread() end
function HideAndSeek_Schedule_Bridge() HideAndSeek._ScheduleCallback() end

HideAndSeek.Init()
return HideAndSeek
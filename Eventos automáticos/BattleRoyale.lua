--[[
Sistema de evento in-game 
]]--

BattleRoyale = {}

local Players = {}
local Participantes = {}
local Map = 0
local CoordX = 0
local CoordY = 0
local idtimer = -1
local timer = 0
local started = false
local ComandoOn = false
local timer_check = nil
local timer_finish = nil
local timer_vivos = nil
local timer_vivos2 = nil
local gm = ''
local timer_hp = nil
local timer_hp2 = nil
local timer_areaprotegida = nil
local timer_areaprotegida2 = nil
local timer_areaprotegida3 = nil

function BattleRoyale.TimerEvento()

	Timer.Interval(30, BattleRoyale.Init)
end

function BattleRoyale.Init()

	-- horário para o evento iniciar (está definido entre 19:00 e 19:01 no arquivo)
	if os.date("%X") >= "19:00:00" and os.date("%X") <= "19:01:00"
	then
		--
	else
		return
	end

	if started == true
	then
		return
	end
	
	BattleRoyale.CommandOpen_Auto()
	
end


function BattleRoyale.CommandOpen_Auto()
	
	timer_check = nil
	timer_finish = nil
	timer_vivos = nil
	timer_vivos2 = nil
	gm = ''

	Players = {}
	Participantes = {}
	
	timer = 30
	
	Map = 6
	CoordX = 63
	CoordY = 164
	
	started = false
	ComandoOn = true
	
	idtimer = Timer.Repeater(1, timer, BattleRoyale.Running)
	
	SendMessageGlobal(string.format("[Sistema] Battle Royale está aberto!"), 1)
	
end




function BattleRoyale.CheckUser()

	if started == false
	then
		return
	end

	for i, name in ipairs(Participantes) do 
		local index = Participantes[name]
		local NickRemover = UserGetName(index)
			
		if UserGetConnected(index) ~= 3
		then
			BattleRoyale.RemoveUser(i)
			BattleRoyale.CheckVivos()
		end
		
		if UserGetMapNumber(index) ~= Map
		then
			BattleRoyale.RemoveUser(NickRemover)
			BattleRoyale.CheckVivos()
		end
		
		if UserGetMapNumber(index) == Map
		then
			if UserGetX(index) < 55 and UserGetY(index) < 142 or UserGetX(index) > 69 and UserGetY(index) > 179
			then
				SendMessage(string.format("[Sistema] Você saiu do evento!"), index, 21)
				DataBase.SetValue("Character", "block_abrirbau", 0, "Name", UserGetName(index)) -- remover block abrir bau
				DataBase.SetValue("Character", "block_compraritens", 0, "Name", UserGetName(index)) -- remover block comprar itens
				
				for i = 12, 75 do
					if InventoryIsItem(index, i) == 1
						then
							if InventoryGetIndex(index, i) == GET_ITEM(14, 116)
							then
								if InventoryGetLevel(index, i) >= 0
								then
									InventoryDeleteItem(index, i)
									SendInventoryDeleteItem(index, i)
								end
									
							end
						end
				end
			
				Teleport(index, 0, 125, 125)
				BattleRoyale.RemoveUser(NickRemover)
				BattleRoyale.CheckVivos()
			end
		end
		
	end
	
	
end


function BattleRoyale.TirarHP()

	if started == false
	then
		return
	end
	
	SendMessageGlobal(string.format(" "), 0)
	SendMessageGlobal(string.format("[Battle Royale] O mapa agora vai começar a tirar HP!"), 0)
	SendMessageGlobal(string.format("CORRA para o centro do mapa 63 154 para não perder HP!!!"), 0)
	
	timer_hp2 = Timer.Interval(3, BattleRoyale.TirarHP2)
	
end

function BattleRoyale.TirarHP2()

	if started == false
	then
		return
	end

	for i, name in ipairs(Participantes) do 
		local index = Participantes[name]
		local NickRemover = UserGetName(index)
			
		if UserGetMapNumber(index) == Map
		then
			if UserGetX(index) < 60 and UserGetY(index) < 151 or UserGetX(index) > 67 and UserGetY(index) > 157
			then
				SendMessage(string.format("[Sistema] Vá para o centro do mapa 63 154 para não perder HP!"), 21)
				UserSetAddLife(index, (math.floor(UserGetAddLife(index) - 5000)))
				LifeUpdate(index, UserGetAddLife(index))
			end
		end
		
	end
			
			
end



function BattleRoyale.AreaProtegida()

	if started == false
	then
		return
	end
	
	SendMessageGlobal(string.format(" "), 0)
	SendMessageGlobal(string.format("[Battle Royale] Todos devem sair AGORA da área protegida!"), 0)
	SendMessageGlobal(string.format("Quem permanecer por mais de 30 segundos, será movido!!!!"), 0)
	SendMessageGlobal(string.format("(Venham para 63 154 e se matem!)"), 0)
	
	timer_areaprotegida2 = Timer.TimeOut(30, BattleRoyale.AreaProtegida2)
	
end

function BattleRoyale.AreaProtegida2()

	if started == false
	then
		return
	end
	
	timer_areaprotegida3 = Timer.Interval(1, BattleRoyale.AreaProtegida3)
	
end

function BattleRoyale.AreaProtegida3()

	if started == false
	then
		return
	end

	for i, name in ipairs(Participantes) do 
		local index = Participantes[name]
		local NickRemover = UserGetName(index)
			
		if UserGetMapNumber(index) == Map
		then
			if UserGetX(index) >= 160
			then
				SendMessage(string.format("[Sistema] Você foi movido por permanecer na área protegida!"), index, 21)
				SendMessageGlobal(string.format("[Battle Royale] %s movido porque ficou na área protegida!", NickRemover), 0)
				Teleport(index, 0, 125, 125)
			end
		end
		
	end
			
			
end


function BattleRoyale.CheckVivos()

	if started == false
	then
		return
	end
	
	if #Participantes <= 3 and #Participantes > 1
	then
		SendMessageGlobal(string.format("[Battle Royale] Restam %d players vivos!", #Participantes), 0)
	end
	
	if #Participantes == 1
	then
	
		if timer_vivos2 ~= nil
		then
			Timer.Cancel(timer_vivos2)
			timer_vivos2 = nil
		end
		
		BattleRoyale.FinishEvent()
	
	end
		
		
end



function BattleRoyale.CheckVivos2()

	if started == false
	then
		return
	end
	
	if #Participantes == 1
	then
		BattleRoyale.FinishEvent()
	end
		
end



function BattleRoyale.FinishEvent()

	SendMessageGlobal(string.format("[Sistema] Battle Royale finalizado!"), 0)
	
	if #Participantes >= 2 or #Participantes < 1
	then
	
		SendMessageGlobal(string.format("(Os players demoraram para se matar ou todos saíram do mapa/jogo)."), 0)
		
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name]
			local NickRemover = UserGetName(index)
				
			if UserGetConnected(index) ~= 3
			then
				BattleRoyale.RemoveUser(NickRemover)
			end
				
			Teleport(Participantes[name], 0, 125, 125)
				
		end
		
		
	elseif #Participantes == 1
	then
	
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name]
			SendMessageGlobal(string.format("Vencedor: %s", UserGetName(index)), 0)
			
			
			local Premio = 10
			local TipoVip = DataBase.GetValue("MEMB_INFO", "Vip", "memb___id", UserGetAccountID(index))
				
			if TipoVip == 2
			then
				Premio = math.floor(Premio * 2)
			else
				Premio = Premio
			end
			
			if TipoVip == 3
			then
				Premio = math.floor(Premio * 3)
			else
				Premio = Premio
			end
				
			DataBase.SetAddValue("MEMB_INFO", "diamantes", Premio, "memb___id", UserGetAccountID(index))
			DataBase.SetAddValue("Character", "battleroyale", 1, "Name", UserGetName(index))
			SendMessageGlobal(string.format("~> Prêmio: %d Diamantes! <~", Premio), 0)
			
			for b = 1, 15 do
				--ItemSerialCreate(index, 236, 0, 0, GET_ITEM(14, 41), 0, 0, 0, 0, 0, 0)
			end
	
			DataBase.SetValue("Character", "block_abrirbau", 0, "Name", UserGetName(index)) -- remover block abrir bau
			DataBase.SetValue("Character", "block_compraritens", 0, "Name", UserGetName(index)) -- remover block comprar itens
			Teleport(index, 0, 125, 125)

			-- pontos eventos total
			DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(index))
			DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(index))
			DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(index))
				
			-- prêmio em diamantes (finais de semana)
			if Premio > 0 --if os.date("%a") == "Sat" or os.date("%a") == "Sun"
			then
				--DataBase.SetAddValue("MEMB_INFO", "diamantes", 10, "memb___id", UserGetAccountID(index))
				--SendMessageGlobal(string.format("(Prêmio Extra: +10 Diamantes!)"), 0)
			end
			
			
			
			if gm ~= ''
			then
				local PremioGM = math.floor(Premio/3)
				local indexGM = GetIndex(gm)
				DataBase.SetAddValue("MEMB_INFO", "eventcashs", PremioGM, "memb___id", UserGetAccountID(indexGM))
			end
			
			
		end
		
	end
	
	started = false
	ComandoOn = false
	
	if timer_finish ~= nil
	then
		Timer.Cancel(timer_finish)
		timer_finish = nil
	end
	
	if timer_vivos ~= nil
	then
		Timer.Cancel(timer_vivos)
		timer_vivos = nil
	end
	
	if timer_vivos2 ~= nil
	then
		Timer.Cancel(timer_vivos2)
		timer_vivos2 = nil
	end
	
	if timer_check ~= nil
	then
		Timer.Cancel(timer_check)
		timer_check = nil
	end
	
	if timer_hp ~= nil
	then
		Timer.Cancel(timer_hp)
		timer_hp = nil
	end
	
	if timer_hp2 ~= nil
	then
		Timer.Cancel(timer_hp2)
		timer_hp2 = nil
	end
	
	if timer_areaprotegida ~= nil
	then
		Timer.Cancel(timer_areaprotegida)
		timer_areaprotegida = nil
	end
	
	if timer_areaprotegida2 ~= nil
	then
		Timer.Cancel(timer_areaprotegida2)
		timer_areaprotegida2 = nil
	end
	
	if timer_areaprotegida3 ~= nil
	then
		Timer.Cancel(timer_areaprotegida3)
		timer_areaprotegida3 = nil
	end
	

end


-- configurar lista de drops
EVENT_DROP_ITEM_BATTLE = {{Section = 0, ID = 0, DropCount = 5},
{Section = 0, ID = 12, DropCount = 5},
{Section = 0, ID = 11, DropCount = 5},
{Section = 0, ID = 8, DropCount = 5},
{Section = 0, ID = 19, DropCount = 5},
{Section = 2, ID = 4, DropCount = 5},
{Section = 2, ID = 12, DropCount = 5},
{Section = 6, ID = 5, DropCount = 5},
{Section = 6, ID = 12, DropCount = 5},
{Section = 6, ID = 13, DropCount = 5},
{Section = 6, ID = 8, DropCount = 5},
{Section = 7, ID = 0, DropCount = 5},
{Section = 8, ID = 0, DropCount = 5},
{Section = 9, ID = 0, DropCount = 5},
{Section = 10, ID = 0, DropCount = 5},
{Section = 11, ID = 0, DropCount = 5},
{Section = 7, ID = 1, DropCount = 5},
{Section = 8, ID = 1, DropCount = 5},
{Section = 9, ID = 1, DropCount = 5},
{Section = 10, ID = 1, DropCount = 5},
{Section = 11, ID = 1, DropCount = 5},
{Section = 7, ID = 8, DropCount = 5},
{Section = 8, ID = 8, DropCount = 5},
{Section = 9, ID = 8, DropCount = 5},
{Section = 10, ID = 8, DropCount = 5},
{Section = 11, ID = 8, DropCount = 5},
{Section = 7, ID = 9, DropCount = 5},
{Section = 8, ID = 9, DropCount = 5},
{Section = 9, ID = 9, DropCount = 5},
{Section = 10, ID = 9, DropCount = 5},
{Section = 11, ID = 9, DropCount = 5},
{Section = 7, ID = 16, DropCount = 5},
{Section = 8, ID = 16, DropCount = 5},
{Section = 9, ID = 16, DropCount = 5},
{Section = 10, ID = 16, DropCount = 5},
{Section = 11, ID = 16, DropCount = 5},
{Section = 12, ID = 2, DropCount = 15},
}

function BattleRoyale.Running()

	if timer == 0
	then
		
		timer_check = Timer.Interval(2, BattleRoyale.CheckUser)
		timer_vivos = Timer.Interval(15, BattleRoyale.CheckVivos)
		timer_vivos2 = Timer.Interval(3, BattleRoyale.CheckVivos2)
		timer_finish = Timer.TimeOut(5 * 60, BattleRoyale.FinishEvent)
		
		started = true
		ComandoOn = false

		timer_areaprotegida = Timer.TimeOut(30, BattleRoyale.AreaProtegida)
		timer_hp = Timer.TimeOut(2 * 60, BattleRoyale.TirarHP)
		
		for i, name in ipairs(Players) do 
			local index = Players[name]
			local NickRemover = UserGetName(index)
			
			if UserGetConnected(index) ~= 3
			then
				BattleRoyale.RemoveUserPlayers(NickRemover)
			end
			
			InsertKey(Participantes, UserGetName(index))
			Participantes[UserGetName(index)] = index
			Teleport(Participantes[name], Map, CoordX, CoordY)
			
			for i = 12, 75 do
				if InventoryIsItem(Participantes[name], i) == 1
					then
						if InventoryGetIndex(Participantes[name], i) == GET_ITEM(14, 116)
						then
							if InventoryGetLevel(Participantes[name], i) >= 0
							then
								InventoryDeleteItem(Participantes[name], i)
								SendInventoryDeleteItem(Participantes[name], i)
							end
								
						end
					end
			end
				
			ItemSerialCreate(Participantes[name], 236, 0, 0, GET_ITEM(14, 3), 0, 255, 0, 0, 0, 0)
			
			UserSetReqWarehouseOpen(Participantes[name], 0)
			
		end
		
		
		if #Participantes < 2
		then
			SendMessageGlobal(string.format("[Sistema] O evento não pode iniciar"), 0)
			SendMessageGlobal(string.format("porque vieram menos de 2 players!"), 0)
			
			for i, name in ipairs(Participantes) do 
				local index = Participantes[name]
				local NickRemover = UserGetName(index)
				
				if UserGetConnected(index) ~= 3
				then
					BattleRoyale.RemoveUser(NickRemover)
				end
				
				Teleport(Participantes[name], 0, 125, 125)
				DataBase.SetValue("Character", "block_abrirbau", 0, "Name", UserGetName(index)) -- remover block abrir bau
				DataBase.SetValue("Character", "block_compraritens", 0, "Name", UserGetName(index)) -- remover block comprar itens
				
			end
			
			started = false
			ComandoOn = false
			
			if timer_finish ~= nil
			then
				Timer.Cancel(timer_finish)
				timer_finish = nil
			end
			
			if timer_vivos ~= nil
			then
				Timer.Cancel(timer_vivos)
				timer_vivos = nil
			end
			
			if timer_vivos2 ~= nil
			then
				Timer.Cancel(timer_vivos2)
				timer_vivos2 = nil
			end
			
			if timer_check ~= nil
			then
				Timer.Cancel(timer_check)
				timer_check = nil
			end
			
			if timer_hp ~= nil
			then
				Timer.Cancel(timer_hp)
				timer_hp = nil
			end
			
			if timer_hp2 ~= nil
			then
				Timer.Cancel(timer_hp2)
				timer_hp2 = nil
			end
			
			if timer_areaprotegida ~= nil
			then
				Timer.Cancel(timer_areaprotegida)
				timer_areaprotegida = nil
			end
			
			if timer_areaprotegida2 ~= nil
			then
				Timer.Cancel(timer_areaprotegida2)
				timer_areaprotegida2 = nil
			end
			
			if timer_areaprotegida3 ~= nil
			then
				Timer.Cancel(timer_areaprotegida3)
				timer_areaprotegida3 = nil
			end
					

			return
			
		end
		
		
		-- Dropar itens espalhados
		for i in ipairs(EVENT_DROP_ITEM_BATTLE) do
			for n = 1, EVENT_DROP_ITEM_BATTLE[i].DropCount do
							
				local tab = {}
							
				local map = 6
				local x = 63
				local y = 160
				local range = 10
								
				if BattleRoyale.GetCoordRandomDrop(tab, map, x, y, range, range, 50) == 1
				then
					x = tab[0]
					y = tab[1]
				end
					
				Level = math.random(6, 9)
					
				ItemSerialCreate(BattleRoyale.GetIndex(),map, x, y, GET_ITEM(EVENT_DROP_ITEM_BATTLE[i].Section, EVENT_DROP_ITEM_BATTLE[i].ID), Level, 255, 1, 1, 1, 0)

			end
		end
		
		
		SendMessageGlobal(string.format("Move %s fechou!", "/battle"), 0)
		SendMessageGlobal(string.format("Aguarde o próximo evento."), 0)
		BattleRoyale.CheckVivos()
	else
		SendMessageGlobal(string.format("Move %s fecha em %d segundo(s)", "/battle", timer), 0)
		timer = timer - 1
	end
	
end

function BattleRoyale.GetIndex()
	for i = 9000, 9999 do
		if UserGetConnected(i) == 3
		then
			return i
		end
	end
	
	return 6400
end

function BattleRoyale.GetCoordRandomDrop(tab, map, ox, oy, tx, ty, count)
	local x = ox
	local y = oy

	local tx = tx
	
	if tx < 1
	then
		tx = 1
	end
	
	local ty = ty
	
	if ty < 1
	then
		ty = 1
	end
	
	local nx = 0
	local ny = 0

	for i = 0, count do
		nx = math.random(0, tx+1)
		
		local rand1 = math.random(0, 1)
		
		if rand1 == 0
		then
			rand1 = -1
		end
		
		nx = nx * rand1 + x
		
		ny = math.random(0, tx+1)
		
		local rand2 = math.random(0, 1)
		
		if rand2 == 0
		then
			rand2 = -1
		end
		
		ny = ny * rand1 + y
		
		if GetMapAttr(map, nx, ny, 4) == 0 and GetMapAttr(map, nx, ny, 8) == 0
		then
			tab[0] = nx
			tab[1] = ny
			return 1
		end
	end

	return 0
end

function BattleRoyale.CommandOpen(aIndex, Arguments)
	
	if UserGetAuthority(aIndex) == 1
	then
		return
	end

	timer_check = nil
	timer_finish = nil
	timer_vivos = nil
	timer_vivos2 = nil
	gm = UserGetName(aIndex)
	
	Players = {}
	Participantes = {}
	
	timer = CommandGetNumber(Arguments, 1)
	
	if timer == 0
	then
		SendMessage(string.format("[Sistema] Uso %s tempo", "/abrirbattle"), aIndex, 21)
		return
	end
	
	if timer > 60
	then
		SendMessage(string.format("[Sistema] O tempo máximo para abrir é de 60 segundos!"), aIndex, 21)
		return
	end
	
	Map = 6
	CoordX = 63
	CoordY = 164
	
	started = false
	ComandoOn = true
	
	DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
	
	idtimer = Timer.Repeater(1, timer, BattleRoyale.Running)
	
	SendMessageGlobal(string.format("[Sistema] %s abriu %s", UserGetName(aIndex), "/battle"), 1)
	
end

function BattleRoyale.CommandGo(aIndex, Arguments)

	if UserGetAuthority(aIndex) ~= 1
	then
		SendMessage(string.format("[Sistema] STAFFERs não podem participar de eventos!"), aIndex, 21)
		return
	end
	
	if ComandoOn == false
	then
		SendMessage(string.format("[Sistema] Battle Royale não está aberto neste momento."), aIndex, 21)
		return
	end
	
	if UserGetLevel(aIndex) < 100
	then
		SendMessage(string.format("[Sistema] Você precisa estar acima do level %d", 100), aIndex, 21)
		return
	end
	
	if UserGetDbClass(aIndex) == 17 or UserGetDbClass(aIndex) == 64
	then
		--
	else
		--SendMessage(string.format("[Sistema] Somente BKs e DLs podem ir neste evento!"), aIndex, 21)
		--return
	end
	
	for i = 12, 75 do
		if InventoryIsItem(aIndex, i) ~= 0
		then
			SendMessage(string.format("[Sistema] Seu inventário precisa estar vazio, sem NENHUM item!"), aIndex, 21)
			SendMessage(string.format("--> Guarde todos os seus itens no Baú."), aIndex, 21)
			return
		end
	end
	
	for i, number in ipairs({0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}) do
		if InventoryIsItem(aIndex, number) == 1
		then
			SendMessage(string.format("[Sistema] DESEQUIPE TODOS OS SEUS ITENS!"), aIndex, 21)
			SendMessage(string.format("Guarde tudo no baú, pois seu char e inventário devem estar limpos."), aIndex, 21)
			return
		end
	end
	
	local Name = UserGetName(aIndex)

	if DataBase.GetValue(TABLE_RESET, COLUMN_RESET[0], WHERE_RESET, Name) < 0
	then
		SendMessage(string.format("[Sistema] Você precisa de %d resets", 0), aIndex, 21)
		return
	end
	
	if DataBase.GetValue(TABLE_MRESET, COLUMN_MRESET[0], WHERE_MRESET, Name) < 0
	then
		SendMessage(string.format("[Sistema] Você precisa de %d MRs", 0), aIndex, 21)
		return
	end
	
	if UserGetInterfaceUse(aIndex) ~= 0 or UserGetState(aIndex) == 32 or UserGetDieRegen(aIndex) ~= 0 or UserGetTeleport(aIndex) ~= 0
	then
		SendMessage(string.format("[Sistema] Feche o Baú ou outras janelas que estiverem abertas!"), aIndex, 21)
		return
	end
	
	if Players[UserGetName(aIndex)] == nil
	then
		InsertKey(Players, UserGetName(aIndex))
		
		Players[UserGetName(aIndex)] = aIndex
		
		SendMessage(string.format("[Sistema] Você será movido em alguns segundos..."), aIndex, 22)
		SendMessage(string.format("Não relogue, não mova ou será eliminado"), aIndex, 22)
		DataBase.SetValue("Character", "block_abrirbau", 1, "Name", UserGetName(aIndex)) -- add block abrir bau
		DataBase.SetValue("Character", "block_compraritens", 1, "Name", UserGetName(aIndex)) -- add block comprar itens
		ItemSerialCreate(aIndex, 236, 0, 0, GET_ITEM(14, 116), 0, 255, 0, 0, 0, 0)
		UserSetReqWarehouseOpen(aIndex, 1)
		Teleport(aIndex, Map, CoordX, CoordY)

	else
		SendMessage(string.format("[Sistema] Você será movido em alguns segundos..."), aIndex, 22)
		DataBase.SetValue("Character", "block_abrirbau", 1, "Name", UserGetName(aIndex)) -- add block abrir bau
		DataBase.SetValue("Character", "block_compraritens", 1, "Name", UserGetName(aIndex)) -- add block comprar itens
		ItemSerialCreate(aIndex, 236, 0, 0, GET_ITEM(14, 116), 0, 255, 0, 0, 0, 0)
		UserSetReqWarehouseOpen(aIndex, 1)
		Teleport(aIndex, Map, CoordX, CoordY)
	end
	
end


function BattleRoyale.Morte(aIndex, TargetIndex)

	if started == false
	then
		return
	end
	
	
	if Participantes[UserGetName(aIndex)] == nil or Participantes[UserGetName(TargetIndex)] == nil
	then
		--
	else
		SendMessageGlobal(string.format("[Battle Royale] %s matou %s", UserGetName(aIndex), UserGetName(TargetIndex)), 0)
		
		SendMessage(string.format("[Battle Royale] Você matou %s", UserGetName(TargetIndex)), aIndex, 22)
		SendMessage(string.format("[Battle Royale] %s matou você!", UserGetName(aIndex)), TargetIndex, 21)
		DataBase.SetValue("Character", "block_abrirbau", 0, "Name", UserGetName(TargetIndex)) -- remover block abrir bau
		DataBase.SetValue("Character", "block_compraritens", 0, "Name", UserGetName(TargetIndex)) -- remover block comprar itens
		
		for i = 12, 75 do
			if InventoryIsItem(TargetIndex, i) == 1
				then
					if InventoryGetIndex(TargetIndex, i) == GET_ITEM(14, 116)
					then
						if InventoryGetLevel(TargetIndex, i) >= 0
						then
							InventoryDeleteItem(TargetIndex, i)
							SendInventoryDeleteItem(TargetIndex, i)
						end
								
					end
				end
		end
			
		Teleport(TargetIndex, 0, 125, 125)
		
		local nomeRemover = UserGetName(TargetIndex)
		BattleRoyale.RemoveUser(nomeRemover)
		BattleRoyale.CheckVivos()
	end
	

end



function BattleRoyale.RemoveUser(Name)
	for i, key in ipairs(Participantes) do
		if key == Name
		then
			table.remove(Participantes, i)
		end
	end
end

function BattleRoyale.RemoveUserPlayers(Name)
	for i, key in ipairs(Players) do
		if key == Name
		then
			table.remove(Players, i)
		end
	end
end


Commands.Register("/abrirbattle", BattleRoyale.CommandOpen)
Commands.Register("/battle", BattleRoyale.CommandGo)
GameServerFunctions.PlayerDie(BattleRoyale.Morte)

BattleRoyale.TimerEvento()

return BattleRoyale
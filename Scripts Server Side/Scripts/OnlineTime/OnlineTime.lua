local CONFIG = require("Scripts\\OnlineTime\\Config")

BridgeFunctionAttach('OnCommandManager','OnlineTimeCommand')


BridgeFunctionAttach('OnCharacterEntry','OnlineTimeEnterCharacter')
BridgeFunctionAttach('OnCharacterClose','OnlineTimeCloseCharacter')

local OnlineTime = {}
local AUTO_ONLINE_TIME = {}


function OnlineTimeCommand(aIndex, Arguments)

    if CONFIG.Enable == 0 then return 0 end

    local Command = CommandGetArgString(Arguments,0)

	if not (Command == CONFIG.Command) then
		return 0
	end

    local Language = GetObjectLanguage(aIndex)
    local AccountID = GetObjectAccount(aIndex)
    local test = GetExpRate(aIndex)

    local tempo = DataBase.GetValue('MEMB_STAT', 'OnlineHours', 'memb___id', AccountID)

    if tempo < 60 then
        MessageSend(aIndex, 0, 0, string.format(CONFIG.MESSAGES[1][Language], tempo))
    elseif tempo >= 1440 then
        MessageSend(aIndex, 0, 0, string.format(CONFIG.MESSAGES[3][Language], tempo/60/24))
    else
        MessageSend(aIndex, 0, 0, string.format(CONFIG.MESSAGES[2][Language], tempo/60))
    end
    MessageSend(aIndex, 0, 0, string.format("%d", test))


    AccountID = nil
    horas = nil


end


function OnlineTimeEnterCharacter(aIndex)

    if CONFIG.Enable == 0 then return 0 end

    local AccountID = GetObjectAccount(aIndex)

    AUTO_ONLINE_TIME[aIndex] = {accountid = AccountID, timer = CONFIG.Timer}

    return 0

end

function OnlineTimeCloseCharacter(aIndex)
    if CONFIG.Enable == 0 then return 0 end

	if AUTO_ONLINE_TIME[aIndex]
	then
		AUTO_ONLINE_TIME[aIndex] = nil
	end
end

function OnlineTime.MainProc()

    for key in pairs(AUTO_ONLINE_TIME) do
		local ontime = AUTO_ONLINE_TIME[key]

		ontime.timer = ontime.timer - 1
if CONFIG.Debug == 1 then  NoticeSend(key,1,string.format('[DEBUG] CurTime:%d/ MaxTime:%d', ontime.timer, CONFIG.Timer)) end

		if ontime.timer <= 0
		then

            local MEMB_NAME = GetObjectAccount(key)

            DataBase.SetAddValue('MEMB_STAT', 'OnlineHours', 1, 'memb___id', MEMB_NAME)

			ontime.timer = CONFIG.Timer
		end

	end

end

function OnlineTime.AutoLoad()
    for i = GetMinUserIndex(), GetMaxUserIndex() do
        if GetObjectConnected(i) == 3 then
            local AccountID = GetObjectAccount(i)
            AUTO_ONLINE_TIME[i] = {accountid = AccountID, timer = CONFIG.Timer}
        end
    end
end

function OnlineTime.Check()
    for i = GetMinUserIndex(), GetMaxUserIndex() do
        if GetObjectConnected(i) == 3 then
            local AccountID = GetObjectAccount(i)
            local Get = GetExpRate(i)
            LogColor(4, 'Exp Final = '.. GetExpRate(i))
        end
    end
end

OnlineTime.AutoLoad()

--Timer.Interval(1, OnlineTime.Check)
Timer.Interval(1, OnlineTime.MainProc)
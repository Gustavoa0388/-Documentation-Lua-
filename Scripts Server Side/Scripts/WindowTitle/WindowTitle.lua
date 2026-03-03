local CONFIG = require("Scripts\\WindowTitle\\Config")

WindowTitle = {}

BridgeFunctionAttach('OnCharacterEntry','EWindowTitleSendCheck')

function WindowTitle.WindowTitleSendCheck()
    for i = GetMinUserIndex(), GetMaxUserIndex() do
        if GetObjectConnected(i) == 3 then
                WindowTitle.Init(i)
                
        end
    end  
end

function EWindowTitleSendCheck(aIndex)

    WindowTitle.Init(aIndex)

end

function WindowTitle.Init(aIndex)

    local ViewName = GetObjectName(aIndex)
    local ViewLevel = GetObjectLevel(aIndex)
    local ViewReset = GetObjectReset(aIndex)
    local ViewVip = CONFIG.VIPTEXT[GetObjectAccountLevel(aIndex)]
    local ViewHunt = DataBase.GetValue('HuntFarm', 'HuntPoint', 'AccountID', GetObjectAccount(aIndex))

    local ViewNameLen = ViewName:len()
    local ViewVipLen = ViewVip:len()

	local packetInformation = string.format("%s-%s", ViewName, CONFIG.PACKET)


	CreatePacket(packetInformation, CONFIG.PACKET)
    SetBytePacket(packetInformation, ViewNameLen)
    SetBytePacket(packetInformation, ViewVipLen)
    SetCharPacketLength(packetInformation, ViewName, ViewNameLen)
	SetDwordPacket(packetInformation, ViewLevel)
    SetDwordPacket(packetInformation, ViewReset)
    SetCharPacketLength(packetInformation, ViewVip, ViewVipLen)
	SetDwordPacket(packetInformation, ViewHunt)

	SendPacket(packetInformation,aIndex)
	ClearPacket(packetInformation)
end


Timer.Interval(10, WindowTitle.WindowTitleSendCheck)



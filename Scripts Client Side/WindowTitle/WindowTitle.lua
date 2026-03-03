local CONFIG = require("Scripts\\WindowTitle\\Config")

BridgeFunctionAttach('MainProcThread','WindowTitleMainProc')

WindowTitle = {}

wt = { StringWindowTitle = "MuFrontal", ViewName  = "Character", ViewLevel  = "400", ViewReset  = "100", ViewVip  = "Frontal", ViewHunt  = "100"}

function WindowTitle.Init()
	ProtocolFunctions.ClientProtocol(WindowTitle.Protocol)
end

function WindowTitle.Protocol(Packet, PacketName)

	if Packet == CONFIG.PACKET and PacketName == string.format("%s-%s",UserGetName(), CONFIG.PACKET) then 

		local NameLen = GetBytePacket(PacketName, -1)
		local VipLen = GetBytePacket(PacketName, -1)
		wt.StringWindowTitle = CONFIG.ServerName
		wt.ViewName = GetCharPacketLength(PacketName, -1, NameLen)
		wt.ViewLevel = GetDwordPacket(PacketName, -1)
		wt.ViewReset = GetDwordPacket(PacketName, -1)
		wt.ViewVip = GetCharPacketLength(PacketName, -1, VipLen)
		wt.ViewHunt = GetDwordPacket(PacketName, -1)
		ClearPacket(PacketName)
		return 
	end
	Console(3, string.format("%s-%s",UserGetName(), CONFIG.PACKET))
end

local TimeToUpdate = 0

function WindowTitleMainProc()

	TimeToUpdate = TimeToUpdate + 1
	if TimeToUpdate > 10 and GetMainScene() == 5 then
		TimeToUpdate = 0

		if(CONFIG.EnableName == 1) then 
			StringWindowTitle = string.format("%s || Character: %s || Level: %s || Resets: %s || VIP: %s || Hunt: %s", CONFIG.ServerName, wt.ViewName, wt.ViewLevel, wt.ViewReset, wt.ViewVip, wt.ViewHunt)
		end
		--Console(3, StringWindowTitle)
		SetWindowTitle(StringWindowTitle)
	end
end


WindowTitle.Init()
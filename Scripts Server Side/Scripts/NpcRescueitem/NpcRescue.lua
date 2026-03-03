local CONFIG = require("Scripts\\NpcRescueitem\\Config")


function GetTick()
    return os.time() * 1000  -- segundos para milissegundos (baixa precisão)
end


BridgeFunctionAttach('OnNpcTalk','NpcRescue_OnNpcTalk')
BridgeFunctionAttach('OnSQLAsyncResult','NpcRescue_OnSQLAsyncResult')

NpcRescueItem = {}

NpcRescueItemPlayers = {}


function NpcRescue_OnNpcTalk(NpcIndex, PlayerIndex)

    local NpcClass = GetObjectClass(NpcIndex)
    local NpcMap   = GetObjectMap(NpcIndex)
    local NpcX     = GetObjectMapX(NpcIndex)
    local NpcY     = GetObjectMapY(NpcIndex)


    if (NpcClass == CONFIG.NPC_RESCUE_MONSTER_ID)
    then
        if (NpcMap == CONFIG.NPC_RESCUE_MONSTER_MAP) 
        then
            if NpcX == CONFIG.NPC_RESCUE_MONSTER_X and NpcY == CONFIG.NPC_RESCUE_MONSTER_Y then
                NpcRescueItem.Open(PlayerIndex, NpcIndex)
                return 1
            end
        end
    end


	return 0
end


function NpcRescueItem.Open(player, npc)

    
    local AccountID = GetObjectAccount(player)

    local retcount = NpcQuant(AccountID)

    ChatTargetSend(npc, player, string.format("Você possui %s Itens guardados", retcount))

    if GetObjectInterface(player) ~= 0 then
        MessageSend(player, 1, 0, string.format(CONFIG.MESSAGES[2][Language]))
        return
    end

    if NpcRescueItemPlayers[player] ~= nil
	then
		local lastTime = math.floor((GetTick() - NpcRescueItemPlayers[player]) / 1000) 
		
		if lastTime <= 5
		then
			--SendMessage(string.format(CONFIG.MESSAGES[2][Language]), player, 1)
            NoticeSend(aIndex, 1, string.format(CONFIG.MESSAGES[2][Language]))
			--ChatTargetSend(npc,player, string.format(CONFIG.MESSAGES[3][Language]))
            ChatTargetSend(npc, player, string.format("Calma ae man"))
			return
		end
	end


    local query = string.format("SELECT top 31 ID,ItemIndex,Level,Option1,Option2,Option3,Exc,Ancient,JoH,SockBonus,Sock1,Sock2,Sock3,Sock4,Sock5,TimeExpire FROM NPC_RESCUE_ITENS WHERE Account='%s' and Delivered=0 and TimeExpire >= GETDATE()", AccountID)
	
    CreateAsyncQuery('PlayerOpenNpcRescue', query, player, 1)

    player = nil

end

function NpcQuant(AccountID)

    local Query = string.format("select count(*) as Total from NPC_RESCUE_ITENS where Account = '%s'", AccountID)

	SQLQuery(Query)

    SQLFetch()

	local str = SQLGetNumber('Total')

	SQLClose()

	return str

end


function NpcRescueItem.InsertItem(Account, Item, Itemlevel, iOp1, iOp2, iOp3, iExc, iAncient, iJoH, iSockCount, iSock1, iSock2, iSock3, iSock4, iSock5, DaysExpire, ItemTimeExpire)
    -- Verifica se ItemTimeExpire é nulo, se for, atribui 0
    if ItemTimeExpire == nil then
        ItemTimeExpire = 0
    end

    -- Chama a função DataBase.InsertNpcRescueItem para inserir o item
    DataBase.InsertNpcRescueItem(Account, Item, Itemlevel, iOp1, iOp2, iOp3, iExc, iAncient, iJoH, iSockCount, iSock1, iSock2, iSock3, iSock4, iSock5, ItemTimeExpire, DaysExpire)
end

function NpcRescue_OnSQLAsyncResult(queryName, identification, aIndex)

if queryName == 'PlayerOpenNpcRescue' then
    if GetObjectConnected(aIndex) ~= 0 then
        local count = 0
        local ItensList = {}

        for n = 1, 31 do 
            local getItemID = tonumber(QueryAsyncGetValue(identification, 'ID'))
            local getItemIndex = tonumber(QueryAsyncGetValue(identification, 'ItemIndex'))
            local getLevel = tonumber(QueryAsyncGetValue(identification, 'Level'))
            local getOp1 = tonumber(QueryAsyncGetValue(identification, 'Option1'))
            local getOp2 = tonumber(QueryAsyncGetValue(identification, 'Option2'))
            local getOp3 = tonumber(QueryAsyncGetValue(identification, 'Option3'))
            local getExc = tonumber(QueryAsyncGetValue(identification, 'Exc'))
            local getAncient = tonumber(QueryAsyncGetValue(identification, 'Ancient'))
            local getJoH = tonumber(QueryAsyncGetValue(identification, 'JoH'))
            local getSockBonus = tonumber(QueryAsyncGetValue(identification, 'SockBonus'))
            local getSock1 = tonumber(QueryAsyncGetValue(identification, 'Sock1'))
            local getSock2 = tonumber(QueryAsyncGetValue(identification, 'Sock2'))
            local getSock3 = tonumber(QueryAsyncGetValue(identification, 'Sock3'))
            local getSock4 = tonumber(QueryAsyncGetValue(identification, 'Sock4'))
            local getSock5 = tonumber(QueryAsyncGetValue(identification, 'Sock5'))
            local getTimeExpire = tostring(QueryAsyncGetValue(identification, 'TimeExpire'))
            
            if getItemID == nil or getItemIndex == nil or getLevel == nil or getTimeExpire == nil
            then
                break
            end

            ItensList[count] = { ItemID = getItemID, ItemIndex = getItemIndex, Level = getLevel
            , Op1 = getOp1, Op2 = getOp2, Op3 = getOp3
            , Exc = getExc, Ancient = getAncient, JoH = getJoH
            , SockBonus = getSockBonus, Sock1 = getSock1, Sock2 = getSock2
            , Sock3 = getSock3, Sock4 = getSock4, Sock5 = getSock5
            , TimeExpire = getTimeExpire }
            
            count = count + 1
        end

        local packetIdentification = string.format('%s-%s', CONFIG.NPC_RESCUE_PACKET_NAME_GET, GetObjectName(aIndex))
        
        CreatePacket(packetIdentification, CONFIG.NPC_RESCUE_PACKET)
        
        SetDwordPacket(packetIdentification, count)

        for i = 0, count do
            if ItensList[i] ~= nil
            then
                SetDwordPacket(packetIdentification, ItensList[i].ItemID)
                SetWordPacket(packetIdentification, ItensList[i].ItemIndex)
                SetBytePacket(packetIdentification, ItensList[i].Level)
                SetBytePacket(packetIdentification, ItensList[i].Op1)
                SetBytePacket(packetIdentification, ItensList[i].Op2)
                SetBytePacket(packetIdentification, ItensList[i].Op3)
                SetBytePacket(packetIdentification, ItensList[i].Exc)
                SetBytePacket(packetIdentification, ItensList[i].Ancient)
                SetBytePacket(packetIdentification, ItensList[i].JoH)
                SetBytePacket(packetIdentification, ItensList[i].SockBonus)
                SetBytePacket(packetIdentification, ItensList[i].Sock1)
                SetBytePacket(packetIdentification, ItensList[i].Sock2)
                SetBytePacket(packetIdentification, ItensList[i].Sock3)
                SetBytePacket(packetIdentification, ItensList[i].Sock4)
                SetBytePacket(packetIdentification, ItensList[i].Sock5)
                SetCharPacketLength(packetIdentification, ItensList[i].TimeExpire, 16)
            end
        end
        
        SendPacket(packetIdentification, aIndex)
        
        ClearPacket(packetIdentification)
    end

    --clear async
    QueryAsyncDelete(identification)
    return 1
elseif queryName == 'PlayerGetItemNpcRescue'
then
    if GetObjectConnected(aIndex) ~= 0
    then
        local getItemID = tonumber(QueryAsyncGetValue(identification, 'ID'))
        local getItemIndex = tonumber(QueryAsyncGetValue(identification, 'ItemIndex'))
        local getLevel = tonumber(QueryAsyncGetValue(identification, 'Level'))
        local getOp1 = tonumber(QueryAsyncGetValue(identification, 'Option1'))
        local getOp2 = tonumber(QueryAsyncGetValue(identification, 'Option2'))
        local getOp3 = tonumber(QueryAsyncGetValue(identification, 'Option3'))
        local getExc = tonumber(QueryAsyncGetValue(identification, 'Exc'))
        local getAncient = tonumber(QueryAsyncGetValue(identification, 'Ancient'))
        local getJoH = tonumber(QueryAsyncGetValue(identification, 'JoH'))
        local getSockBonus = tonumber(QueryAsyncGetValue(identification, 'SockBonus'))
        local getSock1 = tonumber(QueryAsyncGetValue(identification, 'Sock1'))
        local getSock2 = tonumber(QueryAsyncGetValue(identification, 'Sock2'))
        local getSock3 = tonumber(QueryAsyncGetValue(identification, 'Sock3'))
        local getSock4 = tonumber(QueryAsyncGetValue(identification, 'Sock4'))
        local getSock5 = tonumber(QueryAsyncGetValue(identification, 'Sock5'))
        local getItemTimeExpire = QueryAsyncGetValue(identification, 'ItemTimeExpire')

        local Language = GetObjectLanguage(aIndex)

        if getItemID == nil or getItemIndex  == nil or getLevel == nil or getOp1 == nil or getSock3 == nil
        then
            MessageSend(aIndex, 1, 0, string.format(CONFIG.MESSAGES[3][Language]))
            QueryAsyncDelete(identification)
            return 1
        end

        if InventoryCheckSpaceByItem(aIndex, getItemIndex) == 0
        then
            NoticeSend(aIndex, 1, string.format(CONFIG.MESSAGES[4][Language]))
            QueryAsyncDelete(identification)
            return 1
        end

        local query = string.format("UPDATE NPC_RESCUE_ITENS SET Delivered=1,TimeDelivered=GetDate() WHERE Account='%s' and ID='%d'", GetObjectAccount(aIndex), getItemID)
        CreateAsyncQuery('UpdateItemGetNpcRescue', query, -1, 0)

        --CreateItemInventory(aIndex, getItemIndex, getLevel, getOp1, getOp2, getOp3, getExc, getAncient, getJoH, getSockBonus, getSock1, getSock2, getSock3, getSock4, getSock5, getItemTimeExpire)
        ItemGiveEx(aIndex,getItemIndex,getLevel,-1,getOp1,getOp2,getOp3,getExc,getAncient,getJoH,0,getSock1,getSock2,getSock3,getSock4,getSock5,getSockBonus,getItemTimeExpire)

        LogColor(2, string.format('[NPC Rescue] %s - Item Retirado %s', GetObjectAccount(aIndex), getItemIndex ))

        local packetIdentification = string.format('%s-%s', CONFIG.NPC_RESCUE_PACKET_GET_ITEM_RECV, GetObjectName(aIndex))
        
        CreatePacket(packetIdentification, CONFIG.NPC_RESCUE_PACKET)
        
        SetDwordPacket(packetIdentification, getItemID)
        
        SendPacket(packetIdentification, aIndex)
        
        ClearPacket(packetIdentification)
    end

    QueryAsyncDelete(identification)
    return 1
end

return 0

end

function NpcRescueItem.GetItem(player, PacketName)
	local Language = GetObjectLanguage(player)
	
    if GetObjectInterface(player) ~= 0 then
        MessageSend(player, 1, 0, string.format(CONFIG.MESSAGES[2][Language]))
        return
    end
	
	if NpcRescueItemPlayers[player] ~= nil
	then
		local lastTime = math.floor((GetTick() - NpcRescueItemPlayers[player]) / 1000) 
		
		if lastTime <= 2
		then
			return
		end
	end
	
	local ItemID = GetDwordPacket(PacketName, -1)

    --LogColor(3, string.format("DWORD:%s - string:%s",ItemID, PacketName))

	ClearPacket(PacketName)

	local query = string.format("SELECT top 1 ID,ItemIndex,Level,Option1,Option2,Option3,Exc,Ancient,JoH,SockBonus,Sock1,Sock2,Sock3,Sock4,Sock5,ItemTimeExpire FROM NPC_RESCUE_ITENS WHERE Account='%s' and Delivered=0 and ID='%d' and TimeExpire >= GETDATE()", GetObjectAccount(player), ItemID)
	
    CreateAsyncQuery('PlayerGetItemNpcRescue', query, player, 1)
	
	NpcRescueItemPlayers[player] = GetTick()
	
	player = nil
end


function NpcRescueItem.Protocol(aIndex, Packet, PacketName)
	if Packet == CONFIG.NPC_RESCUE_PACKET
	then
		
        --LogColor(1, string.format('%s-%s (Packet: %s)', CONFIG.NPC_RESCUE_PACKET_GET_ITEM_RECV, GetObjectName(aIndex), PacketName))
		if string.format('%s-%s', CONFIG.NPC_RESCUE_PACKET_GET_ITEM_RECV, GetObjectName(aIndex)) == PacketName
		then
			NpcRescueItem.GetItem(aIndex, PacketName)
		end
	end
end

function NpcRescueItem.RunSQL()
	local query = string.format("IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[NPC_RESCUE_ITENS]') AND type in (N'U')) BEGIN CREATE TABLE [dbo].[NPC_RESCUE_ITENS] ([ID] [int] IDENTITY(1,1) NOT NULL,[Account] [varchar](10) NOT NULL,[ItemIndex] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_ItemIndex]  DEFAULT ((0)),[Level] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_Level]  DEFAULT ((0)),[Option1] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_Option1]  DEFAULT ((0)),[Option2] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_Option2]  DEFAULT ((0)),[Option3] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_Option3]  DEFAULT ((0)),[Exc] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_Exc]  DEFAULT ((0)),[Ancient] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_Ancient]  DEFAULT ((0)),[JoH] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_JoH]  DEFAULT ((0)),[SockBonus] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_SockBonus]  DEFAULT ((0)),[Sock1] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_Sock1]  DEFAULT ((0)),[Sock2] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_Sock2]  DEFAULT ((0)),[Sock3] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_Sock3]  DEFAULT ((0)),[Sock4] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_Sock4]  DEFAULT ((0)),[Sock5] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_Sock5]  DEFAULT ((0)), [Delivered] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_Delivered]  DEFAULT ((0)), [ItemTimeExpire] [int] NOT NULL CONSTRAINT [DF_NPC_RESCUE_ITENS_ItemTimeExpire]  DEFAULT ((0)), [TimeExpire] [datetime] NOT NULL, [TimeDelivered] [datetime] NULL ) ON [PRIMARY] END")
	
	SQLQuery(query)
	
	SQLClose()

	DataBase.CreateColumn('NPC_RESCUE_ITENS', 'ItemTimeExpire', "INT NOT NULL DEFAULT 0")
end

function NpcRescueItem.Init()
	if CONFIG.NPC_RESCUE_ITEM_SWITCH == 0
	then
		return
	end

	ProtocolFunctions.GameServerProtocol(NpcRescueItem.Protocol)
    
	Timer.TimeOut(5, NpcRescueItem.RunSQL)

end

NpcRescueItem.Init()
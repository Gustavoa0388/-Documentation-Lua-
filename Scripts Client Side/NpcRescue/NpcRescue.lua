local CONFIG = require("Scripts\\NpcRescue\\Config")
local NpcRescueItem = {}
local NpcRescueItensList = {}

BridgeFunctionAttach('MainProcThread','NpcRescueItemUpdateProc')
BridgeFunctionAttach('MainInterfaceProcThread','NpcRescueItemBeforeInterface')
BridgeFunctionAttach('KeyboardEvent','CloseNpc')
BridgeFunctionAttach('UpdateMouseEvent','NpcRescueClick')
BridgeFunctionAttach('ScrollMouseEvent','NpcRescueScrollMouseEvent')

function NpcRescueScrollMouseEvent(ScrollData)
	NpcRescueItem.ScrollMouse(ScrollData)
end

function NpcRescueClick()
	NpcRescueItem.ScrollBarClick()
end

function CloseNpc(key)
	if CONFIG.NpcRescueVisible == 0
    then
        return
    end

	if(key == Keys.Escape) then
		CONFIG.NpcRescueVisible = 0
		UnlockPlayerWalk()
	end
end

function NpcRescueItem.RenderFrame()

	LockPlayerWalk()

    RenderImage(31322, CONFIG.x, CONFIG.y, 190.0, 429.0)
	RenderImage(31353, CONFIG.x, CONFIG.y, 190.0, 64.0)
	RenderImage(31355, CONFIG.x, CONFIG.y + 64, 21.0, 320.0)
	RenderImage(31356, CONFIG.x + 169, CONFIG.y + 64, 21.0, 320.0)
	RenderImage(31357, CONFIG.x, CONFIG.y + 384, 190.0, 45.0)
 
   --Buttom
    NpcRescueItem.RenderButtom(CONFIG.x + 190/2 - 85/2, CONFIG.y + 185, 100, 30)

    --Box item selected
    NpcRescueItem.RenderBox(CONFIG.x + 45, CONFIG.y + 85, 100, 80, 0)

	--Render Item selected on box
	NpcRescueItem.RenderItemSelected(CONFIG.x + 82, CONFIG.y + 85 + 25)

    --Box itens
    NpcRescueItem.RenderBox(CONFIG.x + 15, CONFIG.y + 230, 160, 160, 1)

	--Render Itens if have
	NpcRescueItem.RenderListItens(CONFIG.x + 20, CONFIG.y + 250)

    --Scroll bar
    NpcRescueItem.RenderScrollBarPage(CONFIG.x + 15, CONFIG.y + 232, 160, 160, 12) --[[]]
end

function NpcRescueItem.RenderScrollBarPage(x, y, width, height, size)
	SetBlend(1)

	glColor4f(1.0, 1.0, 1.0, 1.0)

	RenderImage(31270, x + width - 11, y + 14, 7, 3)
	
	for i = 0, size do
		RenderImage(31271, x + width - 11, (y + 13) + (i * 10 + 4), 7, 15)
	end

	RenderImage(31272, x + width - 11, y + height - 8, 7, 3)

	if MousePosX() >= (x + width - 15) and MousePosX() <= (x + width - 15) + 15
		and MousePosY() >= y + 10 + CONFIG.NpcRescueScrollBarPosY and MousePosY() <= y + 10 + CONFIG.NpcRescueScrollBarPosY + 30
	then
		glColor4f(1.0, 1.0, 1.0, 1.0)
	else
		glColor4f(0.7, 0.7, 0.7, 1.0)
	end

	RenderImage(31273, x + width - 15, y + 10 + CONFIG.NpcRescueScrollBarPosY, 15, 30)
	
	glColor4f(1.0, 1.0, 1.0, 1.0)

	DisableAlphaBlend()
end

function NpcRescueItem.RenderItemSelected(x, y)
	if CONFIG.NpcRescueSelectedItemKey == -1
	then
		return
	end

	local item = NpcRescueItensList[CONFIG.NpcRescueSelectedItemKey]

	if item.ItemIndex >= GET_ITEM(0, 15) and item.ItemIndex < GET_ITEM(5, 0)
	then
		y = y + 17
	end

	if item.ItemIndex >= GET_ITEM(5, 0) and item.ItemIndex < GET_ITEM(6, 0)
	then
		y = y + 10
	end

	CreateItem(x, y, 25, 25, item.ItemIndex, item.Level, 0, 0, 0)
	
end

function NpcRescueItem.RenderDescriptionItemSelected(x, y, width, height)
	if CONFIG.NpcRescueSelectedItemKey == -1
	then
		return
	end

	if MousePosX() > x and MousePosX() < x + width
		and MousePosY() > y and MousePosY() < y + height
	then
		local item = NpcRescueItensList[CONFIG.NpcRescueSelectedItemKey]
		SetBlend(1)

		glColor4f(1.0, 1.0, 1.0, 1.0)

		ShowDescriptionComplete(x-10, y, item.ItemIndex, item.Level, -1, item.Op1, item.Op2, item.Op3, item.Exc, item.Ancient, item.JoH, item.SockCount, item.Sock1, item.Sock2, item.Sock3, item.Sock4, item.Sock5)

		DisableAlphaBlend()
	end
end

function NpcRescueItem.RenderBox(x, y, width, height, title)
	SetBlend(1)
	
	glColor4f(0.0, 0.0, 0.0, 0.3)

	DrawBar(x, y, width, height, 0.0, 0)
	
	glColor4f(0.0, 0.0, 0.0, 0.5)

	DrawBar(x, y, width, height, 0.0, 0)

	if title == 1
	then
		glColor4f(0.3, 0.3, 0.3, 0.7)

		DrawBar(x, y-1, width+1, 15.0, 0.0, 0)
	end
	
	if CONFIG.NpcRescueSelectedItem ~= 0
	then
		glColor4f(0.2, 0.2, 0.2, 0.5)
		DrawBar(x, CONFIG.NpcRescueSelectedItemPosY - 2, width-10, 13, 0.0, 0)
	end
	
	if CONFIG.NpcRescueSelectedItemClicked ~= 0
	then
		glColor4f(0.2, 0.2, 0.2, 0.5)
		DrawBar(x, CONFIG.NpcRescueSelectedItemClickedPosY - 2, width-10, 13, 0.0, 0)
	end
	
	EndDrawBar()
	DisableAlphaBlend()
	
	SetBlend(1)

	RenderImage(31340, x - 4, y - 3, 14.0, 14.0)
	RenderImage(31341, x + width - 9, y - 3, 14.0, 14.0)
	RenderImage(31342, x - 4, y + height - 8, 14.0, 14.0)
	RenderImage(31343, x + width - 9, y + height - 8, 14.0, 14.0)

	for i = (x + 10), x + width - 9, 1
	do
		RenderImage(31344, i, y - 3, 1, 14);
		RenderImage(31345, i, y + height - 8, 1, 14)
	end
	
	for i = y + 11, y + height - 8, 1
	do
		RenderImage(31346, x - 4, i, 14, 1);
		RenderImage(31347, x + width - 9, i, 14, 1)
	end
	
	DisableAlphaBlend()
end

function NpcRescueItem.RenderButtom(x, y, width, height)
    SetBlend(1)
	
	if MousePosX() >= x and MousePosX() <= x + width and MousePosY() >= y and MousePosY() <= y + height
	then
		RenderImage2(31326, x, y, width, height, 0, 0.2264566, 1.0, 0.2245212, 1, 1, 1.0)
		--RenderBitmap(31326, x, y, width, height, 0, 0.2264566, 1.0, 0.2245212, 1, 1, 1.0)
	else
		RenderImage2(31326, x, y, width, height, 0, 0, 1.0, 0.2245212, 1, 1, 1.0)
	end
	
	SetFontType(1)
	SetTextBg(0, 0, 0, 0)
	SetTextColor(216, 216, 216, 255)
	
	local Text = CONFIG.MESSAGES[6][GetLanguage()]
	
	RenderText5(CONFIG.x, y + 8, Text, 190, 3)
	
	DisableAlphaBlend()
end

function NpcRescueItem.RenderListItens(x, y)
	SetBlend(1)

	SetFontType(0)
	SetTextBg(0, 0, 0, 0)
	SetTextColor(225, 225, 225, 255)
	
	local posY = 0
	local line = 0

	for key = 0, #NpcRescueItensList do
		if NpcRescueItensList[key] == nil
		then
			goto continue
		end

		if line >= CONFIG.NpcRescueScrollBarCurrentLine and line <= CONFIG.NpcRescueScrollBarRenderPageMax
		then
			local itens = NpcRescueItensList[key]
		
			local itemName = GetNameByIndex(itens.ItemIndex)

			--local itemName = 'Item: '.. itens.ItemIndex

			RenderText5(x, y + posY, itemName, 155 - #itemName, 1)
			
			posY = posY + 15
		end
		
		line = line + 1

		::continue::
	end
	
	DisableAlphaBlend()
end

function NpcRescueItem.ItemListUpdate()
	
	
	CONFIG.NpcRescueSelectedItem = 0
	local x = CONFIG.x + 20
	local y = CONFIG.y + 250
	local posY = 0
	local line = 0

	for key = 0, #NpcRescueItensList do
		if NpcRescueItensList[key] == nil
		then
			goto continue
		end

		if line >= CONFIG.NpcRescueScrollBarCurrentLine and line <= CONFIG.NpcRescueScrollBarRenderPageMax
		then
			if MousePosX() >= x and MousePosX() <= x + 130
			then
				if MousePosY() >= (y + posY) and MousePosY() <= (y + posY) + 10
				then
					if CheckPressedKey(Keys.LButton) == 1
					then
						CONFIG.NpcRescueSelectedItemKey = key
						CONFIG.NpcRescueSelectedItemClicked = 1
						CONFIG.NpcRescueSelectedItemClickedPosY = (y + posY)
						DisableClickClient()
					end
					
					CONFIG.NpcRescueSelectedItem = 1
					CONFIG.NpcRescueSelectedItemPosY = (y + posY)
				end
			end
			
			posY = posY + 15
		end
		
		line = line + 1

		::continue::
	end
end

function NpcRescueItem.ScrollBarClick()
	if CheckRepeatKey(Keys.LButton) == 1
	then
		if MousePosX() >= CONFIG.x + 150 and MousePosX() <= CONFIG.x + 190
		then
			local value = MousePosY() - CONFIG.NpcRescueScrollBarPosMouse
			
			if value < 0
			then
				if (MousePosY() <= (CONFIG.y + 225 + CONFIG.NpcRescueScrollBarPosY) + 15)
				then
					NpcRescueItem.ScrollingBar(-1)
				end
			elseif value > 0
			then
				if (MousePosY() >= (CONFIG.y + 225 + CONFIG.NpcRescueScrollBarPosY) + 15)
				then
					NpcRescueItem.ScrollingBar(1)
				end
			end
			
			CONFIG.NpcRescueScrollBarPosMouse = MousePosY()
		end
	end
end

function NpcRescueItem.ScrollingBar(value)
	if value > 0
	then
		if (CONFIG.NpcRescueScrollBarRenderPageMax < (CONFIG.NpcRescueScrollBarRenderMaxLines))
		then
			CONFIG.NpcRescueScrollBarRenderPageMax = CONFIG.NpcRescueScrollBarRenderPageMax + 1
			CONFIG.NpcRescueScrollBarCurrentLine = CONFIG.NpcRescueScrollBarCurrentLine + 1
			CONFIG.NpcRescueScrollBarPosY = CONFIG.NpcRescueScrollBarPosY + CONFIG.NpcRescueScrollBarPosYMultiplier
		end
	elseif value < 0
	then
		if (CONFIG.NpcRescueScrollBarRenderPageMax > CONFIG.NpcRescueScrollMaxLine)
		then
			CONFIG.NpcRescueScrollBarRenderPageMax = CONFIG.NpcRescueScrollBarRenderPageMax - 1
			CONFIG.NpcRescueScrollBarCurrentLine = CONFIG.NpcRescueScrollBarCurrentLine - 1
			CONFIG.NpcRescueScrollBarPosY = CONFIG.NpcRescueScrollBarPosY - CONFIG.NpcRescueScrollBarPosYMultiplier
		end
	end
end

function NpcRescueItem.CalcScrollBar()
	CONFIG.NpcRescueScrollBarPosY = 0
	CONFIG.NpcRescueScrollBarPosMouse = 0
	CONFIG.NpcRescueScrollBarCurrentLine = 0
	CONFIG.NpcRescueScrollBarRenderMaxLines = CONFIG.NpcRescueItemCount
	CONFIG.NpcRescueScrollMaxLine = CONFIG.NpcRescueScrollBarMaxLines
	CONFIG.NpcRescueScrollBarPosYMultiplier = (125 / (CONFIG.NpcRescueItemCount - CONFIG.NpcRescueScrollBarMaxLines))
	CONFIG.NpcRescueScrollBarRenderPageMax = CONFIG.NpcRescueScrollBarMaxLines
end

function NpcRescueItem.RenderText()
    SetBlend(1)

    SetFontType(1)
	
	SetTextBg(0, 0, 0, 0)
	
	SetTextColor(216, 216, 216, 255)

	RenderText5(CONFIG.x, CONFIG.y + 11, CONFIG.MESSAGES[1][GetLanguage()], 190, 3)

	SetFontType(0)

	if CONFIG.NpcRescueSelectedItemKey ~= -1
	then
		RenderText5(CONFIG.x + 20, CONFIG.y + 50, CONFIG.MESSAGES[2][GetLanguage()], 170, 1)
		SetFontType(1)
		RenderText5(CONFIG.x + 150, CONFIG.y + 50, string.format('%s', NpcRescueItensList[CONFIG.NpcRescueSelectedItemKey].TimeExpire), 150, 7)
		SetFontType(0)
	end

	RenderText5(CONFIG.x, CONFIG.y + 70, CONFIG.MESSAGES[3][GetLanguage()], 190, 3) -- string.format(CONFIG.MESSAGES[1][GetLanguage()])

	SetFontType(1)

	RenderText5(CONFIG.x + 20, CONFIG.y + 232, CONFIG.MESSAGES[4][GetLanguage()], 160, 1)

    if CONFIG.NpcRescueItemCount <= 0
    then
        SetTextBg(0, 0, 0, 0)
        SetTextColor(255, 255, 255, 255)
        RenderText5(CONFIG.x + 20, CONFIG.y + 255, CONFIG.MESSAGES[5][GetLanguage()], 170, 1)
    end

    DisableAlphaBlend()
end

function NpcRescueItemBeforeInterface()
	if CONFIG.NpcRescueVisible == 0
    then
        return
    end

    SetBlend(1)

    NpcRescueItem.RenderFrame()

    NpcRescueItem.RenderText()

	--Render Description Item selected if mouse on
	NpcRescueItem.RenderDescriptionItemSelected(CONFIG.x + 60, CONFIG.y + 85, 75, 75)

    DisableAlphaBlend()
end

function NpcRescueItemUpdateProc()
	if CONFIG.NpcRescueVisible == 0
    then
        return 
	end

	if CheckWindowOpen(UIExpandInventory) == 1
	then
		if GetWideX() == 640 then
			CONFIG.x = 70
			Console(2, CONFIG.x)
		else
			CONFIG.x = 747-273-190
		end
	else
		if GetWideX() == 640 then
			CONFIG.x = 260
		else
			CONFIG.x = 747-273
		end
	end

	if CheckWindowOpen(UIInventory) == 0 then 
		CONFIG.NpcRescueVisible = 0
	end

	if MousePosX() >= CONFIG.x + (190/2 - 85/2) and MousePosX() <= CONFIG.x + (190/2 - 85/2) + 80 and MousePosY() >= CONFIG.y + CONFIG.y + 185 and MousePosY() <= CONFIG.y + CONFIG.y + 185 + 32
	then
		if CheckPressedKey(Keys.LButton) == 1
		then
			if CONFIG.NpcRescueSelectedItemKey ~= -1
			then
				NpcRescueItem.SendGetItem(NpcRescueItensList[CONFIG.NpcRescueSelectedItemKey].ID)
			end

			--DisableClickClient()
		end
	end

	NpcRescueItem.ItemListUpdate()
	NpcRescueItem.ForceClose()
end

function NpcRescueItem.UpdateMouse()
	if CONFIG.NpcRescueVisible == 0
    then
        return
    end

	NpcRescueItem.ScrollBarClick()

	if MousePosX() >= CONFIG.x and MousePosX() <= CONFIG.x + 190
	then
		if MousePosY() >= CONFIG.y + 0 and MousePosY() <= CONFIG.y + 430
		then
			if (CheckClickClient() == 1)
			then
				--DisableClickClient()
			end
		end
	end
end

function NpcRescueItem.ScrollMouse(value)
    if CONFIG.NpcRescueVisible == 0
    then
        return
    end

	if MousePosX() >= CONFIG.x and MousePosX() <= CONFIG.x + 190
	then
		if MousePosY() >= CONFIG.y + 220 and MousePosY() <= CONFIG.y + 400
		then
			if value > 0
			then
				NpcRescueItem.ScrollingBar(-1)
			end
			
			if value < 0
			then
				NpcRescueItem.ScrollingBar(1)
			end
		end
	end
end

function NpcRescueItem.DeleteItem(ItemId)
	for i = 0, 32 do
		
		if NpcRescueItensList[i] ~= nil
		then
			if NpcRescueItensList[i].ID == ItemId
			then
				NpcRescueItensList[i] = nil
				CONFIG.NpcRescueItemCount = CONFIG.NpcRescueItemCount - 1
				CONFIG.NpcRescueSelectedItemKey = -1
				CONFIG.NpcRescueSelectedItem = 0
				CONFIG.NpcRescueSelectedItemClicked = 0
				CONFIG.NpcRescueSelectedItemPosY = 0

				NpcRescueItem.CalcScrollBar()
				return
			end
		end
	end
end

function NpcRescueItem.CloseInterface()

		if	CheckWindowOpen(UIFriendList) 		== 1	then	CloseWindow(UIFriendList)	end
		if	CheckWindowOpen(UIMoveList)			== 1	then	CloseWindow(UIMoveList)	end
		if	CheckWindowOpen(UIParty) 			== 1	then	CloseWindow(UIParty)	end
		if	CheckWindowOpen(UIQuest) 			== 1	then	CloseWindow(UIQuest)	end
		if	CheckWindowOpen(UIGuild) 			== 1	then	CloseWindow(UIGuild)	end
		if	CheckWindowOpen(UIGuildNpc) 		== 1	then	CloseWindow(UIGuildNpc)	end
		if	CheckWindowOpen(UITrade) 			== 1	then	CloseWindow(UITrade)	end
		if	CheckWindowOpen(UIWarehouse) 		== 1	then	CloseWindow(UIWarehouse)	end
		if	CheckWindowOpen(UICommandWindow) 	== 1	then	CloseWindow(UICommandWindow)	end
		if	CheckWindowOpen(UIPetInfo)	 		== 1	then	CloseWindow(UIPetInfo)	end
		if	CheckWindowOpen(UIShop)				== 1	then	CloseWindow(UIShop)	end
		if	CheckWindowOpen(UIStore)			== 1	then	CloseWindow(UIStore)	end
		if	CheckWindowOpen(UIOtherStore) 		== 1	then	CloseWindow(UIOtherStore)	end
		if	CheckWindowOpen(UICharacter) 		== 1	then	CloseWindow(UICharacter)	end
		if	CheckWindowOpen(UIOptions) 			== 1	then	CloseWindow(UIOptions)	end
		if	CheckWindowOpen(UIHelp)				== 1	then	CloseWindow(UIHelp)	end
		if	CheckWindowOpen(UIFastDial)			== 1	then	CloseWindow(UIFastDial)	end
		if	CheckWindowOpen(UISkillTree) 		== 1	then	CloseWindow(UISkillTree)	end
		if	CheckWindowOpen(UINPC_Titus) 		== 1	then	CloseWindow(UINPC_Titus)	end
		if	CheckWindowOpen(UICashShop)			== 1	then	CloseWindow(UICashShop)	end
		if	CheckWindowOpen(UIFullMap) 			== 1	then	CloseWindow(UIFullMap)	end
		if	CheckWindowOpen(UINPC_Dialog)		== 1	then	CloseWindow(UINPC_Dialog)	end
		if	CheckWindowOpen(UIGensInfo)			== 1	then	CloseWindow(UIGensInfo)	end
		if	CheckWindowOpen(UINPC_Julia)		== 1	then	CloseWindow(UINPC_Julia)	end
end

function NpcRescueItem.ForceClose()

	if	CheckWindowOpen(UIFriendList) 		== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIMoveList)			== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIParty) 			== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIQuest) 			== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIGuild) 			== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIGuildNpc) 		== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UITrade) 			== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIWarehouse) 		== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UICommandWindow) 	== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIPetInfo)	 		== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIShop)				== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIStore)			== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIOtherStore) 		== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UICharacter) 		== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIOptions) 			== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIHelp)				== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIFastDial)			== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UISkillTree) 		== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UINPC_Titus) 		== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UICashShop)			== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIFullMap) 			== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UINPC_Dialog)		== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UIGensInfo)			== 1	then	CONFIG.NpcRescueVisible = 0	end
	if	CheckWindowOpen(UINPC_Julia)		== 1	then	CONFIG.NpcRescueVisible = 0	end
end

function NpcRescueItem.InsertItem(ItemId, Item, Itemlevel, iOp1, iOp2, iOp3, iExc, iAncient, iJoH, iSockCount, iSock1, iSock2, iSock3, iSock4, iSock5, iTimeExpire)

	for i = 0, 32 do
		if NpcRescueItensList[i] == nil
		then
			NpcRescueItensList[i] = { ID = ItemId, ItemIndex = Item, Level = Itemlevel, Op1 = iOp1, Op2 = iOp2, Op3 = iOp3, Exc = iExc
			, Ancient = iAncient, JoH = iJoH, SockCount = iSockCount, Sock1 = iSock1, Sock2 = iSock2, Sock3 = iSock3, Sock4 = iSock4, Sock5 = iSock5, TimeExpire = iTimeExpire }
			return
		end
	end
end

function NpcRescueItem.Open(packet)
	NpcRescueItensList = nil
	NpcRescueItensList = {}

	local count = GetDwordPacket(packet, -1)

	if count > 0
	then
		for i = 0, (count-1) do
			ItemID = GetDwordPacket(packet, -1)
			ItemIndex = GetWordPacket(packet, -1)
			Level = GetBytePacket(packet, -1)
			Op1 = GetBytePacket(packet, -1)
			Op2 = GetBytePacket(packet, -1)
			Op3 = GetBytePacket(packet, -1)
			Exc = GetBytePacket(packet, -1)
			Ancient = GetBytePacket(packet, -1)
			JoH = GetBytePacket(packet, -1)
			SockBonus = GetBytePacket(packet, -1)
			Sock1 = GetBytePacket(packet, -1)
			Sock2 = GetBytePacket(packet, -1)
			Sock3 = GetBytePacket(packet, -1)
			Sock4 = GetBytePacket(packet, -1)
			Sock5 = GetBytePacket(packet, -1)
			TimeExpire = GetCharPacketLength(packet, -1, 16)

			NpcRescueItem.InsertItem(ItemID, ItemIndex, Level, Op1, Op2, Op3, Exc, Ancient, JoH, SockBonus, Sock1, Sock2, Sock3, Sock4, Sock5, TimeExpire)


	end
	end

	NpcRescueItem.CloseInterface()

	CONFIG.NpcRescueItemCount = count
	CONFIG.NpcRescueSelectedItemKey = -1
	CONFIG.NpcRescueSelectedItem = 0
	CONFIG.NpcRescueVisible = 1

	NpcRescueItem.CalcScrollBar()

	SetLockInterfaces()

	OpenWindow(UIInventory)
end

function NpcRescueItem.SendGetItem(ItemID)
	if CONFIG.NpcRescueVisible == 0
    then
        return
    end

	local packetIdentification = string.format('%s-%s', CONFIG.NPC_RESCUE_PACKET_GET_ITEM_RECV, UserGetName())

	CreatePacket(packetIdentification, CONFIG.NPC_RESCUE_PACKET)
	
	SetDwordPacket(packetIdentification, ItemID)
	
	SendPacket(packetIdentification)
	
	ClearPacket(packetIdentification)

end

function NpcRescueItem.Init()
	NpcRescueItem.CalcScrollBar()

	NpcRescueItensList = nil
	NpcRescueItensList = {}

	ProtocolFunctions.ClientProtocol(NpcRescueItem.Protocol)
end

function NpcRescueItem.Protocol(Packet, PacketName)

		if Packet == CONFIG.NPC_RESCUE_PACKET
	then
		if string.format('%s-%s', CONFIG.NPC_RESCUE_PACKET_NAME_GET, UserGetName()) == PacketName
		then
			NpcRescueItem.Open(PacketName)
			ClearPacket(PacketName)
			return
		end

		if string.format('%s-%s', CONFIG.NPC_RESCUE_PACKET_GET_ITEM_RECV, UserGetName()) == PacketName
		then
			NpcRescueItem.DeleteItem(GetDwordPacket(PacketName, -1))
			ClearPacket(PacketName)
			return
		end
	end

end


NpcRescueItem.Init()


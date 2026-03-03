local CONFIG = require("Scripts\\PackageShop\\Config")
BridgeFunctionAttach('MainInterfaceProcThread','PackageLoad')
BridgeFunctionAttach('KeyboardEvent','PackageKey')
BridgeFunctionAttach('UpdateMouseEvent','PackageClick')

local pShop = {}

pShop.Open = 0

local posx = 0
local posy = 0
local size = 250
local page = 0
local maxpage = 0
local Width = 0


local ItemName = ""
local Valor = 0
local meusaldo = 0

local SlotPet = 0
local SlotWing = 0
local SlotLWeapon = 0
local SlotRWeapon = 0

local SlotHelm = 0
local SlotArmor = 0
local SlotGloves = 0
local SlotPants = 0
local SlotBoots = 0

local SlotPendant = 0
local SlotRing = 0



function PackageLoad()

	if pShop.Open == 0
    then
		--UnlockPlayerWalk()
        return
    end

    if GetWideX() ~= 640 then
        Width = 840 
    else 
        Width = 640
    end

	LockPlayerWalk()
	SetLockInterfaces()
	
	SetBlend(1)

	glColor4f(1.0, 1.0, 1.0, 1.0)

	posx = (Width/2) - (size/2)
	posy = 50

    
    Console(0, string.format('posx: %s / Width: %s',posx, Width))

	pShop.RenderBack(posx, posy)
	pShop.RenderBtn(posx, posy)
	pShop.Text(posx+2, posy)
	pShop.RenderSlot(posx, posy)


	DisableAlphaBlend()
end

function PackageKey(KeyNumber)
	if KeyNumber == Keys.Escape
	then
        local packetInformation = string.format('%s-%s', PacketNameClose, UserGetName())
        CreatePacket(packetInformation, CONFIG.Packet)
        SendPacket(packetInformation, aIndex)
        ClearPacket(packetInformation)

		pShop.Open = 0
		page = 0
		UnlockPlayerWalk()

        return
	end
end

function PackageClick()

    if pShop.Open == 0 then return end

	posx = (Width/2) - (size/2)
	posy = 50

	local nx = posx+40
	local ny = posy

	-- Left Page
	if CheckPressedKey(Keys.LButton) == 1
	then
		if pShop.CheckMouseIn(nx-30, ny+158, 17, 18) == 1
		then
			page = page - 1
			if page < 0 then page = 0 end

			Console(3, string.format("Pagina: %s", page))

			local packetInformation = string.format("%s-%s-%s", CONFIG.PacketSlide, CONFIG.Packet, UserGetName())
			CreatePacket(packetInformation, CONFIG.Packet)
			SetBytePacket(packetInformation, page)
			SendPacket(packetInformation,aIndex)
			ClearPacket(packetInformation)

		end
	end

	-- Right Page
	if CheckPressedKey(Keys.LButton) == 1
	then
		if pShop.CheckMouseIn(nx+size-65, ny+158, 17, 18) == 1
		then
			page = page + 1
			if page > maxpage then page = maxpage end

			Console(2, string.format("Pagina: %s", page))

			local packetInformation = string.format("%s-%s-%s", CONFIG.PacketSlide, CONFIG.Packet, UserGetName())
			CreatePacket(packetInformation, CONFIG.Packet)
			SetBytePacket(packetInformation, page)
			SendPacket(packetInformation,aIndex)
			ClearPacket(packetInformation)
		end
	end

	--Button Buy
	if CheckPressedKey(Keys.LButton) == 1
	then
		if pShop.CheckMouseIn(posx + (size/4) , ny+300, size/2, 25) == 1
		then
			
			local packetInformation = string.format("%s-%s-%s", CONFIG.Packet, CONFIG.PacketBuy, UserGetName())
			CreatePacket(packetInformation, CONFIG.Packet)
			SetBytePacket(packetInformation, page)
			SendPacket(packetInformation,aIndex)
			ClearPacket(packetInformation)

			Console(2, string.format("Buy: Click Page %s [%s]", page, packetInformation))


		end
	end

end

function pShop.Text(x, y)

	SetFontType(1)

	--Title Shop Shadow
	SetTextBg(0, 0, 0, 0)
	SetTextColor(0, 0, 0, 255)
	RenderText(x+1, y+11, "PACKAGE SHOP", size, 3)

	--Title Shop Font White
	SetTextBg(0, 0, 0, 0)
	SetTextColor(255, 255, 255, 255)
	RenderText(x, y+10, "PACKAGE SHOP", size, 3)

	--Title Package
	SetTextBg(0, 0, 0, 0)
	SetTextColor(255, 255, 255, 255)
	RenderText(x, y+35, string.format('(%s) - %s',page, ItemName), size, 3)

	--Title Package
	SetTextBg(0, 0, 0, 0)
	SetTextColor(255, 255, 255, 255)
	RenderText(x, y+282, string.format("Preço: %s FCoin's", Valor), size, 3)

	--Button Buy Package
	SetTextBg(0, 0, 0, 0)
	SetTextColor(255, 255, 255, 255)
	RenderText(x, y+305, "Comprar", size, 3)

	--Saldo Package
	SetTextBg(0, 0, 255, 255)
	SetTextColor(255, 0, 255, 255)
	RenderText(x, y+330, string.format("Seu saldo: %s FCoin's", GetCoin1()), size, 3)

end

function pShop.RenderBack(x, y)

	-- BACKGROUND
	glColor4f(0.0, 0.0, 0.0, 0.80);
	DrawBar(x, y, size, size+100)

	-- RED TITLE
	glColor4f(1.0, 0.0, 0.0, 1.0);
	DrawBar(x+5, y+5, size-10, 25)

	-- BLUE SUB TITLE
	glColor4f(0.0, 0.0, 1.0, 1.0);
	DrawBar(x+5, y+35, size-10, 10)

	-- GREEN PRICE
	glColor4f(0.0, 0.5, 0.0, 1.0);
	DrawBar(x+5, y+282, size-10, 10)

	-- BROWN BUY
	local btnBuy = pShop.CheckMouseIn(x + (size/4),y+300,size/2,25)

	if btnBuy == 1 then 
		glColor4f(1.0, 0.0, 0.0, 1.0); 
	else
		glColor4f(0.55, 0.0, 0.0, 1.0);
	end

	DrawBar(x + (size/4) , y+300, size/2, 25)

	EndDrawBar()
	

end

function pShop.RenderSlot(x,y)

	local nx = x+40
	local ny = y

if SlotPet ~= -1 then
	RenderImage(31360, nx+10, ny+50, 46, 46) -- Pet
	CreateItem(nx+10, ny+50, 46, 46, SlotPet, 0, 0, 0, 0)
end

if SlotHelm ~= -1 then
	RenderImage(31359, nx+66, ny+50, 46, 46) -- Helm
	CreateItem(nx+66, ny+50, 46, 46, SlotHelm, 13, 0, 63, 0)
end

if SlotWing ~= -1 then
	RenderImage(31361, nx+122, ny+50, 66, 46) -- Wing
	CreateItem(nx+122, ny+50, 66, 46, SlotWing, 13, 0, 63, 0)
end

if SlotLWeapon ~= -1 then
	RenderImage(31362, nx+10, ny+106, 46, 66) -- Weapon L
	CreateItem(nx+10, ny+106, 46, 66, SlotLWeapon, 13, 0, 63, 0)
end

if SlotArmor ~= -1 then
	RenderImage(31364, nx+66, ny+106, 46, 66) -- Armor 
	CreateItem(nx+66, ny+106, 46, 66, SlotArmor, 13, 0, 63, 0)
end

if SlotRWeapon ~= -1 then
	RenderImage(31363, nx+122, ny+106, 46, 66) -- Weapon R
	CreateItem(nx+122, ny+106, 46, 66, SlotRWeapon, 13, 0, 63, 0)
end

if SlotGloves ~= -1 then
	RenderImage(31365, nx+10, ny+182, 46, 46) -- Gloves
	CreateItem(nx+10, ny+182, 46, 46, SlotGloves, 13, 0, 63, 0)
end

if SlotPants ~= -1 then
	RenderImage(31366, nx+66, ny+182, 46, 46) -- Pants
	CreateItem(nx+66, ny+182, 46, 46, SlotPants, 13, 0, 63, 0)
end

if SlotBoots ~= -1 then
	RenderImage(31358, nx+122, ny+182, 46, 46) -- Boots
	CreateItem(nx+122, ny+182, 46, 46, SlotBoots, 13, 0, 63, 0)
end

if SlotPendant ~= -1 then
	RenderImage(31368, nx+10, ny+238, 28, 28) -- Pendant
	CreateItem(nx+10, ny+238, 28, 28, SlotPendant, 13, 0, 63, 0)
end

if SlotRing ~= -1 then
	RenderImage(31367, nx+66, ny+238, 28, 28) -- Ring
	CreateItem(nx+66, ny+238, 28, 28, SlotRing, 13, 0, 63, 0)

	RenderImage(31367, nx+122, ny+238, 28, 28) -- Ring
	CreateItem(nx+122, ny+238, 28, 28, SlotRing, 13, 0, 63, 0)
end


	pShop.RenderDesc(nx+10, ny+50, 46, 46, SlotPet, 0, 0, 0) 			-- Slot Pet
	pShop.RenderDesc(nx+66, ny+50, 46, 46, SlotHelm, 15, 0, 63) 		-- Slot helm
	pShop.RenderDesc(nx+122, ny+50, 66, 46, SlotWing, 15, 0, 15) 		-- Slot Wing


	if SlotLWeapon >= GET_ITEM(5,0) and SlotLWeapon <= GET_ITEM(5,511) then
		pShop.RenderDesc(nx+10, ny+106, 46, 66, SlotLWeapon, 15, 0, 63) 	-- Slot Left Weapon
	elseif SlotLWeapon >= GET_ITEM(6,0) then
		pShop.RenderDesc(nx+10, ny+106, 46, 66, SlotLWeapon, 15, 0, 63) 	-- Slot Left Weapon
	else
		pShop.RenderDesc(nx+10, ny+106, 46, 66, SlotLWeapon, 15, 0, 63) 	-- Slot Left Weapon
	end

	pShop.RenderDesc(nx+66, ny+106, 46, 66, SlotArmor, 15, 0, 63) 	-- Slot Armor

	if SlotRWeapon >= GET_ITEM(5,0) and SlotRWeapon <= GET_ITEM(5,511) then
		pShop.RenderDesc(nx+122, ny+106, 46, 66, SlotRWeapon, 15, 0, 63) 	-- Slot Right Weapon
	elseif SlotRWeapon >= GET_ITEM(6,0) then
		pShop.RenderDesc(nx+122, ny+106, 46, 66, SlotRWeapon, 15, 0, 63) 	-- Slot Right Weapon
	else
		pShop.RenderDesc(nx+122, ny+106, 46, 66, SlotRWeapon, 15, 0, 63) 	-- Slot Right Weapon
	end

	pShop.RenderDesc(nx+10, ny+182, 46, 46, SlotGloves, 15, 0, 63) 	-- Slot Gloves
	pShop.RenderDesc(nx+66, ny+182, 46, 46, SlotPants, 15, 0, 63) 	-- Slot Pants
	pShop.RenderDesc(nx+122, ny+182, 46, 46, SlotBoots, 15, 0, 63) 	-- Slot Boots
	pShop.RenderDesc(nx+10, ny+238, 28, 28, SlotPendant, 15, 0, 63) 	-- SLot Pendant
	pShop.RenderDesc(nx+66, ny+238, 28, 28, SlotRing, 15, 0, 63) 		-- Slot Ring L
	pShop.RenderDesc(nx+122, ny+238, 28, 28, SlotRing, 15, 0, 63) 		-- Slot Ring R

end

function pShop.RenderBtn(x,y)
	local nx = x+40
	local ny = y

	RenderImage(31658, nx-30, ny+158, 17, 18) -- Btn L
	RenderImage(31659, nx+size-65, ny+158, 17, 18) -- Btn R
end

function pShop.CheckMouseIn(x, y, w, h)


	if MousePosX() >= x and MousePosX() <= x+w and MousePosY() >= y and MousePosY() <= y+h then
		return 1
	else
		return 0
	end

end

function pShop.RenderDesc(x, y, w, h, itemid, level, joh, exc)
	if MousePosX() >= x and MousePosX() <= x+w and MousePosY() >= y and MousePosY() <= y+h then
		return ShowDescriptionComplete(MousePosX()-50, MousePosY(), itemid, level, -1, 1, 1, 7, exc, 0, joh, 0, 255, 255, 255, 255, 255)
	end
end

function pShop.init()
	ProtocolFunctions.ClientProtocol(pShop.Protocol)
end

function pShop.Protocol(Packet, PacketName)

	if Packet == CONFIG.Packet
	then
		if string.format('%s-%s', CONFIG.PacketName, CONFIG.Packet) == PacketName
		then
			pShop.Open = 1
			maxpage = GetBytePacket(PacketName, -1)
			ClearPacket(PacketName)
			return
		end

		if string.format('%s-%s', CONFIG.PacketSlide, UserGetName()) == PacketName
		then
			 local TitleLen = GetBytePacket(PacketName, -1) 
			 ItemName 		= GetCharPacketLength(PacketName, -1, TitleLen)

			 Valor 			= GetDwordPacket(PacketName, -1)
			 SlotPet 		= GetDwordPacket(PacketName, -1)
			 SlotWing 		= GetDwordPacket(PacketName, -1)
			 SlotLWeapon 	= GetDwordPacket(PacketName, -1)
			 SlotRWeapon 	= GetDwordPacket(PacketName, -1)
			 SlotHelm 		= GetDwordPacket(PacketName, -1)
			 SlotArmor 		= GetDwordPacket(PacketName, -1)
			 SlotGloves 	= GetDwordPacket(PacketName, -1)
			 SlotPants 		= GetDwordPacket(PacketName, -1)
			 SlotBoots 		= GetDwordPacket(PacketName, -1)
			 SlotPendant 	= GetDwordPacket(PacketName, -1)
			 SlotRing 		= GetDwordPacket(PacketName, -1)

			ClearPacket(PacketName)

			return
		end

	end



end

pShop.init()
local CONFIG = require('Scripts\\PackageShop\\Config')

local pShop = {}

pShop.Open = false

pShop.Page = 0


BridgeFunctionAttach('OnCommandManager', 'CommandOpen')


function CommandOpen(aIndex, Arguments)


local Command = CommandGetArgString(Arguments, 0)

if not (Command == CONFIG.Command) then
    return 0
end


if CONFIG.Active == false then return 0 end

pShop.Open = true

local packetInformation = string.format("%s-%s", CONFIG.PacketName, CONFIG.Packet)

CreatePacket(packetInformation, CONFIG.Packet)
SetBytePacket(packetInformation, #CONFIG.Packages)
SendPacket(packetInformation,aIndex)
ClearPacket(packetInformation)

pShop.SendVisual(aIndex, 0)

LogColor(3, string.format('%s - %s - %s', pShop.Open, Command, packetInformation))



end


function pShop.Protocol(aIndex, Packet, PacketName)
	if Packet == CONFIG.Packet
	then
        if string.format('%s-%s-%s', CONFIG.Packet,CONFIG.PacketBuy, GetObjectName(aIndex)) == PacketName
		then
			pShop.Page = GetBytePacket(PacketName, -1)
            ClearPacket(PacketName)
            pShop.CommandBuy(aIndex, pShop.Page)
            return
		end

        if string.format('%s-%s-%s', CONFIG.PacketSlide, CONFIG.Packet, GetObjectName(aIndex)) == PacketName
		then
			pShop.Page = GetBytePacket(PacketName, -1)
            ClearPacket(PacketName)
            pShop.SendVisual(aIndex, pShop.Page)
            LogColor(1, string.format('Page: %s', pShop.Page))
            return
		end

       if string.format('%s-%s', PacketNameClose, GetObjectName(aIndex)) == PacketName 
       then
            pShop.Open = false
            ClearPacket(PacketName)
            return
       end
    return
	end
end


function pShop.SendVisual(aIndex, slide)

    
    local packetIdentification = string.format('%s-%s', CONFIG.PacketSlide, GetObjectName(aIndex))
    
    CreatePacket(packetIdentification, CONFIG.Packet)

    SetBytePacket(packetIdentification, string.len(CONFIG.Packages[slide].Name))
    SetCharPacketLength(packetIdentification, CONFIG.Packages[slide].Name, string.len(CONFIG.Packages[slide].Name))
    SetDwordPacket(packetIdentification, CONFIG.Packages[slide].Valor)

    SetDwordPacket(packetIdentification, CONFIG.Packages[slide].SlotPet)
    SetDwordPacket(packetIdentification, CONFIG.Packages[slide].SlotWing)
    SetDwordPacket(packetIdentification, CONFIG.Packages[slide].SlotLWeapon)
    SetDwordPacket(packetIdentification, CONFIG.Packages[slide].SlotRWeapon)
    SetDwordPacket(packetIdentification, CONFIG.Packages[slide].SlotHelm)
    SetDwordPacket(packetIdentification, CONFIG.Packages[slide].SlotArmor)
    SetDwordPacket(packetIdentification, CONFIG.Packages[slide].SlotGloves)
    SetDwordPacket(packetIdentification, CONFIG.Packages[slide].SlotPants)
    SetDwordPacket(packetIdentification, CONFIG.Packages[slide].SlotBoots)
    SetDwordPacket(packetIdentification, CONFIG.Packages[slide].SlotPendant)
    SetDwordPacket(packetIdentification, CONFIG.Packages[slide].SlotRing)




    LogColor(1, CONFIG.Packages[slide].SlotPet)
    LogColor(1, CONFIG.Packages[slide].SlotWing)
    LogColor(1, CONFIG.Packages[slide].SlotLWeapon)
    LogColor(1, CONFIG.Packages[slide].SlotRWeapon)
    LogColor(1, CONFIG.Packages[slide].SlotHelm)
    LogColor(1, CONFIG.Packages[slide].SlotArmor)
    LogColor(1, CONFIG.Packages[slide].SlotGloves)
    LogColor(1, CONFIG.Packages[slide].SlotPants)
    LogColor(1, CONFIG.Packages[slide].SlotBoots)
    LogColor(1, CONFIG.Packages[slide].SlotPendant)
    LogColor(1, CONFIG.Packages[slide].SlotRing)


    SendPacket(packetIdentification, aIndex)
    
    ClearPacket(packetIdentification)

end

function pShop.CommandBuy(aIndex, page)

    local GetCoin = DataBase.GetValue('CashShopData', 'WCoinC', 'AccountID', GetObjectAccount(aIndex))

    local id = CONFIG.Packages[page]

    if GetCoin < CONFIG.Packages[page].Valor then
        MessageSend(aIndex,1,0,string.format('[PACKAGE] %s - Você precisa ter %d FCoins', GetObjectAccount(aIndex), CONFIG.Packages[page].Valor))
        LogColor(3, string.format('[PACKAGE] %s - Você precisa ter %d FCoins', GetObjectAccount(aIndex), CONFIG.Packages[page].Valor))
        return 0
    end

    ObjectSubCoin(aIndex,id.Valor,0,0)
    
    LogColor(3, string.format('[PACKAGE] %s - Comprou o Pacote %s', GetObjectAccount(aIndex), page))
    MessageSend(aIndex,1,0,string.format('[PACKAGE] %s - Comprou o Pacote %s', GetObjectAccount(aIndex), page))
    MessageSend(aIndex,1,0,string.format('[PACKAGE] Retire seu pacote no Npc Rescue Item', GetObjectAccount(aIndex), page))

    if CONFIG.Debug ~= true
    then
        DataBase.Package('ww_package', GetObjectAccount(aIndex), page, CONFIG.Packages[page].Valor)
    end

    iJoH = 0

    if id.SlotArmor ~= -1 then
        DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotArmor, 15, 1, 1, 7, 63, 0, iJoH, 0, 255, 255, 255, 255, 255, 0, 0)
    end
    
    if id.SlotBoots ~= -1 then
        DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotBoots, 15, 1, 1, 7, 63, 0, iJoH, 0, 255, 255, 255, 255, 255, 0, 0)
    end
    
    if id.SlotGloves ~= -1 then
        DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotGloves, 15, 1, 1, 7, 63, 0, iJoH, 0, 255, 255, 255, 255, 255, 0, 0)
    end
    
    if id.SlotHelm ~= -1 then
        DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotHelm, 15, 1, 1, 7, 63, 0, iJoH, 0, 255, 255, 255, 255, 255, 0, 0)
    end
    

    
    if id.SlotPants ~= -1 then
        DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotPants, 15, 1, 1, 7, 63, 0, iJoH, 0, 255, 255, 255, 255, 255, 0, 0)
    end
    
    if id.SlotPendant ~= -1 then
        DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotPendant, 15, 1, 1, 7, 63, 0, iJoH, 0, 255, 255, 255, 255, 255, 0, 0)
    end
    
    if id.SlotPet ~= -1 then
        DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotPet, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0)
    end
    
    if id.SlotRing ~= -1 then

 for i = 1, 2 do
        DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotRing, 15, 1, 1, 7, 63, 0, iJoH, 0, 255, 255, 255, 255, 255, 0, 0)
 end

    end
    
    if id.SlotRWeapon ~= -1 then
        if id.SlotRWeapon >= GET_ITEM(5,0) and id.SlotRWeapon <= GET_ITEM(5,511) then
            DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotRWeapon, 15, 1, 1, 7, 63, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0)
        elseif id.SlotRWeapon >= GET_ITEM(6,0) then
            DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotRWeapon, 15, 1, 1, 7, 63, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0)
        else -- SlotRWeapon <= 2559
            DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotRWeapon, 15, 1, 1, 7, 63, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0)
        end 
    end
    
    if id.SlotLWeapon ~= -1 then
        if id.SlotLWeapon >= GET_ITEM(5,0) and id.SlotLWeapon <= GET_ITEM(5,511) then
            DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotLWeapon, 15, 1, 1, 7, 63, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0)
        elseif id.SlotLWeapon >= GET_ITEM(6,0) then
            DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotLWeapon, 15, 1, 1, 7, 63, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0)
        else -- SlotRWeapon <= 2559
            DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotLWeapon, 15, 1, 1, 7, 63, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0)
        end   
    end

    if id.SlotWing ~= -1 then
        DataBase.InsertNpcRescueItem(GetObjectAccount(aIndex), id.SlotWing, 15, 1, 1, 7, 15, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0)
    end
    


end

function pShop.Init()
	if CONFIG.Active == false
	then
		return
	end

	ProtocolFunctions.GameServerProtocol(pShop.Protocol)
    

end


pShop.Init()
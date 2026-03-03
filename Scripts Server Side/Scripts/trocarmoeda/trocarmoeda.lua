local CONFIG = require("Scripts\\trocarmoeda\\Config")
local hf = {}


BridgeFunctionAttach('OnCommandManager', 'TradeCoin')
BridgeFunctionAttach('OnNpcTalk','TradeHunt')
BridgeFunctionAttach('OnNpcTalk','GemstoneTrade')


function TradeCoin(aIndex, Arguments)
    local Command    = CommandGetArgString(Arguments, 0)
    local Quantidade = CommandGetArgNumber(Arguments, 1) -- GP que o player quer trocar

    if not (Command == CONFIG.Command) then
        return 0
    end


    if Quantidade < 1000 then
        MessageSend(aIndex, 1, 0, "A troca mínima é de 1000 GP.")

        return 1
    end

    local AccountID = GetObjectAccount(aIndex)
    local GpAtual = DataBase.GetValue(CONFIG.Tabela, CONFIG.ColunaGP, CONFIG.ColunaConta, AccountID)

    if GpAtual < Quantidade then
        MessageSend(aIndex, 1, 0, string.format("Você não tem GP suficiente. Saldo atual: %d GP.", GpAtual))
        return 1
    end

    local GoldRecebido = math.floor(Quantidade / 1000)
    local GpGasto = GoldRecebido * 1000

    if GoldRecebido == 0 then
        MessageSend(aIndex, 1, 0, "Você precisa trocar pelo menos 1000 GP para receber 1 Gold.")
        return 1
    end

    --ObjectAddCoin(aIndex,aValue,bValue,cValue)
    --ObjectSubCoin(aIndex,aValue,bValue,cValue)


    -- Subtrai apenas os GP necessários
    --DataBase.SetAddValue(CONFIG.Tabela, CONFIG.ColunaSaldo, -GpGasto, CONFIG.ColunaConta, AccountID)
    ObjectSubCoin(aIndex,0,0,GpGasto)
    -- Adiciona os Golds
    --DataBase.SetAddValue(CONFIG.Tabela, CONFIG.ColunaGold, GoldRecebido, CONFIG.ColunaConta, AccountID)
    ObjectAddCoin(aIndex,0,GoldRecebido,0)
    MessageSend(aIndex, 1, 0, string.format("Você trocou %d GP por %d Golds com sucesso!", GpGasto, GoldRecebido))
    LogColor(2, string.format("Você trocou %d GP por %d Golds com sucesso!", GpGasto, GoldRecebido))

    return 1
end

function GemstoneTrade(npc, player)

    if GetObjectClass(npc) ~= 249 then return 0 end
    
    if GetObjectMap(npc) ~= 0 or GetObjectMapX(npc) ~= 113 or GetObjectMapY(npc) ~= 124 then
        return 0
    end

    -- [[Inicio do Script]] --
    local gemstone = GET_ITEM(14, 41)
    local harmony = GET_ITEM(14, 42)
    local quantidade = InventoryGetItemCount(player, gemstone, -1)

    if quantidade <= 0 then
        ChatTargetSend(npc, player, "Você não possui Gemstones.")
        return 1
    end

    local sucesso = 0
    local falha = 0

    for i = 1, quantidade do

        InventoryDelItemCount(player,gemstone,-1,0,0,1)

        if math.random(1, 100) >= 35 then
                ItemGiveEx(player, harmony, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 0)
                sucesso = sucesso + 1
        else
                falha = falha + 1
        end

    end

    -- Mensagem final com resultado
    ChatTargetSend(npc, player, string.format("Troca concluída. Sucesso: %d, Falha: %d", sucesso, falha))
    LogPrint(string.format("[%s]Troca concluída. Sucesso: %d, Falha: %d",GetObjectName(player), sucesso, falha))
    MessageSend(player, 1, 0, string.format("Genstone Refinadas com sucesso!"))

   sucesso = nil
   falha = nil

    return 1
end


function TradeHunt(npc, player)

	if GetObjectClass(npc) ~= 249 then return 0 end
    
    if GetObjectMap(npc) ~= 2 and GetObjectMapX(npc) ~= 220 and GetObjectMapY(npc) ~= 067 then
        return 0
    end

    hf.OpenSend(player, 1)

    return 1

end


function hf.OpenSend(player, open)

local packinfo = string.format("%s-%s-%s", CONFIG.PACKET, CONFIG.PACKETNAME, GetObjectName(player))
local Hunt = DataBase.GetValue('HuntFarm', 'HuntPoint', 'AccountID', GetObjectAccount(player))

CreatePacket(packinfo, CONFIG.PACKET)
SetBytePacket(packinfo, open)
SetDwordPacket(packinfo, math.floor(Hunt))
SendPacket(packinfo, player)
ClearPacket(packinfo)


end

hf.SaldoRetorno = 0



function hf.Protocol(aIndex, Packet, PacketName)
	if Packet == CONFIG.PACKET
	then

        if string.format('%s-%s-%s', CONFIG.PACKET,CONFIG.PACKETNAME, GetObjectName(aIndex)) == PacketName
		then
			hf.SaldoRetorno = GetDwordPacket(PacketName, -1)
            ClearPacket(PacketName)

            hf.exchange(aIndex, hf.SaldoRetorno)
            return
		end

    return
	end
end


function hf.exchange(aIndex, valor)

    local Hunt = DataBase.GetValue('HuntFarm', 'HuntPoint', 'AccountID', GetObjectAccount(aIndex))


    if Hunt < 1000 then 
        MessageSend(aIndex, 1, 0, "Você deve ter no minimo 1000 HuntPoints.")
        return 0 
    end

    if valor < Hunt then
        return 0 
    else
        DataBase.SetDecreaseValue('HuntFarm', 'HuntPoint', math.floor(valor), 'AccountID', GetObjectAccount(aIndex))
    end
  

   --DataBase.SetAddValue('CashShopData', 'WCoinP', math.floor(valor/500), 'AccountID',  GetObjectAccount(aIndex))

   ObjectAddCoin(aIndex,0,math.floor(valor/1000),0)

   -- success msg
   MessageSend(aIndex, 1, 0, string.format("parabéns você trocou %s HuntPoints por %s SCoin's", hf.SaldoRetorno, math.floor(hf.SaldoRetorno/1000)))

   hf.OpenSend(aIndex, 1)

end

function hf.Init()
	if CONFIG.Active == false
	then
		return
	end

	ProtocolFunctions.GameServerProtocol(hf.Protocol)
    

end


hf.Init()
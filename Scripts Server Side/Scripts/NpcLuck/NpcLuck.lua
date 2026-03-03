local CONFIG = require("Scripts\\NpcLuck\\Config")

BridgeFunctionAttach('OnNpcTalk','NpcLuck_NpcTalk')

NpcLuck = {}

function NpcLuck_NpcTalk(Npc, Player)
    if CONFIG.Enable ~= 1 then return 0 end

    local NpcClass = GetObjectClass(Npc)
    local NpcMap = GetObjectMap(Npc)
    local NpcPosX = GetObjectMapX(Npc)
    local NpcPosY = GetObjectMapY(Npc)

    if NpcClass == 249 and NpcMap == 0 and NpcPosX == 130 and NpcPosY == 140 then
        NpcLuck.Clicked(Player, Npc)
        return 1
    end

    return 0
end

function NpcLuck.Clicked(player, npc)
    local random = math.random(1, #CONFIG.Item)
    local selectedItem = CONFIG.Item[random]
    local AccountID = GetObjectAccount(player)

    local GetCoin = DataBase.GetValue(CONFIG.Tabela, CONFIG.ColunaSaldo, CONFIG.ColunaConta, AccountID)
    if GetCoin < CONFIG.Cash then
        ChatTargetSend(npc, player, string.format("Você precisa ter %d FCoin's", CONFIG.Cash))
        LogColor(3, string.format('[NPC LUCK] %s - Você precisa ter %d FCoins', AccountID, ONFIG.Cash))
        return 0
    end

    if CONFIG.Type == 1 then
        if InventoryGetFreeSlotCount(player) < 10 then
            ChatTargetSend(npc, player, "Libere pelo menos 10 Slots no seu inventário!")
            LogColor(3, string.format('[NPC LUCK] %s - Libere pelo menos 10 Slots no seu inventário!', AccountID))
            return 0
        end
    end

    ObjectSubCoin(player, CONFIG.Cash, 0, 0)

    -- Se o item for de saldo (FCoin)
    if selectedItem.cash == 1 then
        local cashback = math.random(selectedItem.ItemIndex, selectedItem.Level)
        ObjectAddCoin(player, cashback, 0, 0)
        ChatTargetSend(npc, player, string.format("Você ganhou %s e recebeu %d FCoin's!", selectedItem.Name, cashback))
        LogColor(3, string.format('[NPC LUCK] %s - Você ganhou %s e recebeu %d FCoin', AccountID, selectedItem.Name, cashback ))
    else
        -- Item físico
        if CONFIG.Type == 0 then
            NpcRescueItem.InsertItem(AccountID, selectedItem.ItemIndex, selectedItem.Level, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0)
        else
            ItemGiveEx(player, selectedItem.ItemIndex, selectedItem.Level, -1, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0)
        end
        ChatTargetSend(npc, player, string.format("Parabéns, você recebeu um %s!", selectedItem.Name))
        LogColor(3, string.format('[NPC LUCK] %s - Parabéns, você recebeu um %s', AccountID, selectedItem.Name))
    end
end

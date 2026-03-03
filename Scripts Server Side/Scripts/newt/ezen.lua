local CONFIG = require("Scripts\\newt\\Config")
BridgeFunctionAttach('OnCommandManager','EzenCommand')

function EzenCommand(aIndex, Arguments)
	if CONFIG.Enable == 0 then return 0 end

	local Command   = CommandGetArgString(Arguments,0)
	local Command2  = CommandGetArgString(Arguments,1)

	if not (Command == CONFIG.Command) then
		return 0
	end

	local Language      = GetObjectLanguage(aIndex)
	local AccountLevel  = GetObjectAccountLevel(aIndex)
    local UserMoney     = GetObjectMoney(aIndex)
    local check 	    = InventoryGetItemCount(aIndex,GET_ITEM(14, 12),-1)
    local Account       = GetObjectAccount(aIndex)

    if Command2 == CONFIG.Create then
        if UserMoney >= CONFIG.MinMoney then
            local NewMoney = UserMoney - CONFIG.MinMoney
            SetObjectMoney(aIndex, NewMoney)
            MoneySend(aIndex)
            ItemGiveEx(aIndex,GET_ITEM(14, 12),0,0,0,0,0,0,0,0,0,255,255,255,255,255,255,0)
            MessageSend(aIndex, 1, 0, string.format(CONFIG.MESSAGES[2][Language]))
            LogColor(2, string.format('%s - %s',Account, CONFIG.MESSAGES[2][Language]))
            return 1
        else
            MessageSend(aIndex, 1, 0, string.format(CONFIG.MESSAGES[1][Language]))
            LogColor(2, string.format('%s - %s',Account, CONFIG.MESSAGES[1][Language]))
            return 1
        end
    end
    if Command2 == CONFIG.Dissolv then
        if check >= 1 then
            if UserMoney > CONFIG.MinMoney then
                MessageSend(aIndex, 1, 0, string.format(CONFIG.MESSAGES[4][Language]))
                LogColor(2, string.format('%s - %s',Account, CONFIG.MESSAGES[4][Language]))
                return 1
            else
                InventoryDelItemCount(aIndex,GET_ITEM(14, 12),-1,0,0,1)
                SetObjectMoney(aIndex, UserMoney + CONFIG.MinMoney)
                MoneySend(aIndex)
                MessageSend(aIndex, 1, 0, string.format(CONFIG.MESSAGES[5][Language]))
                LogColor(2, string.format('%s - %s',Account, CONFIG.MESSAGES[5][Language]))
                return 1
            end
        else
            MessageSend(aIndex, 1, 0, string.format(CONFIG.MESSAGES[3][Language]))
            LogColor(2, string.format('%s - %s',Account, CONFIG.MESSAGES[3][Language]))
            return 1
        end
    end
end


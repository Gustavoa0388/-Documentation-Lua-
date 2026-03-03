local CONFIG = require("Scripts\\VenderVip\\Config")


BridgeFunctionAttach('OnCommandManager', 'VenderVip')


function VenderVip(aIndex, Arguments)

    local Command       = CommandGetArgString(Arguments, 0)
    local Name          = CommandGetArgString(Arguments, 1)
    local Dias          = CommandGetArgNumber(Arguments, 2) 
    local Segundos = Dias * 24 * 3600

if (Command == CONFIG.Command) then
 
    if not TemPermissao(GetObjectAccount(aIndex)) then
        NoticeSend(aIndex, 1, "Você não tem permissão para usar esse comando.")
        return 0
    end
    
    for i = GetMinUserIndex(), GetMaxUserIndex() do
        if GetObjectAccount(i) == Name then
            local AccountID = GetObjectAccount(i)
            UserSetAccountLevel(i,2,Segundos)
            LogPrint(string.format("[VIP] Adicionado na conta %s (Dias: %d)", Name, Dias))
            DataBase.RegistrarVendaVip(GetObjectAccount(aIndex), AccountID, Dias)
        end
    end
    return

elseif (Command == "/galo") then


    ItemGiveEx(aIndex,GET_ITEM(13, 253),0,0,0,0,0,0,0,0,0,255,255,255,255,255,255,0)
    LogPrint(string.format("[GALO] %s Editou um galo", GetObjectName(aIndex)))

    return

end



return 0

end


function TemPermissao(Login)
    for i = 1, #CONFIG.Permission do
        if CONFIG.Permission[i].Login == Login then
            return true
        end
    end
    return false
end
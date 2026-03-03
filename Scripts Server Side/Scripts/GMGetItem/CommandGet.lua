local CONFIG = require("Scripts\\GMGetItem\\Config")

BridgeFunctionAttach('OnCommandManager','GMCommand')

ComandGet = {}

Check = {
    { Name = 'louismk', permission = 1 },
    { Name = 'blackfrida', permission = 1 },
    -- Adicione mais conforme necessário
}


function GMCommand(aIndex, Arguments)

    if CONFIG.Enable == 0 then return 0 end
    
    local Command   = CommandGetArgString(Arguments,0)
    local Arg1      = CommandGetArgString(Arguments,1)
    local Arg2      = CommandGetArgNumber(Arguments,2)
    local AccountID = GetObjectAccount(aIndex)

    if not (Command == CONFIG.Command) then
		return 0
	end

    for i = 1, #Check do
        local chek = Check[i]
    
        if AccountID == chek.Name then
            if chek.permission == 0 then
                MessageSend(aIndex, 1, 0, string.format("Pode nao man"))
                return
            end
        end
    end
    
    

    if Arg1 == string.lower('set') then
        for a = 7, 11 do
            for b = 100, 170 do
                ComandGet.InsertItem(AccountID, GET_ITEM(a, b), 15, 1, 1, 7, 63, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0)
                MessageSend(aIndex, 1, 0, string.format("Item adicionado: %s", GET_ITEM(a, b)))

            end
        end
        
    elseif Arg1 == string.lower('armas') then
        for i = 0, 6 do
            if i ~= 1 and i ~= 3 and i ~= 6 then
                for b = 100, 109 do
                ComandGet.InsertItem(AccountID, GET_ITEM(i, b), 15, 1, 1, 7, 63, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0)
                MessageSend(aIndex, 1, 0, string.format("Item adicionado: %s", GET_ITEM(i, b)))
                end
            end
        end
    end
    


end




function ComandGet.InsertItem(Account, Item, Itemlevel, iOp1, iOp2, iOp3, iExc, iAncient, iJoH, iSockCount, iSock1, iSock2, iSock3, iSock4, iSock5, DaysExpire, ItemTimeExpire)
    -- Verifica se ItemTimeExpire é nulo, se for, atribui 0
    if ItemTimeExpire == nil then
        ItemTimeExpire = 0
    end

    -- Chama a função DataBase.InsertNpcRescueItem para inserir o item
    DataBase.InsertNpcRescueItem(Account, Item, Itemlevel, iOp1, iOp2, iOp3, iExc, iAncient, iJoH, iSockCount, iSock1, iSock2, iSock3, iSock4, iSock5, ItemTimeExpire, DaysExpire)
end
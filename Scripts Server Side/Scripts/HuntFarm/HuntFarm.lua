local CONFIG = require("Scripts\\HuntFarm\\Config")


BridgeFunctionAttach('OnMonsterDie','HuntMonsterKill')
BridgeFunctionAttach('OnCharacterEntry','HuntCharacterEntry')

function HuntCharacterEntry(aIndex)

    local accountID = GetObjectAccount(aIndex)

    -- Query para inserir se não existir
    local insertQuery = string.format("INSERT INTO HuntFarm (AccountID, HuntPoint)  SELECT '%s', 0 WHERE NOT EXISTS (SELECT 1 FROM HuntFarm WHERE AccountID = '%s')", accountID, accountID)

    SQLQuery(insertQuery)
    SQLClose()

    -- Query para buscar os dados
    local selectQuery = string.format("SELECT AccountID, HuntPoint FROM HuntFarm WHERE AccountID = '%s'", accountID)

    SQLQuery(selectQuery)
    SQLFetch()
    
    -- Você pode pegar os valores assim, se necessário:
    local resultAccount = SQLGetString("AccountID")
    local resultPoint = SQLGetNumber("HuntPoint")
    
    SQLClose()

    LogColor(1, insertQuery)

    -- Se quiser retornar os valores:
    -- return resultAccount, resultPoint
end




function HuntMonsterKill(aIndex, bIndex)


	-- aIndex = Monster index (victim).
	-- bIndex = User index (killer).

    if not CONFIG.Enable then return end

    if GetObjectMap(bIndex) == CONFIG.Map and GetObjectMap(aIndex) == CONFIG.Map or
       GetObjectMap(bIndex) == CONFIG.MapVip and GetObjectMap(aIndex) == CONFIG.MapVip 
    then

        SendMoney(bIndex, 0.35)



    local GetHunt = DataBase.GetValue('HuntFarm', 'HuntPoint', 'AccountID', GetObjectAccount(bIndex))

    DataBase.SetAddValue('HuntFarm', 'HuntPoint', 1, 'AccountID', GetObjectAccount(bIndex))

else

    return

end


end


function SendMoney(player, percentage)

    local randomic = math.random(1, 10000)

    if randomic == 10000 then
        local currentZen = GetObjectMoney(player)

        -- Verifica se o valor atual é válido
        if currentZen <= 0 or currentZen >= 2000000000 then
            return
        end

        -- Calcula o aumento baseado na porcentagem
        local increase = math.floor(currentZen * percentage)

        -- Ajusta para não ultrapassar o limite
        if currentZen + increase > 2000000000 then
            increase = 2000000000 - currentZen
        end

        -- Calcula o novo valor final
        local finalZen = currentZen + increase

        -- Aplica e envia
        SetObjectMoney(player, finalZen)
        MoneySend(player)

        PostSend(2,69,GetObjectName(player),string.format("Recebeu %d zen no Mapa VIP", increase))
    end
end

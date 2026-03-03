-- ScriptClient/Script/System/CommandParser.lua

local QuestManager = require("Scripts\\QuestSystem\\QuestManager")

local CommandParser = {}

-- ============================================
-- INTERCEPTAR MENSAGENS DE CHAT
-- ============================================
BridgeFunctionAttach('MainProcThread', 'CommandParser_CheckInput')

function CommandParser_CheckInput()
    -- Esta função é chamada a cada frame
    -- Aqui você pode verificar entrada de comando
end

-- ============================================
-- PROCESSAR COMANDO VIA CHAT
-- ============================================
function CommandParser.ExecuteCommand(command)
    -- Remover espaços
    command = command:lower():trim()
    
    if command == "/quests" or command == "/quest" then
        QuestManager.Open()
        return true
    end
    
    if command == "/questclose" then
        QuestManager.Close()
        return true
    end
    
    return false
end

-- Hook para processar quando receber mensagem
BridgeFunctionAttach('ClientProtocol', 'CommandParser_ProcessProtocol')

function CommandParser_ProcessProtocol(packet, packet_name)
    -- Se for uma mensagem do sistema, processar comando
    if packet_name == "Message" then
        -- Aqui você poderia capturar mensagens do servidor
    end
end

-- Função auxiliar
function string.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

return CommandParser
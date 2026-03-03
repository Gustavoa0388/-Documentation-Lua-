-- ScriptClient/Script/System/ChatCommandListener.lua

local QuestManager = require("Scripts\\QuestSystem\\QuestManager")

local ChatListener = {}

-- ============================================
-- INTERCEPTAR MENSAGENS DIGITADAS
-- ============================================
BridgeFunctionAttach('KeyboardEvent', 'ChatListener_OnKeyPress')

local LastChatMessage = ""

function ChatListener_OnKeyPress(key)
    -- Se o chat estiver aberto
    if CheckWindowOpen(UIChatWindow) == 1 then
        -- Quando pressiona ENTER
        if key == Keys.Return then
            -- Aqui você teria acesso à mensagem digitada
            -- No MU Online, o chat é gerenciado internamente
            
            -- Alternativa: usar comando local sem enviar pro chat
            -- Exemplo: se o jogador digitar "/quests" diretamente
        end
    end
end

-- ============================================
-- MÉTODO ALTERNATIVO: Verificar mensagem antes de enviar
-- ============================================
function ChatListener.ProcessChatMessage(message)
    message = message:lower():trim()
    
    -- Comandos locais (não enviam pro servidor)
    if message == "/quests" or message == "/quest" then
        QuestManager.Open()
        return true  -- Bloqueia de enviar para o chat
    end
    
    if message == "/questclose" then
        QuestManager.Close()
        return true
    end
    
    return false
end

function string.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

return ChatListener
local CONFIG = require("Scripts\\BossHPBar\\Config")

Boss = {}
Boss.Imprime = 0
Boss.Timer = 100
Boss.CalcDamage = 0
Boss.DmgRate = 0
Boss.Step = 100000

local PosX = 200
local PosY = 50
local width = 300
local height = 20
local pulseTime = 0.0

BridgeFunctionAttach('MainInterfaceProcThread','BossDrawBar')
BridgeFunctionAttach('MainProcThread','BossThread')


function BossThread()

    pulseTime = pulseTime + 0.05  -- Atualizado periodicamente


if Boss.Imprime == 0 then return end

if Boss.Timer == 0 then 
    Boss.Imprime = 0
    Boss.CalcDamage = 0
    Boss.DmgRate = 0
    return 
end

Boss.Timer = Boss.Timer - 1

end


function BossDrawBar()

if CONFIG.ENable == 0 then return end
if Boss.Imprime == 0 then return end

Boss.RenderBar()

Boss.RenderText()

end

function Boss.RenderText()

    SetBlend(1)
	SetFontType(0)
	SetTextBg(0, 0, 0, 155)
	SetTextColor(225, 225, 225, 255)

    Boss.DmgRate = math.floor((Boss.CalcDamage / Boss.ViewMaxHP) * 100)
    RenderText5(Boss.Center()+(width/4), PosY-10, string.format('%s (%s%%)', Boss.CalcDamage, Boss.DmgRate), width/2, 3)

    SetBlend(1)
	SetFontType(1)
	SetTextBg(0, 0, 0, 0)
	SetTextColor(0, 0, 0, 255)
    --RenderText5(Boss.Center()+1, PosY+05+1, string.format('%s / %s', Boss.ViewCurHP, Boss.ViewMaxHP), width, 3)
    RenderText5(Boss.Center()+1+1, PosY+10+1, string.format('%s%%', Boss.ViewRateHP, math.floor(Boss.ViewCurHP/Boss.Step)), width, 4)
    RenderText5(Boss.Center()+1, PosY+05+1, string.format('%s', Boss.Name), width, 3)

    SetBlend(1)
	SetFontType(1)
	SetTextBg(0, 0, 0, 0)
	SetTextColor(225, 225, 225, 255)
   -- RenderText5(Boss.Center(), PosY+05, string.format('%s / %s', Boss.ViewCurHP, Boss.ViewMaxHP), width, 3)
    RenderText5(Boss.Center()+1, PosY+10, string.format('%s%%', Boss.ViewRateHP, math.floor(Boss.ViewCurHP/Boss.Step)), width, 4)
    RenderText5(Boss.Center(), PosY+05, string.format('%s', Boss.Name), width, 3)

    

end

function Boss.RenderBar()

    SetBlend(1)

	glColor4f(0.0, 0.0, 0.0, 0.9)
	DrawBar(Boss.Center(), PosY, width, height, 0.0, 0)

    local pulse = 0.5 + 0.5 * math.sin(pulseTime * 2)  -- Varia entre 0.0 e 1.0

   -- local totalSteps = math.floor(Boss.ViewMaxHP / Boss.Step)
   -- local currentStep = math.floor(Boss.ViewCurHP / Boss.Step)
   -- local stepHP = Boss.ViewCurHP % Boss.Step
    
    -- Calcula proporção da barra atual
    --local barWidth = (stepHP * (width - 2)) / Boss.Step
    
    for i = 0, height - 3 do
        local t = i / (height - 3)
        local hp = Boss.ViewRateHP
    
        -- Cores base para interpolação
        local r, g, b
    
        -- Degradê vermelho -> roxo rosado (usando o t do degradê)
        r = ((1.0 * (1 - t)) + (0.7 * t))  -- Gradiente de vermelho a roxo rosado
        g = 0.0
        b = ((0.0 * (1 - t)) + (0.5 * t))  -- Gradiente de roxo rosado (azul/roxo)
    
        -- Escurecimento das cores baseado na % do HP
        if hp > 70 then
            -- Verde escuro mais avermelhado
            local factor = (100 - hp) / 30 -- de 0 a 1 conforme HP vai de 100 a 70
            r = r * (0.4 + (0.6 * factor))  -- Aumenta o vermelho conforme HP diminui
            g = g * 0.4  -- Mantém o verde escuro
            b = b * 0.0  -- Azul é zero
        elseif hp > 40 then
            -- Amarelo escuro e avermelhado
            local factor = (70 - hp) / 30
            r = r * (0.7 + (0.3 * factor))  -- Mais vermelho
            g = g * (0.5 - (0.3 * factor))  -- Menos verde
            b = b * 0.0
        else
            -- Vermelho escuro mais intenso
            local factor = (40 - hp) / 40
            r = r * (0.8 + (0.2 * factor))  -- Intensifica o vermelho
            g = g * (0.2 - (0.2 * factor))  -- Verde muito escuro
            b = b * 0.0  -- Azul é zero
        end
    
        -- Pulso (se desejar manter)
        r = r * (0.8 + 0.2 * pulse)
        g = g * (0.8 + 0.2 * pulse)
        b = b * (0.8 + 0.2 * pulse)
    
        glColor4f(r, g, b, 1.0)
        DrawBar(Boss.Center() + 1, PosY + 1 + i, (hp / 100.0) * (width - 2), 1, 0.0, 0)
    end
    
    
    
    
    

	EndDrawBar()
	DisableAlphaBlend()



end

function Boss.Init()
	ProtocolFunctions.ClientProtocol(Boss.Protocol)
end

function Boss.Protocol(Packet, PacketName)

	if Packet == CONFIG.PACKET and PacketName == string.format("%s-%s",UserGetName(), CONFIG.PACKET) then 

        Boss.Byte = GetBytePacket(PacketName, -1)
		Boss.Name = GetCharPacketLength(PacketName, -1, Boss.Byte)
		Boss.ViewCurHP  = GetDwordPacket(PacketName, -1)
		Boss.ViewMaxHP  = GetDwordPacket(PacketName, -1)
		Boss.ViewRateHP = GetBytePacket(PacketName, -1)
        Boss.ViewDamage = GetDwordPacket(PacketName, -1)
		ClearPacket(PacketName)

        Boss.Imprime = 1
        Boss.Timer = 100       
		
        Boss.CalcDamage = Boss.ViewDamage + Boss.CalcDamage

        Console(2, Boss.CalcDamage)
		return 
	end

end

function Boss.Center()

    if GetWideX() == 640 then
        return (GetWideX() / 2) - (width  / 2)
    else
        return (747 / 2) - (width  / 2) + (107/2)
    end

end


Boss.Init()
local CONFIG = require("Scripts\\TradeHunt\\Config")
local CF = require("Scripts\\TradeHunt\\CustomFont")
local hf = {}
hf.Open = 0
hf.Number = 0
hf.meusaldo = 0
hf.Mult = 1

local posx = 0
local posy = 0
local size = 250
local page = 0
local maxpage = 0
local Width = 0

BridgeFunctionAttach('MainInterfaceProcThread','TradeHuntRender')
BridgeFunctionAttach('KeyboardEvent','TradeHuntKey')
BridgeFunctionAttach('UpdateMouseEvent','TradeHuntClick')


function TradeHuntKey(KeyNumber)
    if hf.Open == 0 then return end
	if KeyNumber == Keys.Escape
	then

		hf.Open = 0
		hf.Number = 0
		UnlockPlayerWalk()

        return
	end

    if KeyNumber == Keys.Space
    then
        if hf.Number ~= math.floor(hf.meusaldo)
        then
            hf.Number = math.floor(hf.meusaldo)
        else
            hf.Number = 0
        end
        
    end
end

function TradeHuntRender()

if hf.Open == 0 then return end

if GetWideX() ~= 640 then
        Width = 840 
    else 
        Width = 640
    end

	LockPlayerWalk()
	SetLockInterfaces()
	
	SetBlend(1)

	glColor4f(1.0, 1.0, 1.0, 1.0)



	posx = (Width/2) - (size/2)
	posy = 150


	hf.RenderBack(posx, posy)
    hf.Text(posx+2, posy)
    hf.RenderButton(posx, posy)


end

function  hf.RenderButton(x,y)
	local nx = x+40
	local ny = y-100

	RenderImage(31757, nx-20, ny+158, 16, 16) -- Btn L
	RenderImage(31396, nx+size-73, ny+158, 16, 16) -- Btn R

end

function hf.RenderBack(x, y)
if hf.Open == 0 then return end
	-- BACKGROUND
	--glColor4f(0.0, 0.0, 0.0, 0.80);
	--DrawBar(x, y, size, (size/2+20))
    glColor4f(1.0, 1.0, 1.0, 1.0);
    RenderImage(40001, x, y-80, 252, 329)

   -- RenderImage(31393, x, y-40, 170.0, 24.0)
    RenderImageScale(31393, x+160, y+120, 240.0, 16.0, 0.0, 0.0, 0.00, 1.00, 1.0)
    RenderImageScale(31393, x+160, y+140, 240.0, 16.0, 0.0, 0.0, 0.00, 1.00, 1.0)
    RenderImageScale(31393, x+160, y+160, 240.0, 16.0, 0.0, 0.0, 0.00, 1.00, 1.0)
    RenderImageScale(31393, x+160, y+180, 240.0, 16.0, 0.0, 0.0, 0.00, 1.00, 1.0)

	local CheckOK = hf.CheckMouseIn(x+ (size/4), y+200, 60, 20)
 	local CheckCancel = hf.CheckMouseIn( x+ (size/2), y+200, 60, 20)
    
    local btnok = 31502
    local btncancel = 31499

	if CheckOK == 1 then 
		btnok = btnok+1
	end
	if CheckCancel == 1 then 
		btncancel = btncancel+1
	end

    
    RenderImageScale(40002, x+127, y+65, 160.0, 50.0, 0.0, 0.0, 0.00, 0.915, 0.84)

    --RenderImage(btnok, x+ (size/4), y+200, 60, 30) -- OK
    RenderImage2(btnok, x+ (size/4),y+200, 60, 20, 0.0, 0.0, 0.85, 1.0, 1.0, 1.0, 1.0)
    --RenderImage(btncancel, x+ (size/2), y+200, 60, 60) -- CANCEL
    RenderImage2(btncancel, x+ (size/2),y+200, 60, 20, 0.0, 0.0, 0.85, 1.0, 1.0, 1.0, 1.0)

	EndDrawBar()
	

end

function TradeHuntClick()
    if hf.Open == 0 then return end

    local nx = posx + 40
    local ny = posy - 100
    local mouseX, mouseY = nx - 20, ny + 158
    local mouseWidth, mouseHeight = 16, 16
    local rightX = nx + size - 73

    -- LEFT: Remover valor
    if hf.CheckMouseIn(mouseX, mouseY, mouseWidth, mouseHeight) == 1 then
        if CheckReleasedKey(Keys.LButton) == 1 then
            if hf.Number >= 1000 then
                hf.Number = hf.Number - 1000
            else
                hf.Number = 0
            end
        elseif CheckReleasedKey(Keys.RButton) == 1 then
            if hf.Number >= 10000 then
                hf.Number = hf.Number - 10000
            else
                hf.Number = 0
            end
        end
    end

    -- RIGHT: Adicionar valor
    if hf.CheckMouseIn(rightX, mouseY, mouseWidth, mouseHeight) == 1 then
        if CheckReleasedKey(Keys.LButton) == 1 then
            hf.Number = hf.Number + 1000
        elseif CheckReleasedKey(Keys.RButton) == 1 then
            hf.Number = hf.Number + 10000
        end

        -- Garante que não ultrapasse o saldo
        if hf.Number >= hf.meusaldo then
            hf.Number = math.floor(hf.meusaldo)
        end
    end


    local ini = (Width/2) - (size/2)
	local ini2 = 150

	local CheckOK = hf.CheckMouseIn(ini+ (size/4), ini2+200, 60, 20)
 	local CheckCancel = hf.CheckMouseIn( ini+ (size/2), ini2+200, 60, 20)

   -- TRADE
    if CheckOK == 1 then
        if CheckReleasedKey(Keys.LButton) == 1 then
            local packinfo = string.format("%s-%s-%s", CONFIG.PACKET, CONFIG.PACKETNAME, UserGetName())
            local Hunt = hf.Number

            CreatePacket(packinfo, CONFIG.PACKET)
            SetDwordPacket(packinfo, Hunt)
            SendPacket(packinfo, player)
            ClearPacket(packinfo)
        end
    end

    if CheckCancel == 1 then
        if CheckReleasedKey(Keys.LButton) == 1 then
		    hf.Open = 0
		    hf.Number = 0
		    UnlockPlayerWalk()
            return
        end
    end
end

function hf.Text(x, y)

	SetFontType(1)

	--Title Package
	SetTextBg(0, 0, 0, 0)
	SetTextColor(255, 255, 255, 255)
	--RenderText(x, y, string.format("Quantos Hunts você gostaria de trocar ?"), size, 3)

    


    --Title Package
	SetTextBg(0, 0, 0, 0)
	SetTextColor(255, 255, 255, 255)
	RenderText(x, y+100, string.format("Trocar: %s HuntPoints's por %s SCoin's", hf.Number, math.floor(hf.Number/1000)), size, 3)

	--Saldo Package
    SetFontType(1)
	SetTextBg(0, 0, 255, 0)
	SetTextColor(255, 255, 255, 255)

	RenderText(x+43, y+113, string.format("FCoin", GetCoin1()), size, 0)
	RenderText(x+43, y+133, string.format("SCoin", GetCoin2()), size, 0)
	RenderText(x+43, y+153, string.format("GCoin", GetCoin3()), size, 0)
	RenderText(x+43, y+173, string.format("Hunt Farm", math.floor(hf.meusaldo)), size, 0)

    SetTextColor(255, 0, 0, 255)
	RenderText(x+113, y+113, string.format("%s", GetCoin1()), size, 0)
	RenderText(x+113, y+133, string.format("%s", GetCoin2()), size, 0)
	RenderText(x+113, y+153, string.format("%s", GetCoin3()), size, 0)
	RenderText(x+113, y+173, string.format("%s", math.floor(hf.meusaldo)), size, 0)


    local zenValue = hf.Number; --// valor de Zen ou número a ser renderizado

    hf.SetZenColor(zenValue); --// define a cor de acordo com o valor

    RenderNumber(x+(size/2) + #(string.format("%s", hf.Number)), y+58, hf.Number, 13, 13)
    
    glColor4f(1.0, 1.0, 1.0, 1.0)

end

function hf.SetZenColor(value)
    if value < 10000 then
        glColor4f(1.0, 1.0, 1.0, 1.0) -- Branco
    elseif value < 100000 then
        glColor4f(0.0, 1.0, 0.0, 1.0) -- Verde
    elseif value < 1000000 then
        glColor4f(0.0, 0.5, 1.0, 1.0) -- Azul
    elseif value < 10000000 then
        glColor4f(0.7, 0.0, 1.0, 1.0) -- Roxo
    else
        glColor4f(1.0, 0.8, 0.0, 1.0) -- Dourado
    end
end

function hf.CheckMouseIn(x, y, w, h)


	if MousePosX() >= x and MousePosX() <= x+w and MousePosY() >= y and MousePosY() <= y+h then
		return 1
	else
		return 0
	end

end

function hf.init()
    hf.Open = 0

	ProtocolFunctions.ClientProtocol(hf.Protocol)
end

function hf.Protocol(Packet, PacketName)

	if Packet == CONFIG.PACKET
	then
		if string.format('%s-%s-%s', CONFIG.PACKET, CONFIG.PACKETNAME, UserGetName()) == PacketName
		then
			hf.Open = GetBytePacket(PacketName, -1)
            hf.meusaldo = GetDwordPacket(PacketName, -1)
			ClearPacket(PacketName)

            Console(2, hf.Open)
			return
		end

	end



end

hf.init()

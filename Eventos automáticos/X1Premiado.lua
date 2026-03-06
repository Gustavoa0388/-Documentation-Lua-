--[[
Sistema de evento in-game 
]]--

X1Premiado = {}

local Players = {}
local Participantes = {}
local Map = 0
local CoordX = 0
local CoordY = 0
local idtimer = -1
local timer = 0
local started = false
local ComandoOn = false
local timer_check = nil
local timer_finish = nil
local timer_vivos = nil
local timer_contar = nil
local timer_contar2 = nil
local timer_andar = nil
local gm = ''
local player1 = ''
local player2 = ''


function X1Premiado.TimerEvento()

	Timer.Interval(30, X1Premiado.Init)
end

function X1Premiado.Init()

	if started == true
	then
		return
	end
	
	if EVENTOS_INICIO_AUTOMATICO == 0
	then
		
		-- verificar se já não tem algum evento automático rolando
		local StatusEventoAuto = DataBase.GetValue3("EVENTO_AUTO", "status")
		
		if StatusEventoAuto == 1
		then
			return
		end
		
		if os.date("%X") >= "15:40:00" and os.date("%X") <= "15:41:00"
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			X1Premiado.CommandOpen_Auto()
		else
			return
		end
	
	else
	
		-- verificar se tem GMs ON
		for i = 9000, 9999 do
			if UserGetConnected(i) == 3
			then
				if UserGetAuthority(i) ~= 1
				then
					--SendMessageGlobal(string.format("[Sistema] Evento não iniciado, pois há GMs online."), 0)
					
					return
				end
			end
		
		end
		
		-- verificar se já não tem algum evento automático rolando
		local StatusEventoAuto = DataBase.GetValue3("EVENTO_AUTO", "status")
		
		if StatusEventoAuto == 1
		then
			return
		end
		
		-- verificar se o evento já está aberto
		if started == true
		then
			return
		end
		
		-- verificar se o evento escolhido é esse
		local EventoEscolhido = DataBase.GetValue4("EVENTO_AUTO", "evento", "status", 0)

		if EventoEscolhido == 'X1 Premiado'
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			X1Premiado.CommandOpen_Auto()
		else
			return
		end
	
	
	end
	
	
end




function X1Premiado.CommandOpen_Auto()
	
	timer_check = nil
	timer_finish = nil
	timer_vivos = nil
	timer_contar = nil
	timer_contar2 = nil
	timer_andar = nil
	gm = ''
	player1 = ''
	player2 = ''

	Players = {}
	Participantes = {}
	
	timer = 30
	
	Map = 6
	CoordX = 215
	CoordY = 195
	
	started = false
	ComandoOn = true
	
	idtimer = Timer.Repeater(1, timer, X1Premiado.Running)
	
	SendMessageGlobal(string.format("[Sistema] X1 Premiado está aberto!"), 0)
	SendMessageGlobal(string.format("Digite: /x1premiado para vir."), 0)
	
end




function X1Premiado.CheckUser()

	if started == false
	then
		return
	end

	for i, name in ipairs(Participantes) do 
		local index = Participantes[name]
		local NickRemover = UserGetName(index)
			
		if UserGetConnected(index) ~= 3
		then
			X1Premiado.RemoveUser(i)
			X1Premiado.CheckVivos()
		end
		
		if UserGetMapNumber(index) ~= Map
		then
			X1Premiado.RemoveUser(NickRemover)
			X1Premiado.CheckVivos()
		end
		
		if UserGetMapNumber(index) == Map
		then
			if UserGetX(index) < 210 and UserGetY(index) < 209 or UserGetX(index) > 242 and UserGetY(index) > 237
			then
				SendMessage(string.format("[Sistema] Você saiu do evento!"), index, 1)
				Teleport(index, 0, 125, 125)
				X1Premiado.RemoveUser(NickRemover)
			end
		end
		
	
		
	end
	
	
end


function X1Premiado.CheckVivos()

	if started == false
	then
		return
	end

	if #Participantes == 1
	then
		
		X1Premiado.FinishEvent()
	
	end
		
end


function X1Premiado.FinishEvent()

	SendMessageGlobal(string.format("[Sistema] X1 Premiado finalizado!"), 0)
	
	if #Participantes >= 2 or #Participantes < 1
	then
	
		SendMessageGlobal(string.format("(Os players demoraram para se matar ou todos saíram do mapa/jogo)."), 0)
		
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name]
			local NickRemover = UserGetName(index)
				
			if UserGetConnected(index) ~= 3
			then
				X1Premiado.RemoveUser(NickRemover)
			end
				
			Teleport(Participantes[name], 0, 125, 125)
				
		end
		
		
	elseif #Participantes == 1
	then
	
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name]
			SendMessageGlobal(string.format("Vencedor: %s", UserGetName(index)), 0)
			
			
			
			
				
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(index))
			DataBase.SetAddValue("Character", COLUNA_X1PREMIADO, PONTOS_EVENTINHOS, "Name", UserGetName(index))
			SendMessageGlobal(string.format("~> Prêmio: %d %s! <~", PREMIO_EVENTINHOS, NOME_MOEDA_EVENTO), 0)
			Teleport(index, 0, 125, 125)

			-- pontos eventos total
			DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(index))
			DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(index))
			DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(index))
				
			
			
			
			
			
			
			
		end
		
	end
	
	started = false
	ComandoOn = false
	
	if timer_finish ~= nil
	then
		Timer.Cancel(timer_finish)
		timer_finish = nil
	end
	
	if timer_vivos ~= nil
	then
		Timer.Cancel(timer_vivos)
		timer_vivos = nil
	end
	
	if timer_contar ~= nil
	then
		Timer.Cancel(timer_contar)
		timer_contar = nil
	end
	
	if timer_contar2 ~= nil
	then
		Timer.Cancel(timer_contar2)
		timer_contar2 = nil
	end
	
	if timer_andar ~= nil
	then
		Timer.Cancel(timer_andar)
		timer_andar = nil
	end
	
	if timer_check ~= nil
	then
		Timer.Cancel(timer_check)
		timer_check = nil
	end
	
	Timer.TimeOut(2, X1Premiado.StatusOFFevent)
	
	
end



function X1Premiado.Running()

	if timer == 0
	then
		
		timer_check = Timer.Interval(2, X1Premiado.CheckUser)
		timer_vivos = Timer.Interval(3, X1Premiado.CheckVivos)
		timer_finish = Timer.TimeOut(5 * 60, X1Premiado.FinishEvent)
		
		started = true
		ComandoOn = false
		
		
		for i, name in ipairs(Players) do 
			local index = Players[name]
			local NickRemover = UserGetName(index)
			
			if UserGetConnected(index) ~= 3
			then
				X1Premiado.RemoveUserPlayers(NickRemover)
			end
			
			InsertKey(Participantes, UserGetName(index))
			Participantes[UserGetName(index)] = index
			DataBase.SetValue("Character", "eventomove", 0, "Name", UserGetName(index)) -- remover participando evento move
			
			--Teleport(Participantes[name], Map, CoordX, CoordY)
			
			local indexplayer1 = GetIndex(player1)
			local indexplayer2 = GetIndex(player2)
			Teleport(indexplayer1, 6, 215, 195)
			Teleport(indexplayer2, 6, 216, 195)
			
		end
		
		
		if #Participantes < 2
		then
			SendMessageGlobal(string.format("[Sistema] O evento não pode iniciar"), 0)
			SendMessageGlobal(string.format("porque vieram menos de 2 players!"), 0)
			
			for i, name in ipairs(Participantes) do 
				local index = Participantes[name]
				local NickRemover = UserGetName(index)
				
				if UserGetConnected(index) ~= 3
				then
					X1Premiado.RemoveUser(NickRemover)
				end
				
				Teleport(Participantes[name], 0, 125, 125)
				
			end
			
			started = false
			ComandoOn = false
			
			if timer_finish ~= nil
			then
				Timer.Cancel(timer_finish)
				timer_finish = nil
			end
			
			if timer_vivos ~= nil
			then
				Timer.Cancel(timer_vivos)
				timer_vivos = nil
			end
			
			if timer_contar ~= nil
			then
				Timer.Cancel(timer_contar)
				timer_contar = nil
			end
			
			if timer_contar2 ~= nil
			then
				Timer.Cancel(timer_contar2)
				timer_contar2 = nil
			end
			
			if timer_andar ~= nil
			then
				Timer.Cancel(timer_andar)
				timer_andar = nil
			end
	
			if timer_check ~= nil
			then
				Timer.Cancel(timer_check)
				timer_check = nil
			end
			
			Timer.TimeOut(2, X1Premiado.StatusOFFevent)
			
			return
			
		end	
			
			
			
		if #Participantes >= 2
		then
		
			for i, name in ipairs(Participantes) do 
				local index = Participantes[name]
				local NickRemover = UserGetName(index)
				
				if UserGetConnected(index) ~= 3
				then
					X1Premiado.RemoveUser(NickRemover)
				end
				
				DataBase.SetValue("Character", "eventoaguardehit", 1, "Name", UserGetName(index)) -- add participando evento aguarde hit
			
			end

			
		end
		
		SendMessageGlobal(string.format("Move %s fechou!", "/x1premiado"), 0)
		SendMessageGlobal(string.format("Aguarde o próximo evento."), 0)
		
		timer_contar = Timer.TimeOut(5, X1Premiado.Contagem)
		
	else
		SendMessageGlobal(string.format("[Sistema] Move %s fecha em %d segundo(s)", "/x1premiado", timer), 0)
		timer = timer - 1
	end
	
end



function X1Premiado.Contagem()

	if started == false
	then
		return
	end
	
	SendMessageGlobal(string.format("[X1 Premiado]"), 0)
	SendMessageGlobal(string.format("<~~ %s [vs] %s  ~~>", player1, player2), 0)
	timer_contar2 = Timer.TimeOut(5, X1Premiado.Contagem2)
	timer_andar = Timer.Interval(1, X1Premiado.CheckAndar)

end


function X1Premiado.Contagem2()

	if started == false
	then
		return
	end
	
	SendMessageGlobal(string.format("[Sistema]"), 0)
	SendMessageGlobal(string.format("ATENÇÃO - JAH!!!"), 0)

	for i, name in ipairs(Participantes) do 
		local index = Participantes[name]
		local NickRemover = UserGetName(index)
				
		if UserGetConnected(index) ~= 3
		then
			X1Premiado.RemoveUser(NickRemover)
		end
		
		DataBase.SetValue("Character", "eventoaguardehit", 0, "Name", UserGetName(index)) -- remover participando evento aguarde hit
			
	end

end


function X1Premiado.CheckAndar()

	if started == false
	then
		return
	end
	
	for i, name in ipairs(Participantes) do 
		local index = Participantes[name]
		local NickRemover = UserGetName(index)
				
		-- player 1 andou
		if UserGetName(index) == player1
		then
			if UserGetMapNumber(index) == 6 and UserGetX(index) == 215 and UserGetY(index) == 195
			then
				--
			else
				local nomePlayer = player1
				X1Premiado.AnunciarAndou(nomePlayer)
				Teleport(Participantes[name], 0, 125, 125)
			end
		end
		
		-- player 2 andou
		if UserGetName(index) == player2
		then
			if UserGetMapNumber(index) == 6 and UserGetX(index) == 216 and UserGetY(index) == 195
			then
				--
			else
				local nomePlayer = player2
				X1Premiado.AnunciarAndou(nomePlayer)
				Teleport(Participantes[name], 0, 125, 125)
			end
		end
		
		
	end

end



function X1Premiado.AnunciarAndou(nomePlayer)

	if started == false
	then
		return
	end
	
	SendMessageGlobal(string.format("[X1 Premiado] %s andou!", nomePlayer), 0)
	
	if timer_andar ~= nil
	then
		Timer.Cancel(timer_andar)
		timer_andar = nil
	end
	
end



function X1Premiado.CommandOpen(aIndex, Arguments)
	
	if UserGetAuthority(aIndex) == 1
	then
		return
	end
	
	timer_check = nil
	timer_finish = nil
	timer_vivos = nil
	timer_contar = nil
	timer_contar2 = nil
	timer_andar	= nil
	gm = UserGetName(aIndex)
	player1 = ''
	player2 = ''
	
	Players = {}
	Participantes = {}
	
	timer = CommandGetNumber(Arguments, 1)
	
	if timer == 0
	then
		SendMessage(string.format("[Sistema] Uso %s tempo", "/abrirx1premiado"), aIndex, 1)
		return
	end
	
	if timer > 30
	then
		SendMessage(string.format("[Sistema] O tempo máximo para abrir é de 30 segundos!"), aIndex, 1)
		return
	end
	
	Map = 6
	CoordX = 215
	CoordY = 195
	
	started = false
	ComandoOn = true
	
	DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
	
	idtimer = Timer.Repeater(1, timer, X1Premiado.Running)
	
	Teleport(aIndex, Map, 216, 192)
	
	SendMessageGlobal(string.format("[Sistema] %s abriu %s", UserGetName(aIndex), "/x1premiado"), 1)
	
end

function X1Premiado.CommandGo(aIndex, Arguments)

	if UserGetAuthority(aIndex) ~= 1
	then
		SendMessage(string.format("[Sistema] STAFFERs não podem participar de eventos!"), aIndex, 1)
		return
	end
	
	if ComandoOn == false
	then
		SendMessage(string.format("[Sistema] X1 Premiado não está aberto neste momento."), aIndex, 1)
		return
	end
	
	if UserGetLevel(aIndex) < 100
	then
		SendMessage(string.format("[Sistema] Você precisa estar acima do level %d", 100), aIndex, 1)
		return
	end
	
	if UserGetDbClass(aIndex) == 17 or UserGetDbClass(aIndex) == 64
	then
		--
	else
		SendMessage(string.format("[Sistema] Somente BKs e DLs podem ir neste evento!"), aIndex, 1)
		return
	end
	
	local Name = UserGetName(aIndex)

	if DataBase.GetValue(TABLE_RESET, COLUMN_RESET[0], WHERE_RESET, Name) < 0
	then
		SendMessage(string.format("[Sistema] Você precisa de %d resets", 0), aIndex, 1)
		return
	end
	
	if DataBase.GetValue(TABLE_MRESET, COLUMN_MRESET[0], WHERE_MRESET, Name) < 0
	then
		SendMessage(string.format("[Sistema] Você precisa de %d MRs", 0), aIndex, 1)
		return
	end
	
	
	if Players[UserGetName(aIndex)] == nil
	then
	
		if #Players == 2
		then
			SendMessage(string.format("[Sistema] Desculpe, mas o evento já atingiu o limite de 2 participantes."), aIndex, 1)
			return
		end
		
		if #Players < 1
		then
			player1 = UserGetName(aIndex)
			
		elseif #Players == 1
		then
			player2 = UserGetName(aIndex)
		
		end
	
	
		InsertKey(Players, UserGetName(aIndex))
		
		Players[UserGetName(aIndex)] = aIndex
		
		SendMessage(string.format("[Sistema] Você será movido em alguns segundos..."), aIndex, 1)
		SendMessage(string.format("Não relogue, não mova ou será eliminado"), aIndex, 1)
		DataBase.SetValue("Character", "eventomove", 1, "Name", UserGetName(aIndex)) -- add participando evento Move
	else
		SendMessage(string.format("[Sistema] Você será movido em alguns segundos..."), aIndex, 1)
		DataBase.SetValue("Character", "eventomove", 1, "Name", UserGetName(aIndex)) -- add participando evento Move
	end
	
end


function X1Premiado.Morte(aIndex, TargetIndex)

	if started == false
	then
		return
	end
	
	
	if Participantes[UserGetName(aIndex)] == nil or Participantes[UserGetName(TargetIndex)] == nil
	then
		--
	else
		SendMessage(string.format("[X1 Premiado] Você matou %s", UserGetName(TargetIndex)), aIndex, 1)
		SendMessage(string.format("[X1 Premiado] %s matou você!", UserGetName(aIndex)), TargetIndex, 1)
		Teleport(TargetIndex, 0, 125, 125)
		local nomeRemover = UserGetName(TargetIndex)
		X1Premiado.RemoveUser(nomeRemover)
		X1Premiado.CheckVivos()
	end
	

end



function X1Premiado.RemoveUser(Name)
	for i, key in ipairs(Participantes) do
		if key == Name
		then
			table.remove(Participantes, i)
		end
	end
end

function X1Premiado.RemoveUserPlayers(Name)
	for i, key in ipairs(Players) do
		if key == Name
		then
			table.remove(Players, i)
		end
	end
end


function X1Premiado.StatusOFFevent()

	DataBase.SetValue3("EVENTO_AUTO", "status", 0) -- OFF
	
	-- sortear evento
	evento = math.random (1, 16)
	
	if evento == 1
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "Sobrevivencia")
		
	elseif evento == 2
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "Resta 1")
		
	elseif evento == 3
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "Corrida da Morte")
		
	elseif evento == 4
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "X1 Premiado")
		
	elseif evento == 5
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "Quiz X4")
		
	elseif evento == 6
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "Rebeliao")
		
	elseif evento == 7
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "Mata-Mata")
		
	elseif evento == 8
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "Time X Time")
		
	elseif evento == 9
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "PKs vs Heros")
		
	elseif evento == 10
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "Trade Wins")
		
	elseif evento == 11
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "Caca ao Tesouro")
		
	elseif evento == 12
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "Esconde-Esconde")
		
	elseif evento == 13
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "The Flash")
		
	elseif evento == 14
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "Moveu Achou")
		
	elseif evento == 15
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "Mata-Mata")
		
	elseif evento == 16
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "Mata-Mata")
	
	
	
	
		
	end

end



Commands.Register("/abrirx1premiado", X1Premiado.CommandOpen)
Commands.Register("/x1premiado", X1Premiado.CommandGo)
GameServerFunctions.PlayerDie(X1Premiado.Morte)

X1Premiado.TimerEvento()

return X1Premiado
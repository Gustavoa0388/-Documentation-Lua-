--[[
Sistema de evento in-game 
]]--

QuizX4 = {}

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
local gm = ''
local player1 = ''
local player2 = ''
local player3 = ''
local player4 = ''



function QuizX4.TimerEvento()

	Timer.Interval(30, QuizX4.Init)
end

function QuizX4.Init()

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
		
		if os.date("%X") == HORARIO_QUIZX4 or os.date("%X") == HORARIO_QUIZX42 or os.date("%X") == HORARIO_QUIZX43
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			QuizX4.CommandOpen_Auto()
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

		if EventoEscolhido == 'Quiz X4'
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			QuizX4.CommandOpen_Auto()
		else
			return
		end
	
	
	end
	
end



function QuizX4.CommandOpen_Auto()
	
	timer_check = nil
	timer_finish = nil
	timer_vivos = nil
	timer_contar = nil
	timer_contar2 = nil
	gm = ''
	player1 = ''
	player2 = ''
	player3 = ''
	player4 = ''

	Players = {}
	Participantes = {}
	
	timer = 30
	
	Map = 2
	CoordX = 226
	CoordY = 229
	
	started = false
	ComandoOn = true
	
	idtimer = Timer.Repeater(1, timer, QuizX4.Running)
	
	SendMessageGlobal(string.format("[Sistema] Evento Quiz X4!"), 0)
	SendMessageGlobal(string.format("Digite: /quizx4 para vir."), 0)
	
end




function QuizX4.CheckUser()

	if started == false
	then
		return
	end

	for i, name in ipairs(Participantes) do 
		local index = Participantes[name]
		local NickRemover = UserGetName(index)
			
		if UserGetConnected(index) ~= 3
		then
			QuizX4.RemoveUser(i)
			QuizX4.CheckVivos()
		end
		
		if UserGetMapNumber(index) ~= Map
		then
			QuizX4.RemoveUser(NickRemover)
			QuizX4.CheckVivos()
		end
		
		
		if UserGetMapNumber(index) == Map
		then
			if UserGetX(index) < 218 and UserGetY(index) < 225 or UserGetX(index) > 231 and UserGetY(index) > 238
			then
				SendMessage(string.format("[Sistema] Você saiu do evento!"), index, 1)
				Teleport(index, 0, 125, 125)
				QuizX4.RemoveUser(NickRemover)
			end
		end
	
		
	end
	
	
end


function QuizX4.CheckVivos()

	if started == false
	then
		return
	end

	if #Participantes == 1
	then
		
		QuizX4.FinishEvent()
	
	end
		
end


function QuizX4.FinishEvent()

	SendMessageGlobal(string.format("[Sistema] Quiz X4 finalizado!"), 0)
	
	if #Participantes >= 2 or #Participantes < 1
	then
	
		SendMessageGlobal(string.format("(Os players demoraram para se matar ou todos saíram do mapa/jogo)."), 0)
		
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name]
			local NickRemover = UserGetName(index)
				
			if UserGetConnected(index) ~= 3
			then
				QuizX4.RemoveUser(NickRemover)
			end
				
			Teleport(Participantes[name], 0, 125, 125)
				
		end
		
		
	elseif #Participantes == 1
	then
	
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name]
			SendMessageGlobal(string.format("Vencedor: %s", UserGetName(index)), 0)
			
			
			
			
				
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(index))
			DataBase.SetAddValue("Character", COLUNA_QUIZX4, PONTOS_EVENTINHOS, "Name", UserGetName(index))
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

	if timer_check ~= nil
	then
		Timer.Cancel(timer_check)
		timer_check = nil
	end
	
	Timer.TimeOut(2, QuizX4.StatusOFFevent)
	
end



function QuizX4.Running()

	if timer == 0
	then
		
		timer_check = Timer.Interval(2, QuizX4.CheckUser)
		timer_vivos = Timer.Interval(3, QuizX4.CheckVivos)
		timer_finish = Timer.TimeOut(5 * 60, QuizX4.FinishEvent)
		
		started = true
		ComandoOn = false
		
		
		for i, name in ipairs(Players) do 
			local index = Players[name]
			local NickRemover = UserGetName(index)
			
			if UserGetConnected(index) ~= 3
			then
				QuizX4.RemoveUserPlayers(NickRemover)
			end
			
			InsertKey(Participantes, UserGetName(index))
			Participantes[UserGetName(index)] = index
			DataBase.SetValue("Character", "eventomove", 0, "Name", UserGetName(index)) -- remover participando evento move
			
			Teleport(Participantes[name], Map, CoordX, CoordY)
			
		end
		
		
		if #Participantes < 4
		then
			SendMessageGlobal(string.format("[Sistema] O evento não pode iniciar"), 0)
			SendMessageGlobal(string.format("porque vieram menos de 4 players!"), 0)
			
			for i, name in ipairs(Participantes) do 
				local index = Participantes[name]
				local NickRemover = UserGetName(index)
				
				if UserGetConnected(index) ~= 3
				then
					QuizX4.RemoveUser(NickRemover)
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
			
			if timer_check ~= nil
			then
				Timer.Cancel(timer_check)
				timer_check = nil
			end
			
			Timer.TimeOut(2, QuizX4.StatusOFFevent)
			
			return
			
		end	
			
			
			
		if #Participantes >= 2
		then
		
			for i, name in ipairs(Participantes) do 
				local index = Participantes[name]
				local NickRemover = UserGetName(index)
				
				if UserGetConnected(index) ~= 3
				then
					QuizX4.RemoveUser(NickRemover)
				end
				
				DataBase.SetValue("Character", "eventoaguardehit", 1, "Name", UserGetName(index)) -- add participando evento aguarde hit
			
			end

			
		end
		
		SendMessageGlobal(string.format("Move %s fechou!", "/quizx4"), 0)
		SendMessageGlobal(string.format("Aguarde o próximo evento."), 0)
		
		timer_contar = Timer.TimeOut(5, QuizX4.Contagem)
		
	else
		SendMessageGlobal(string.format("[Sistema] Move %s fecha em %d segundo(s)", "/quizx4", timer), 0)
		timer = timer - 1
	end
	
end



function QuizX4.Contagem()

	if started == false
	then
		return
	end
	
	SendMessageGlobal(string.format(" "), 0)
	SendMessageGlobal(string.format("[Quiz X4] Participantes:"), 0)
	SendMessageGlobal(string.format("%s, %s, %s e %s", player1, player2, player3, player4), 0)
	timer_contar2 = Timer.TimeOut(3, QuizX4.Contagem2)

end


function QuizX4.Contagem2()

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
			QuizX4.RemoveUser(NickRemover)
		end
		
		DataBase.SetValue("Character", "eventoaguardehit", 0, "Name", UserGetName(index)) -- remover participando evento aguarde hit
			
	end

end


function QuizX4.CommandOpen(aIndex, Arguments)
	
	if UserGetAuthority(aIndex) == 1
	then
		return
	end

	timer_check = nil
	timer_finish = nil
	timer_vivos = nil
	timer_contar = nil
	timer_contar2 = nil
	gm = UserGetName(aIndex)
	player1 = ''
	player2 = ''
	player3 = ''
	player4 = ''
	
	Players = {}
	Participantes = {}
	
	timer = CommandGetNumber(Arguments, 1)
	
	if timer == 0
	then
		SendMessage(string.format("[Sistema] Uso %s tempo", "/abrirquizx4"), aIndex, 1)
		return
	end
	
	if timer > 30
	then
		SendMessage(string.format("[Sistema] O tempo máximo para abrir é de 30 segundos!"), aIndex, 1)
		return
	end
	
	Map = 2
	CoordX = 226
	CoordY = 229
	
	started = false
	ComandoOn = true
	
	DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
	
	idtimer = Timer.Repeater(1, timer, QuizX4.Running)
	
	Teleport(aIndex, Map, 226, 234)
	
	SendMessageGlobal(string.format("[Sistema] %s abriu %s", UserGetName(aIndex), "/quizx4"), 1)
	
end

function QuizX4.CommandGo(aIndex, Arguments)

	if UserGetAuthority(aIndex) ~= 1
	then
		SendMessage(string.format("[Sistema] STAFFERs não podem participar de eventos!"), aIndex, 1)
		return
	end
	
	if ComandoOn == false
	then
		SendMessage(string.format("[Sistema] Quiz X4 não está aberto neste momento."), aIndex, 1)
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
	
		if #Players == 4
		then
			SendMessage(string.format("[Sistema] Desculpe, mas o evento já atingiu o limite de 4 participantes."), aIndex, 1)
			return
		end
		
		if #Players < 1
		then
			player1 = UserGetName(aIndex)
			
		elseif #Players == 1
		then
			player2 = UserGetName(aIndex)
			
		elseif #Players == 2
		then
			player3 = UserGetName(aIndex)
			
		elseif #Players == 3
		then
			player4 = UserGetName(aIndex)
		
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


function QuizX4.Morte(aIndex, TargetIndex)

	if started == false
	then
		return
	end
	
	
	if Participantes[UserGetName(aIndex)] == nil or Participantes[UserGetName(TargetIndex)] == nil
	then
		--
	else
		SendMessage(string.format("[Quiz X4] Você matou %s", UserGetName(TargetIndex)), aIndex, 1)
		SendMessage(string.format("[Quiz X4] %s matou você!", UserGetName(aIndex)), TargetIndex, 1)
		
		SendMessageGlobal(string.format("[Quiz X4] %s matou %s", UserGetName(aIndex), UserGetName(TargetIndex)), 0)
		
		--Teleport(TargetIndex, 0, 125, 125)
		local nomeRemover = UserGetName(TargetIndex)
		QuizX4.RemoveUser(nomeRemover)
		QuizX4.CheckVivos()
	end
	

end



function QuizX4.RemoveUser(Name)
	for i, key in ipairs(Participantes) do
		if key == Name
		then
			table.remove(Participantes, i)
		end
	end
end

function QuizX4.RemoveUserPlayers(Name)
	for i, key in ipairs(Players) do
		if key == Name
		then
			table.remove(Players, i)
		end
	end
end


function QuizX4.StatusOFFevent()

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


Commands.Register("/abrirquizx4", QuizX4.CommandOpen)
Commands.Register("/quizx4", QuizX4.CommandGo)
GameServerFunctions.PlayerDie(QuizX4.Morte)

QuizX4.TimerEvento()

return QuizX4
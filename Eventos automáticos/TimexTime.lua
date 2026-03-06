--[[
Sistema de evento in-game 
]]--

TimexTime = {}

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
local player5 = ''
local player6 = ''
local player1_morto = false
local player2_morto = false
local player3_morto = false
local player4_morto = false
local player5_morto = false
local player6_morto = false


function TimexTime.TimerEvento()

	Timer.Interval(30, TimexTime.Init)
end

function TimexTime.Init()

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
		
		if os.date("%X") == HORARIO_TIMEXTIME or os.date("%X") == HORARIO_TIMEXTIME2 or os.date("%X") == HORARIO_TIMEXTIME3
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			TimexTime.CommandOpen_Auto()
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

		if EventoEscolhido == 'Time X Time'
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			TimexTime.CommandOpen_Auto()
		else
			return
		end
		
		
	end
	
	
end



function TimexTime.CommandOpen_Auto()
	
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
	player5 = ''
	player6 = ''
	player1_morto = false
	player2_morto = false
	player3_morto = false
	player4_morto = false
	player5_morto = false
	player6_morto = false

	Players = {}
	Participantes = {}
	
	timer = 30
	
	Map = 2
	CoordX = 226
	CoordY = 229
	
	started = false
	ComandoOn = true
	
	idtimer = Timer.Repeater(1, timer, TimexTime.Running)
	
	SendMessageGlobal(string.format("[Sistema] Evento Time x Time!"), 0)
	SendMessageGlobal(string.format("Digite: /timextime para vir."), 0)
	
end




function TimexTime.CheckUser()

	if started == false
	then
		return
	end

	for i, name in ipairs(Participantes) do 
		local index = Participantes[name]
		local NickRemover = UserGetName(index)
			
		if UserGetConnected(index) ~= 3
		then
			TimexTime.RemoveUser(i)
			
			if UserGetName(index) == player1
			then
				player1_morto = true
				
			elseif UserGetName(index) == player2
			then
				player2_morto = true
				
			elseif UserGetName(index) == player3
			then
				player3_morto = true
				
			elseif UserGetName(index) == player4
			then
				player4_morto = true
				
			elseif UserGetName(index) == player5
			then
				player5_morto = true
				
			elseif UserGetName(index) == player6
			then
				player6_morto = true
				
				
			end
			
			TimexTime.CheckVivos()
		
		end
		
		
		if UserGetMapNumber(index) ~= Map
		then
			TimexTime.RemoveUser(NickRemover)
			
			if UserGetName(index) == player1
			then
				player1_morto = true
				
			elseif UserGetName(index) == player2
			then
				player2_morto = true
				
			elseif UserGetName(index) == player3
			then
				player3_morto = true
				
			elseif UserGetName(index) == player4
			then
				player4_morto = true
				
			elseif UserGetName(index) == player5
			then
				player5_morto = true
				
			elseif UserGetName(index) == player6
			then
				player6_morto = true
				
				
			end
			
			
			TimexTime.CheckVivos()
			
			
		end
		
		
		if UserGetMapNumber(index) == Map
		then
			if UserGetX(index) < 210 and UserGetY(index) < 209 or UserGetX(index) > 242 and UserGetY(index) > 237
			then
				SendMessage(string.format("[Sistema] Você saiu do evento!"), index, 1)
				Teleport(index, 0, 125, 125)
				
				TimexTime.RemoveUser(NickRemover)
			
				if UserGetName(index) == player1
				then
					player1_morto = true
					
				elseif UserGetName(index) == player2
				then
					player2_morto = true
					
				elseif UserGetName(index) == player3
				then
					player3_morto = true
					
				elseif UserGetName(index) == player4
				then
					player4_morto = true
					
				elseif UserGetName(index) == player5
				then
					player5_morto = true
					
				elseif UserGetName(index) == player6
				then
					player6_morto = true
					
					
				end
				

				TimexTime.CheckVivos()
				
			end
		end
	
		
	end
	
	
end


function TimexTime.CheckVivos()

	if started == false
	then
		return
	end

	if player1_morto == true and player2_morto == true and player3_morto == true or player4_morto == true and player5_morto == true and player6_morto == true
	then
		TimexTime.FinishEvent()
	end
		
end


function TimexTime.FinishEvent()

	SendMessageGlobal(string.format("[Sistema] Time x Time finalizado!"), 0)
	
	if #Participantes < 1 or player1_morto == true and player2_morto == true and player3_morto == true and player4_morto == true and player5_morto == true and player6_morto == true
	then
	
		SendMessageGlobal(string.format("(Os players demoraram para se matar ou todos saíram do mapa/jogo)."), 0)
		
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name]
			local NickRemover = UserGetName(index)
				
			if UserGetConnected(index) ~= 3
			then
				TimexTime.RemoveUser(NickRemover)
			end
				
			Teleport(Participantes[name], 0, 125, 125)
		
		end
		
		
	elseif #Participantes == 1
	then
	
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name]

			if UserGetName(index) == player1 or UserGetName(index) == player2 or UserGetName(index) == player3
			then
				SendMessageGlobal(string.format("Time (A) Winner!"), 0)
				local TimeVencedor = "A"
			else
				SendMessageGlobal(string.format("Time (B) Winner!"), 0)
				local TimeVencedor = "B"
			end
			
			Teleport(index, 0, 125, 125)

		end
		
		
		SendMessageGlobal(string.format("~> Prêmios adicionados! <~"), 0)
		
		

			
		-- add prêmio do time
		if TimeVencedor == "A"
		then
			local indexDoPlayer1 = GetIndex(player1)
			local indexDoPlayer2 = GetIndex(player2)
			local indexDoPlayer3 = GetIndex(player3)
				
			
					
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(indexDoPlayer1))
			DataBase.SetAddValue("Character", COLUNA_TIMEXTIME, PONTOS_EVENTINHOS, "Name", UserGetName(indexDoPlayer1))
				
			-- pontos eventos total
			DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(indexDoPlayer1))
			DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(indexDoPlayer1))
			DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(indexDoPlayer1))
			
			
			
				
				
			
					
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(indexDoPlayer2))
			DataBase.SetAddValue("Character", COLUNA_TIMEXTIME, PONTOS_EVENTINHOS, "Name", UserGetName(indexDoPlayer2))
				
			-- pontos eventos total
			DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(indexDoPlayer2))
			DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(indexDoPlayer2))
			DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(indexDoPlayer2))
			
			
			
			
			
					
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(indexDoPlayer3))
			DataBase.SetAddValue("Character", COLUNA_TIMEXTIME, PONTOS_EVENTINHOS, "Name", UserGetName(indexDoPlayer3))
			
			-- pontos eventos total
			DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(indexDoPlayer3))
			DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(indexDoPlayer3))
			DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(indexDoPlayer3))
			
			
			
			
			
		elseif TimeVencedor == "B"
		then
			local indexDoPlayer1 = GetIndex(player4)
			local indexDoPlayer2 = GetIndex(player5)
			local indexDoPlayer3 = GetIndex(player6)
				
			
			
			
					
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(indexDoPlayer1))
			DataBase.SetAddValue("Character", COLUNA_TIMEXTIME, PONTOS_EVENTINHOS, "Name", UserGetName(indexDoPlayer1))
				
			-- pontos eventos total
			DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(indexDoPlayer1))
			DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(indexDoPlayer1))
			DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(indexDoPlayer1))
			
			
			
			
				
			
					
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(indexDoPlayer2))
			DataBase.SetAddValue("Character", COLUNA_TIMEXTIME, PONTOS_EVENTINHOS, "Name", UserGetName(indexDoPlayer2))
				
			-- pontos eventos total
			DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(indexDoPlayer2))
			DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(indexDoPlayer2))
			DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(indexDoPlayer2))
			
			
			
			
				
			
					
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(indexDoPlayer3))
			DataBase.SetAddValue("Character", COLUNA_TIMEXTIME, PONTOS_EVENTINHOS, "Name", UserGetName(indexDoPlayer3))
				
			-- pontos eventos total
			DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(indexDoPlayer3))
			DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(indexDoPlayer3))
			DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(indexDoPlayer3))
			
			
			
			
			
			
			
			
		end
		
		
	-- vitória time A
	elseif player4_morto == true and player5_morto == true and player6_morto == true
	then
	
		SendMessageGlobal(string.format("Time (A) Winner!"), 0)
		
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name]		
			Teleport(index, 0, 125, 125)
		end
			
		SendMessageGlobal(string.format("~> Prêmios adicionados! <~"), 0)
		
		
			
		-- add prêmio do time
		local indexDoPlayer1 = GetIndex(player1)
		local indexDoPlayer2 = GetIndex(player2)
		local indexDoPlayer3 = GetIndex(player3)

	
		DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(indexDoPlayer1))
		DataBase.SetAddValue("Character", COLUNA_TIMEXTIME, PONTOS_EVENTINHOS, "Name", UserGetName(indexDoPlayer1))		
				
		-- pontos eventos total
		DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(indexDoPlayer1))
		DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(indexDoPlayer1))
		DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(indexDoPlayer1))
			
		

		-- player 2
					
		DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(indexDoPlayer2))
		DataBase.SetAddValue("Character", COLUNA_TIMEXTIME, PONTOS_EVENTINHOS, "Name", UserGetName(indexDoPlayer2))
				
		-- pontos eventos total
		DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(indexDoPlayer2))
		DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(indexDoPlayer2))
		DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(indexDoPlayer2))
			
				
		-- player 3
		
		DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(indexDoPlayer3))
		DataBase.SetAddValue("Character", COLUNA_TIMEXTIME, PONTOS_EVENTINHOS, "Name", UserGetName(indexDoPlayer3))
			
		-- pontos eventos total
		DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(indexDoPlayer3))
		DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(indexDoPlayer3))
		DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(indexDoPlayer3))
			
			
			
		
		
	-- vitória time B
	elseif player1_morto == true and player2_morto == true and player3_morto == true
	then
	
		SendMessageGlobal(string.format("Time (B) Winner!"), 0)
		
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name]		
			Teleport(index, 0, 125, 125)
		end
			
		SendMessageGlobal(string.format("~> Prêmios adicionados! <~"), 0)
		
		
			
		-- add prêmio do time
		local indexDoPlayer1 = GetIndex(player4)
		local indexDoPlayer2 = GetIndex(player5)
		local indexDoPlayer3 = GetIndex(player6)
				
		-- player 1
					
		DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(indexDoPlayer1))
		DataBase.SetAddValue("Character", COLUNA_TIMEXTIME, PONTOS_EVENTINHOS, "Name", UserGetName(indexDoPlayer1))
				
		-- pontos eventos total
		DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(indexDoPlayer1))
		DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(indexDoPlayer1))
		DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(indexDoPlayer1))
			
		
				
		-- player 2
		
		DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(indexDoPlayer2))
		DataBase.SetAddValue("Character", COLUNA_TIMEXTIME, PONTOS_EVENTINHOS, "Name", UserGetName(indexDoPlayer2))
						
		-- pontos eventos total
		DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(indexDoPlayer2))
		DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(indexDoPlayer2))
		DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(indexDoPlayer2))
			


		
		-- player 3
		
		DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(indexDoPlayer3))
		DataBase.SetAddValue("Character", COLUNA_TIMEXTIME, PONTOS_EVENTINHOS, "Name", UserGetName(indexDoPlayer3))
		
		-- pontos eventos total
		DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(indexDoPlayer3))
		DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(indexDoPlayer3))
		DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(indexDoPlayer3))

		
		
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
	
	Timer.TimeOut(2, TimexTime.StatusOFFevent)
	
end



function TimexTime.Running()

	if timer == 0
	then
		
		timer_check = Timer.Interval(2, TimexTime.CheckUser)
		timer_vivos = Timer.Interval(3, TimexTime.CheckVivos)
		timer_finish = Timer.TimeOut(5 * 60, TimexTime.FinishEvent)
		
		started = true
		ComandoOn = false
		
		
		for i, name in ipairs(Players) do 
			local index = Players[name]
			local NickRemover = UserGetName(index)
			
			if UserGetConnected(index) ~= 3
			then
				TimexTime.RemoveUserPlayers(NickRemover)
			end
			
			InsertKey(Participantes, UserGetName(index))
			Participantes[UserGetName(index)] = index
			DataBase.SetValue("Character", "eventomove", 0, "Name", UserGetName(index)) -- remover participando evento move
		
			local indexPlayer1 = GetIndex(player1)
			local indexPlayer2 = GetIndex(player2)
			local indexPlayer3 = GetIndex(player3)
			local indexPlayer4 = GetIndex(player4)
			local indexPlayer5 = GetIndex(player5)
			local indexPlayer6 = GetIndex(player6)
			
			-- Mover Time A
			Teleport(indexPlayer1, 2, 225, 226)
			Teleport(indexPlayer2, 2, 226, 226)
			Teleport(indexPlayer3, 2, 227, 226)
			
			-- Mover Time B
			Teleport(indexPlayer4, 2, 225, 232)
			Teleport(indexPlayer5, 2, 226, 232)
			Teleport(indexPlayer6, 2, 227, 232)
			
		
		end
		
		
		if #Participantes < 6
		then
			SendMessageGlobal(string.format("[Sistema] O evento não pode iniciar"), 0)
			SendMessageGlobal(string.format("porque vieram menos de 6 players!"), 0)
			
			for i, name in ipairs(Participantes) do 
				local index = Participantes[name]
				local NickRemover = UserGetName(index)
				
				if UserGetConnected(index) ~= 3
				then
					TimexTime.RemoveUser(NickRemover)
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
			
			Timer.TimeOut(2, TimexTime.StatusOFFevent)
			
			return
			
		end	
			
			
			
		if #Participantes >= 2
		then
		
			for i, name in ipairs(Participantes) do 
				local index = Participantes[name]
				local NickRemover = UserGetName(index)
				
				if UserGetConnected(index) ~= 3
				then
					TimexTime.RemoveUser(NickRemover)
				end
				
				DataBase.SetValue("Character", "eventoaguardehit", 1, "Name", UserGetName(index)) -- add participando evento aguarde hit
			
			end

			
		end
		
		SendMessageGlobal(string.format("Move %s fechou!", "/timextime"), 0)
		SendMessageGlobal(string.format("Aguarde o próximo evento."), 0)
		
		timer_contar = Timer.TimeOut(5, TimexTime.Contagem)
		
	else
		SendMessageGlobal(string.format("[Sistema] Move %s fecha em %d segundo(s)", "/timextime", timer), 0)
		timer = timer - 1
	end
	
end



function TimexTime.Contagem()

	if started == false
	then
		return
	end
	
	SendMessageGlobal(string.format(" "), 0)
	SendMessageGlobal(string.format("[Time x Time]"), 0)
	SendMessageGlobal(string.format("Time (A): %s, %s e %s", player1, player2, player3), 0)
	SendMessageGlobal(string.format("Time (B): %s, %s e %s", player4, player5, player6), 0)
	timer_contar2 = Timer.TimeOut(10, TimexTime.Contagem2)

end


function TimexTime.Contagem2()

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
			TimexTime.RemoveUser(NickRemover)
		end
		
		DataBase.SetValue("Character", "eventoaguardehit", 0, "Name", UserGetName(index)) -- remover participando evento aguarde hit
			
	end

end


function TimexTime.CommandOpen(aIndex, Arguments)
	
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
	player5 = ''
	player6 = ''
	player1_morto = false
	player2_morto = false
	player3_morto = false
	player4_morto = false
	player5_morto = false
	player6_morto = false
	
	Players = {}
	Participantes = {}
	
	timer = CommandGetNumber(Arguments, 1)
	
	if timer == 0
	then
		SendMessage(string.format("[Sistema] Uso %s tempo", "/abrirtimextime"), aIndex, 1)
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
	
	idtimer = Timer.Repeater(1, timer, TimexTime.Running)
	
	Teleport(aIndex, Map, CoordX, CoordY)
	
	SendMessageGlobal(string.format("[Sistema] %s abriu %s", UserGetName(aIndex), "/timextime"), 1)
	
end

function TimexTime.CommandGo(aIndex, Arguments)

	if UserGetAuthority(aIndex) ~= 1
	then
		SendMessage(string.format("[Sistema] STAFFERs não podem participar de eventos!"), aIndex, 1)
		return
	end
	
	if ComandoOn == false
	then
		SendMessage(string.format("[Sistema] Time x Time não está aberto neste momento."), aIndex, 1)
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
	
		if #Players == 6
		then
			SendMessage(string.format("[Sistema] Desculpe, mas o evento já atingiu o limite de 6 participantes."), aIndex, 1)
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
			
		elseif #Players == 4
		then
			player5 = UserGetName(aIndex)
			
		elseif #Players == 5
		then
			player6 = UserGetName(aIndex)
		
		end
		
		
		InsertKey(Players, UserGetName(aIndex))
		
		Players[UserGetName(aIndex)] = aIndex
		
		
		SendMessage(string.format("[Sistema] Você será movido em alguns segundos..."), aIndex, 1)
		
		if UserGetName(aIndex) == player1 or UserGetName(aIndex) == player2 or UserGetName(aIndex) == player3
		then
			SendMessage(string.format("--> Seu time é: A"), aIndex, 1)
		else
			SendMessage(string.format("--> Seu time é: B"), aIndex, 1)
		end
		
		DataBase.SetValue("Character", "eventomove", 1, "Name", UserGetName(aIndex)) -- add participando evento Move
		
	else
	
		SendMessage(string.format("[Sistema] Você será movido em alguns segundos..."), aIndex, 1)
		
		if UserGetName(aIndex) == player1 or UserGetName(aIndex) == player2 or UserGetName(aIndex) == player3
		then
			SendMessage(string.format("--> Seu time é: A"), aIndex, 1)
		else
			SendMessage(string.format("--> Seu time é: B"), aIndex, 1)
		end
		
		DataBase.SetValue("Character", "eventomove", 1, "Name", UserGetName(aIndex)) -- add participando evento Move
		
	end
	
end


function TimexTime.AtacarMesmoTime(aIndex, TargetIndex)

	if started == false
	then
		return
	end
	
	
	if Participantes[UserGetName(aIndex)] == nil or Participantes[UserGetName(TargetIndex)] == nil
	then
		--
	else
	
		-- Time A atacar Time A
		if UserGetName(aIndex) == player1 or UserGetName(aIndex) == player2 or UserGetName(aIndex) == player3
		then
			if UserGetName(TargetIndex) == player1 or UserGetName(TargetIndex) == player2 or UserGetName(TargetIndex) == player3
			then
				SendMessage(string.format("[Time x Time] Você não pode atacar players do seu Time!"), aIndex, 1)
				return 1
				
			end
		end
		
		-- Time B atacar Time B
		if UserGetName(aIndex) == player4 or UserGetName(aIndex) == player5 or UserGetName(aIndex) == player6
		then
			if UserGetName(TargetIndex) == player4 or UserGetName(TargetIndex) == player5 or UserGetName(TargetIndex) == player6
			then
				SendMessage(string.format("[Time x Time] Você não pode atacar players do seu Time!"), aIndex, 1)
				return 1
				
			end
		end
	
	
	
	end
		
		
end



function TimexTime.Morte(aIndex, TargetIndex)

	if started == false
	then
		return
	end
	
	
	if Participantes[UserGetName(aIndex)] == nil or Participantes[UserGetName(TargetIndex)] == nil
	then
		--
	else
	
		SendMessage(string.format("[Time x Time] Você matou %s", UserGetName(TargetIndex)), aIndex, 1)
		SendMessage(string.format("[Time x Time] %s matou você!", UserGetName(aIndex)), TargetIndex, 1)
		
		if UserGetName(aIndex) == player1 or UserGetName(aIndex) == player2 or UserGetName(aIndex) == player3
		then
			SendMessageGlobal(string.format("[Time x Time] %s matou %s", UserGetName(aIndex), UserGetName(TargetIndex)), 0)
		else
			SendMessageGlobal(string.format("[Time x Time] %s matou %s", UserGetName(aIndex), UserGetName(TargetIndex)), 0)
		end
		
		Teleport(TargetIndex, 0, 125, 125)
		local nomeRemover = UserGetName(TargetIndex)
		TimexTime.RemoveUser(nomeRemover)
		
		if UserGetName(TargetIndex) == player1
		then
			player1_morto = true
				
		elseif UserGetName(TargetIndex) == player2
		then
			player2_morto = true
				
		elseif UserGetName(TargetIndex) == player3
		then
			player3_morto = true
				
		elseif UserGetName(TargetIndex) == player4
		then
			player4_morto = true
				
		elseif UserGetName(TargetIndex) == player5
		then
			player5_morto = true
				
		elseif UserGetName(TargetIndex) == player6
		then
			player6_morto = true
			
				
		end
		
		TimexTime.CheckVivos()
		
	end
	

end



function TimexTime.RemoveUser(Name)
	for i, key in ipairs(Participantes) do
		if key == Name
		then
			table.remove(Participantes, i)
		end
	end
end

function TimexTime.RemoveUserPlayers(Name)
	for i, key in ipairs(Players) do
		if key == Name
		then
			table.remove(Players, i)
		end
	end
end


function TimexTime.StatusOFFevent()

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



Commands.Register("/abrirtimextime", TimexTime.CommandOpen)
Commands.Register("/timextime", TimexTime.CommandGo)
GameServerFunctions.PlayerDie(TimexTime.Morte)
GameServerFunctions.PlayerAttack(TimexTime.AtacarMesmoTime)

TimexTime.TimerEvento()

return TimexTime
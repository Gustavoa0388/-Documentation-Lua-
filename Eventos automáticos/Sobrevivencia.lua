--[[
Sistema de evento in-game 
]]--

Sobrevivencia = {}

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
local timer_vivos2 = nil
local gm = ''


function Sobrevivencia.TimerEvento()

	Timer.Interval(30, Sobrevivencia.Init)
end

function Sobrevivencia.Init()

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
		
		if os.date("%X") == HORARIO_SOBREVIVENCIA or os.date("%X") == HORARIO_SOBREVIVENCIA2 or os.date("%X") == HORARIO_SOBREVIVENCIA3
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			Sobrevivencia.CommandOpen_Auto()
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

		if EventoEscolhido == 'Sobrevivencia'
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			Sobrevivencia.CommandOpen_Auto()
		else
			return
		end
		
		
	end
	
	
end



function Sobrevivencia.CommandOpen_Auto()
	
	timer_check = nil
	timer_finish = nil
	timer_vivos = nil
	timer_vivos2 = nil
	gm = ''

	Players = {}
	Participantes = {}
	
	timer = 30
	
	Map = 1
	CoordX = 155
	CoordY = 189
	
	started = false
	ComandoOn = true
	
	idtimer = Timer.Repeater(1, timer, Sobrevivencia.Running)
	
	SendMessageGlobal(string.format("[Sistema] Sobrevivência está aberta!"), 1)
	
end




function Sobrevivencia.CheckUser()

	if started == false
	then
		return
	end

	for i, name in ipairs(Participantes) do 
		local index = Participantes[name]
		local NickRemover = UserGetName(index)
			
		if UserGetConnected(index) ~= 3
		then
			Sobrevivencia.RemoveUser(i)
			Sobrevivencia.CheckVivos()
		end
		
		if UserGetMapNumber(index) ~= Map
		then
			Sobrevivencia.RemoveUser(NickRemover)
			Sobrevivencia.CheckVivos()
		end
		
		if UserGetMapNumber(index) == Map
		then
			if UserGetX(index) < 154 and UserGetY(index) < 185 or UserGetX(index) > 156 and UserGetY(index) > 190
			then
				SendMessage(string.format("[Sistema] Você saiu do evento!"), index, 1)
				Teleport(index, 0, 125, 125)
				Sobrevivencia.RemoveUser(NickRemover)
			end
		end
	
		
	end
	
	
end


function Sobrevivencia.CheckVivos()

	if started == false
	then
		return
	end
	
	SendMessageGlobal(string.format("[Sobrevivência] Restam %d players vivos!", #Participantes), 0)
	
	if #Participantes == 1
	then
	
		if timer_vivos2 ~= nil
		then
			Timer.Cancel(timer_vivos2)
			timer_vivos2 = nil
		end
		
		Sobrevivencia.FinishEvent()
	
	end
		
end


function Sobrevivencia.CheckVivos2()

	if started == false
	then
		return
	end
	
	if #Participantes == 1
	then
		Sobrevivencia.FinishEvent()
	end
		
end


function Sobrevivencia.FinishEvent()

	SendMessageGlobal(string.format("[Sistema] Sobrevivência finalizado!"), 0)
	
	if #Participantes >= 2 or #Participantes < 1
	then
	
		SendMessageGlobal(string.format("(Os players demoraram para se matar ou todos saíram do mapa/jogo)."), 0)
		
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name]
			local NickRemover = UserGetName(index)
				
			if UserGetConnected(index) ~= 3
			then
				Sobrevivencia.RemoveUser(NickRemover)
			end
				
			Teleport(Participantes[name], 0, 125, 125)
				
		end
		
		
	elseif #Participantes == 1
	then
	
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name]
			SendMessageGlobal(string.format("Vencedor: %s", UserGetName(index)), 0)
			
			
			
			
				
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(index))
			DataBase.SetAddValue("Character", COLUNA_SOBREVIVENCIA, PONTOS_EVENTINHOS, "Name", UserGetName(index))
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
	
	if timer_vivos2 ~= nil
	then
		Timer.Cancel(timer_vivos2)
		timer_vivos2 = nil
	end
	
	if timer_check ~= nil
	then
		Timer.Cancel(timer_check)
		timer_check = nil
	end
	
	Timer.TimeOut(2, Sobrevivencia.StatusOFFevent)
	
end



function Sobrevivencia.Running()

	if timer == 0
	then
		
		timer_check = Timer.Interval(2, Sobrevivencia.CheckUser)
		timer_vivos = Timer.Interval(15, Sobrevivencia.CheckVivos)
		timer_vivos2 = Timer.Interval(3, Sobrevivencia.CheckVivos2)
		timer_finish = Timer.TimeOut(5 * 60, Sobrevivencia.FinishEvent)
		
		started = true
		ComandoOn = false
		
		
		for i, name in ipairs(Players) do 
			local index = Players[name]
			local NickRemover = UserGetName(index)
			
			if UserGetConnected(index) ~= 3
			then
				Sobrevivencia.RemoveUserPlayers(NickRemover)
			end
			
			InsertKey(Participantes, UserGetName(index))
			Participantes[UserGetName(index)] = index
			DataBase.SetValue("Character", "eventomove", 0, "Name", UserGetName(index)) -- remover participando evento move
			
			UserSetPKLevel(Participantes[name], 6)
			PkLevelSend(Participantes[name], UserGetPKLevel(Participantes[name]))
			
			Teleport(Participantes[name], Map, CoordX, CoordY)
			
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
					Sobrevivencia.RemoveUser(NickRemover)
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
			
			if timer_vivos2 ~= nil
			then
				Timer.Cancel(timer_vivos2)
				timer_vivos2 = nil
			end
			
			if timer_check ~= nil
			then
				Timer.Cancel(timer_check)
				timer_check = nil
			end
			
			Timer.TimeOut(2, Sobrevivencia.StatusOFFevent)
			
			return
			
		end
		
		SendMessageGlobal(string.format("Move %s fechou!", "/sobre"), 0)
		SendMessageGlobal(string.format("Aguarde o próximo evento."), 0)
		Sobrevivencia.CheckVivos()
	else
		SendMessageGlobal(string.format("[Sistema] Move %s fecha em %d segundo(s)", "/sobre", timer), 0)
		timer = timer - 1
	end
	
end

function Sobrevivencia.CommandOpen(aIndex, Arguments)
	
	if UserGetAuthority(aIndex) == 1
	then
		return
	end
	
	timer_check = nil
	timer_finish = nil
	timer_vivos = nil
	timer_vivos2 = nil
	gm = UserGetName(aIndex)
	
	Players = {}
	Participantes = {}
	
	timer = CommandGetNumber(Arguments, 1)
	
	if timer == 0
	then
		SendMessage(string.format("[Sistema] Uso %s tempo", "/abrirsobre"), aIndex, 1)
		return
	end
	
	if timer > 60
	then
		SendMessage(string.format("[Sistema] O tempo máximo para abrir é de 60 segundos!"), aIndex, 1)
		return
	end
	
	Map = 1
	CoordX = 155
	CoordY = 189
	
	started = false
	ComandoOn = true
	
	DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
	
	idtimer = Timer.Repeater(1, timer, Sobrevivencia.Running)
	
	SendMessageGlobal(string.format("[Sistema] %s abriu %s", UserGetName(aIndex), "/sobre"), 1)
	
end

function Sobrevivencia.CommandGo(aIndex, Arguments)

	if UserGetAuthority(aIndex) ~= 1
	then
		SendMessage(string.format("[Sistema] STAFFERs não podem participar de eventos!"), aIndex, 1)
		return
	end
	
	if ComandoOn == false
	then
		SendMessage(string.format("[Sistema] Sobrevivência não está aberto neste momento."), aIndex, 1)
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


function Sobrevivencia.Morte(aIndex, TargetIndex)

	if started == false
	then
		return
	end
	
	
	if Participantes[UserGetName(aIndex)] == nil or Participantes[UserGetName(TargetIndex)] == nil
	then
		--
	else
		SendMessage(string.format("[Sobrevivência] Você matou %s", UserGetName(TargetIndex)), aIndex, 1)
		SendMessage(string.format("[Sobrevivência] %s matou você!", UserGetName(aIndex)), TargetIndex, 1)
		local nomeRemover = UserGetName(TargetIndex)
		Sobrevivencia.RemoveUser(nomeRemover)
		Sobrevivencia.CheckVivos()
	end
	

end



function Sobrevivencia.RemoveUser(Name)
	for i, key in ipairs(Participantes) do
		if key == Name
		then
			table.remove(Participantes, i)
		end
	end
end

function Sobrevivencia.RemoveUserPlayers(Name)
	for i, key in ipairs(Players) do
		if key == Name
		then
			table.remove(Players, i)
		end
	end
end

function Sobrevivencia.StatusOFFevent()

	-- sortear evento
	evento = math.random (1, 16)
	
	DataBase.SetValue3("EVENTO_AUTO", "status", 0) -- OFF
	
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



Commands.Register("/abrirsobre", Sobrevivencia.CommandOpen)
Commands.Register("/sobre", Sobrevivencia.CommandGo)
GameServerFunctions.PlayerDie(Sobrevivencia.Morte)

Sobrevivencia.TimerEvento()
--Sobrevivencia.Init()

return Sobrevivencia
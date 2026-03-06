--[[
Sistema de evento in-game 
]]--

CorridaDaMorte = {}

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
local timer_hp = nil
local timer_hp2 = nil

function CorridaDaMorte.TimerEvento()

	Timer.Interval(30, CorridaDaMorte.Init)
end

function CorridaDaMorte.Init()

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
		
		if os.date("%X") == HORARIO_CORRIDADAMORTE or os.date("%X") == HORARIO_CORRIDADAMORTE2 or os.date("%X") == HORARIO_CORRIDADAMORTE3
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			CorridaDaMorte.CommandOpen_Auto()
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

		if EventoEscolhido == 'Corrida da Morte'
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			CorridaDaMorte.CommandOpen_Auto()
		else
			return
		end
	
	
	end
	
	
end


function CorridaDaMorte.CommandOpen_Auto()
	
	timer_check = nil
	timer_finish = nil
	timer_vivos = nil
	timer_vivos2 = nil
	gm = ''

	Players = {}
	Participantes = {}
	
	timer = 30
	
	Map = 0
	CoordX = 125
	CoordY = 81
	
	started = false
	ComandoOn = true
	
	idtimer = Timer.Repeater(1, timer, CorridaDaMorte.Running)
	
	SendMessageGlobal(string.format("[Sistema] Corrida da Morte está aberta!"), 1)
	
end




function CorridaDaMorte.CheckUser()

	if started == false
	then
		return
	end

	for i, name in ipairs(Participantes) do 
		local index = Participantes[name]
		local NickRemover = UserGetName(index)
			
		if UserGetConnected(index) ~= 3
		then
			CorridaDaMorte.RemoveUser(i)
			CorridaDaMorte.CheckVivos()
		end
		
		if UserGetMapNumber(index) ~= Map
		then
			CorridaDaMorte.RemoveUser(NickRemover)
			CorridaDaMorte.CheckVivos()
		end
		
		if UserGetMapNumber(index) == Map
		then
			if UserGetX(index) < 93 and UserGetY(index) < 61 or UserGetX(index) > 133 and UserGetY(index) > 88
			then
				SendMessage(string.format("[Sistema] Você saiu do evento!"), index, 1)
				Teleport(index, 0, 125, 125)
				CorridaDaMorte.RemoveUser(NickRemover)
				CorridaDaMorte.CheckVivos()
			end
		end
		
	end
	
	
end


function CorridaDaMorte.TirarHP()

	if started == false
	then
		return
	end
	
	SendMessageGlobal(string.format(" "), 0)
	SendMessageGlobal(string.format("[Corrida da Morte] O mapa agora vai começar a tirar HP!"), 0)
	SendMessageGlobal(string.format("CORRA para o centro do mapa 125 81 para não perder HP!!!"), 0)
	
	timer_hp2 = Timer.Interval(3, CorridaDaMorte.TirarHP2)
	
end

function CorridaDaMorte.TirarHP2()

	if started == false
	then
		return
	end

	for i, name in ipairs(Participantes) do 
		local index = Participantes[name]
		local NickRemover = UserGetName(index)
			
		if UserGetMapNumber(index) == 0
		then
			if UserGetX(index) < 122 and UserGetY(index) < 78 or UserGetX(index) > 128 and UserGetY(index) > 85
			then
				SendMessage(string.format("[Sistema] Vá para o centro do mapa 125 81 para não perder HP!"), 1)
				UserSetAddLife(index, (math.floor(UserGetAddLife(index) - 5000)))
				LifeUpdate(index, UserGetAddLife(index))
			end
		end
		
	end
			
			
end


function CorridaDaMorte.CheckVivos()

	if started == false
	then
		return
	end
	
	SendMessageGlobal(string.format("[Corrida da Morte] Restam %d players vivos!", #Participantes), 0)
	
	if #Participantes == 1
	then
	
		if timer_vivos2 ~= nil
		then
			Timer.Cancel(timer_vivos2)
			timer_vivos2 = nil
		end
		
		CorridaDaMorte.FinishEvent()
	
	end
		
		
end



function CorridaDaMorte.CheckVivos2()

	if started == false
	then
		return
	end
	
	if #Participantes == 1
	then
		CorridaDaMorte.FinishEvent()
	end
		
end



function CorridaDaMorte.FinishEvent()

	SendMessageGlobal(string.format("[Sistema] Corrida da Morte finalizado!"), 0)
	
	if #Participantes >= 2 or #Participantes < 1
	then
	
		SendMessageGlobal(string.format("(Os players demoraram para se matar ou todos saíram do mapa/jogo)."), 0)
		
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name]
			local NickRemover = UserGetName(index)
				
			if UserGetConnected(index) ~= 3
			then
				CorridaDaMorte.RemoveUser(NickRemover)
			end
				
			Teleport(Participantes[name], 0, 125, 125)
				
		end
		
		
	elseif #Participantes == 1
	then
	
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name]
			SendMessageGlobal(string.format("Vencedor: %s", UserGetName(index)), 0)
			
			
			
			
				
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(index))
			DataBase.SetAddValue("Character", COLUNA_CORRIDADAMORTE, PONTOS_EVENTINHOS, "Name", UserGetName(index))
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
	
	if timer_hp ~= nil
	then
		Timer.Cancel(timer_hp)
		timer_hp = nil
	end
	
	if timer_hp2 ~= nil
	then
		Timer.Cancel(timer_hp2)
		timer_hp2 = nil
	end
	
	Timer.TimeOut(2, CorridaDaMorte.StatusOFFevent)
	
end



function CorridaDaMorte.Running()

	if timer == 0
	then
		
		timer_check = Timer.Interval(2, CorridaDaMorte.CheckUser)
		timer_vivos = Timer.Interval(15, CorridaDaMorte.CheckVivos)
		timer_vivos2 = Timer.Interval(3, CorridaDaMorte.CheckVivos2)
		timer_finish = Timer.TimeOut(5 * 60, CorridaDaMorte.FinishEvent)
		
		started = true
		ComandoOn = false

		timer_hp = Timer.TimeOut(60, CorridaDaMorte.TirarHP)
		
		for i, name in ipairs(Players) do 
			local index = Players[name]
			local NickRemover = UserGetName(index)
			
			if UserGetConnected(index) ~= 3
			then
				CorridaDaMorte.RemoveUserPlayers(NickRemover)
			end
			
			InsertKey(Participantes, UserGetName(index))
			Participantes[UserGetName(index)] = index
			
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
					CorridaDaMorte.RemoveUser(NickRemover)
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
			
			if timer_hp ~= nil
			then
				Timer.Cancel(timer_hp)
				timer_hp = nil
			end
			
			if timer_hp2 ~= nil
			then
				Timer.Cancel(timer_hp2)
				timer_hp2 = nil
			end
					
			Timer.TimeOut(2, CorridaDaMorte.StatusOFFevent)
			
			return
			
		end
		
		SendMessageGlobal(string.format("Move %s fechou!", "/corridadamorte"), 0)
		SendMessageGlobal(string.format("Aguarde o próximo evento."), 0)
		CorridaDaMorte.CheckVivos()
	else
		SendMessageGlobal(string.format("[Sistema] Move %s fecha em %d segundo(s)", "/corridadamorte", timer), 0)
		timer = timer - 1
	end
	
end

function CorridaDaMorte.CommandOpen(aIndex, Arguments)
	
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
		SendMessage(string.format("[Sistema] Uso %s tempo", "/abrircorridadamorte"), aIndex, 1)
		return
	end
	
	if timer > 60
	then
		SendMessage(string.format("[Sistema] O tempo máximo para abrir é de 60 segundos!"), aIndex, 1)
		return
	end
	
	Map = 0
	CoordX = 125
	CoordY = 81
	
	started = false
	ComandoOn = true
	
	DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
	
	idtimer = Timer.Repeater(1, timer, CorridaDaMorte.Running)
	
	SendMessageGlobal(string.format("[Sistema] %s abriu %s", UserGetName(aIndex), "/corridadamorte"), 1)
	
end

function CorridaDaMorte.CommandGo(aIndex, Arguments)

	if UserGetAuthority(aIndex) ~= 1
	then
		SendMessage(string.format("[Sistema] STAFFERs não podem participar de eventos!"), aIndex, 1)
		return
	end
	
	if ComandoOn == false
	then
		SendMessage(string.format("[Sistema] Corrida da Morte não está aberto neste momento."), aIndex, 1)
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
	else
		SendMessage(string.format("[Sistema] Você será movido em alguns segundos..."), aIndex, 1)
	end
	
end


function CorridaDaMorte.Morte(aIndex, TargetIndex)

	if started == false
	then
		return
	end
	
	
	if Participantes[UserGetName(aIndex)] == nil or Participantes[UserGetName(TargetIndex)] == nil
	then
		--
	else
		SendMessage(string.format("[Corrida da Morte] Você matou %s", UserGetName(TargetIndex)), aIndex, 1)
		SendMessage(string.format("[Corrida da Morte] %s matou você!", UserGetName(aIndex)), TargetIndex, 1)
		local nomeRemover = UserGetName(TargetIndex)
		CorridaDaMorte.RemoveUser(nomeRemover)
		CorridaDaMorte.CheckVivos()
	end
	

end



function CorridaDaMorte.RemoveUser(Name)
	for i, key in ipairs(Participantes) do
		if key == Name
		then
			table.remove(Participantes, i)
		end
	end
end

function CorridaDaMorte.RemoveUserPlayers(Name)
	for i, key in ipairs(Players) do
		if key == Name
		then
			table.remove(Players, i)
		end
	end
end


function CorridaDaMorte.StatusOFFevent()

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



Commands.Register("/abrircorridadamorte", CorridaDaMorte.CommandOpen)
Commands.Register("/corridadamorte", CorridaDaMorte.CommandGo)
GameServerFunctions.PlayerDie(CorridaDaMorte.Morte)

CorridaDaMorte.TimerEvento()

return CorridaDaMorte
--[[
Sistema de evento in-game 
]]--

TheFlash = {}

local Players = {}
local idtimer = -1
local timer = 0
local started = false
local timer_check = nil
local timer_finish = nil
local gm = ''
local Map = 0
local CoordX = 0
local CoordY = 0
local Move = ''
local TRADEWINS_NPC_CREATE = {}

function TheFlash.TimerEvento()

	TheFlash.ClearByMonster()
	Timer.Interval(30, TheFlash.Init)
end

function TheFlash.Init()

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
			TheFlash.CommandOpen_Auto()
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

		if EventoEscolhido == 'The Flash'
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			TheFlash.CommandOpen_Auto()
		else
			return
		end
	
	
	end
	
	
end


function TheFlash.CommandOpen_Auto()
	
	timer_check = nil
	timer_finish = nil
	timer_vivos = nil
	timer_vivos2 = nil
	gm = ''

	Players = {}

	Map = math.random (0, 8)
	
	if Map == 0
	then
		Move = "Lorencia"
		
	elseif Map == 1
	then
		Move = "Dungeons"
		
	elseif Map == 2
	then
		Move = "Devias"
		
	elseif Map == 3
	then
		Move = "Noria"
		
	elseif Map == 4
	then
		Move = "Losttower"
		
	elseif Map == 5
	then
		Map = 0
		Move = "Lorencia"
		
	elseif Map == 6
	then
		Map = 0
		Move = "Lorencia"
	
	elseif Map == 7
	then
		Move = "Atlans"
		
	elseif Map == 8
	then
		Move = "Tarkan"
		
		
	end
	
	
	
	started = true
	TheFlash.InitNPC()

	idtimer = Timer.Interval(1, TheFlash.Running)
	timer_finish = Timer.Interval(5 * 60, TheFlash.FinishEvent)
	
	SendMessageGlobal(string.format("[Sistema] Evento The Flash!"), 0)
	SendMessageGlobal(string.format("~~>  %s - %d %d  <~~", Move, CoordX, CoordY), 0)
	
end



function TheFlash.NpcTalk(Npc, Player)
	for i in pairs(TRADEWINS_NPC_CREATE) do
		if TRADEWINS_NPC_CREATE[i].NpcIndex == Npc
		then
			TheFlash.EscEscNpc(Npc, Player)
			return 1
		end
	end
	
	return 0
end


function TheFlash.EscEscNpc(Npc, aIndex)

	if started == false
	then
		ChatTargetSend(Npc, string.format("Que pena... Alguém chegou antes de você! Tente na próxima..."), aIndex)
		return
	end
	
	if Players[UserGetName(aIndex)] == nil
	then
		InsertKey(Players, UserGetName(aIndex))
		Players[UserGetName(aIndex)] = aIndex
		
		ChatTargetSend(Npc, string.format("Parabéns!"), aIndex)
	else
		ChatTargetSend(Npc, string.format("Parabéns!"), aIndex)
	end
	
	TheFlash.FinishEvent()
	
end



function TheFlash.InitNPC()
	for i, key in ipairs(TRADEWINS_NPC_CREATE) do
		if UserGetConnected(TRADEWINS_NPC_CREATE[key].NpcIndex) >= 1
		then
			gObjDel(TRADEWINS_NPC_CREATE[key].NpcIndex)
			gObjDel(249)
		end
	end
	
	TRADEWINS_NPC_CREATE = {}

	TheFlash.CreateNpc(249, Map, 1, 1, 3)
	
end

function TheFlash.CreateNpc(class, map, x, y, dir)
	index = AddMonster(map)
	
	if index == -1
	then
		LogAdd(string.format("[The Flash] Problema ao criar o Npc :%d", class))
		return
	end
	
	SetMapMonster(index, map, x, y)
	
	UserSetDir(index, dir)

	--SetMonster(index, class)
	
	
	SetPositionMonster(index, map)
	SetMonster(index, class)
	LogAdd(string.format("[The Flash] NPC: %d - Map: %d - X: %d Y: %d",class, UserGetMapNumber(index), UserGetX(index), UserGetY(index)))

	CoordX = UserGetX(index)
	CoordY = UserGetY(index)
	
	TRADEWINS_NPC_CREATE[index] = {NpcIndex = index}
end




function TheFlash.FinishEvent()

	SendMessageGlobal(string.format("[Sistema] The Flash Finalizado!"), 0)
	
	if #Players < 1
	then
		SendMessageGlobal(string.format("(Os players demoraram muito para encontrar o NPC)."), 0)
		
	elseif #Players == 1
	then
	
		for i, name in ipairs(Players) do 
			local index = Players[name]
			SendMessageGlobal(string.format("Vencedor: %s", UserGetName(index)), 0)
			
			
			
				
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(index))
			DataBase.SetAddValue("Character", COLUNA_THEFLASH, PONTOS_EVENTINHOS, "Name", UserGetName(index))
			SendMessageGlobal(string.format("~> Prêmio: %d %s! <~", PREMIO_EVENTINHOS, NOME_MOEDA_EVENTO), 0)

			-- pontos eventos total
			DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(index))
			DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(index))
			DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(index))
				
			
			
			
			
			
			
			
		end
		
	end
	
	started = false
	
	for i in pairs(TRADEWINS_NPC_CREATE) do
		--Remover npc
		TheFlash.ClearByMonster(TRADEWINS_NPC_CREATE[i].NpcIndex)
	end
	
	if timer_finish ~= nil
	then
		Timer.Cancel(timer_finish)
		timer_finish = nil
	end
	
	if timer_check ~= nil
	then
		Timer.Cancel(timer_check)
		timer_check = nil
	end
	
	if idtimer ~= nil
	then
		Timer.Cancel(idtimer)
		idtimer = nil
	end
	
	Timer.TimeOut(2, TheFlash.StatusOFFevent)
	
end


function TheFlash.ClearByMonster(index)
	for key in pairs(TRADEWINS_NPC_CREATE) do
		if TRADEWINS_NPC_CREATE[key].NpcIndex == index
		then
			if TRADEWINS_NPC_CREATE[key].NpcIndex ~= -1
			then
				gObjDel(TRADEWINS_NPC_CREATE[key].NpcIndex)
				TRADEWINS_NPC_CREATE[key] = nil
			end
		end
	end
	
	gObjDel(249)
	
end


function TheFlash.Running()

	if started == false
	then
		return
	end
		
	SendMessageGlobal(string.format("[Sistema] The Flash ~> %s - %d %d", Move, CoordX, CoordY), 0)
	
end

function TheFlash.CommandOpen(aIndex, Arguments)
	
	if UserGetAuthority(aIndex) == 1
	then
		return
	end
	
	if started == true
	then
		if gm == ''
		then
			SendMessage(string.format("[Sistema] Já existe um The Flash aberto pelo Sistema!"), aIndex, 1)
			return
		else
			SendMessage(string.format("[Sistema] Já existe um The Flash aberto pelo %s!", gm), aIndex, 1)
			return
		end
	end
	
	timer_check = nil
	timer_finish = nil
	timer_vivos = nil
	timer_vivos2 = nil
	gm = UserGetName(aIndex)
	
	Players = {}

	Map = math.random (0, 8)
	
	if Map == 0
	then
		Move = "Lorencia"
		
	elseif Map == 1
	then
		Move = "Dungeons"
		
	elseif Map == 2
	then
		Move = "Devias"
		
	elseif Map == 3
	then
		Move = "Noria"
		
	elseif Map == 4
	then
		Move = "Losttower"
		
	elseif Map == 5
	then
		Map = 0
		Move = "Lorencia"
		
	elseif Map == 6
	then
		Map = 0
		Move = "Lorencia"
	
	elseif Map == 7
	then
		Move = "Atlans"
		
	elseif Map == 8
	then
		Move = "Tarkan"
		
		
	end
	
	
	DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
	
	started = true
	TheFlash.InitNPC()

	idtimer = Timer.Interval(1, TheFlash.Running)
	timer_finish = Timer.Interval(5 * 60, TheFlash.FinishEvent)
	
	SendMessageGlobal(string.format("[%s]", UserGetName(aIndex)), 0)
	SendMessageGlobal(string.format("Evento The Flash!"), 0)
	SendMessageGlobal(string.format("~~>  %s - %d %d  <~~", Move, CoordX, CoordY), 0)
	
end


function TheFlash.RemoveUserPlayers(Name)
	for i, key in ipairs(Players) do
		if key == Name
		then
			table.remove(Players, i)
		end
	end
end


function TheFlash.StatusOFFevent()

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


Commands.Register("/abrirtheflash", TheFlash.CommandOpen)
GameServerFunctions.NpcTalk(TheFlash.NpcTalk)

TheFlash.TimerEvento()

return TheFlash
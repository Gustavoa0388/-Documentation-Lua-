--[[
Sistema de evento in-game 
]]--

MoveuAchou = {}

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

function MoveuAchou.TimerEvento()

	MoveuAchou.ClearByMonster()
	Timer.Interval(30, MoveuAchou.Init)
end

function MoveuAchou.Init()

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
		
		if os.date("%X") == HORARIO_MOVEUACHOU or os.date("%X") == HORARIO_MOVEUACHOU2 or os.date("%X") == HORARIO_MOVEUACHOU3
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			MoveuAchou.CommandOpen_Auto()
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

		if EventoEscolhido == 'Moveu Achou'
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			MoveuAchou.CommandOpen_Auto()
		else
			return
		end
	
	
	end
	
	
end


function MoveuAchou.CommandOpen_Auto()
	
	timer_check = nil
	timer_finish = nil
	timer_vivos = nil
	timer_vivos2 = nil
	gm = ''

	Players = {}

	sorteioMove = math.random (1, 30)
	
	if sorteioMove == 1
	then
		Move = "/bar"
		Map = 0
		CoordX = 125
		CoordY = 125
		
	elseif sorteioMove == 2
	then
		Move = "/lorencia2"
		Map = 0
		CoordX = 76
		CoordY = 155
		
	elseif sorteioMove == 3
	then
		Move = "/lorencia3"
		Map = 0
		CoordX = 220
		CoordY = 200
		
	elseif sorteioMove == 4
	then
		Move = "/lorencia4"
		Map = 0
		CoordX = 210
		CoordY = 109
		
	elseif sorteioMove == 5
	then
		Move = "/cemiterio"
		Map = 0
		CoordX = 140
		CoordY = 225
		
	elseif sorteioMove == 6
	then
		Move = "/pvp1"
		Map = 0
		CoordX = 133
		CoordY = 90
		
	elseif sorteioMove == 7
	then
		Move = "/saida"
		Map = 0
		CoordX = 172
		CoordY = 128
		
	elseif sorteioMove == 8
	then
		Move = "/saida2"
		Map = 2
		CoordX = 222
		CoordY = 74
		
	elseif sorteioMove == 9
	then
		Move = "/tarkan2"
		Map = 8
		CoordX = 30
		CoordY = 225
		
	elseif sorteioMove == 10
	then
		Move = "/tarkan3"
		Map = 8
		CoordX = 50
		CoordY = 160
		
	elseif sorteioMove == 11
	then
		Move = "/tarkan4"
		Map = 8
		CoordX = 95
		CoordY = 35
		
	elseif sorteioMove == 12
	then
		Move = "/tarkan5"
		Map = 8
		CoordX = 160
		CoordY = 125
		
	elseif sorteioMove == 13
	then
		Move = "/arena"
		Map = 6
		CoordX = 66
		CoordY = 50
		
	elseif sorteioMove == 14
	then
		Move = "/arena1"
		Map = 6
		CoordX = 55
		CoordY = 80
		
	elseif sorteioMove == 15
	then
		Move = "/arena2"
		Map = 6
		CoordX = 38
		CoordY = 44
	
	elseif sorteioMove == 16
	then
		Move = "/arena3"
		Map = 6
		CoordX = 38
		CoordY = 66
		
	elseif sorteioMove == 17
	then
		Move = "/arena4"
		Map = 6
		CoordX = 38
		CoordY = 84
		
	elseif sorteioMove == 18
	then
		Move = "/arena5"
		Map = 6
		CoordX = 20
		CoordY = 83
		
	elseif sorteioMove == 19
	then
		Move = "/arena6"
		Map = 6
		CoordX = 20
		CoordY = 65
		
	elseif sorteioMove == 20
	then
		Move = "/arena7"
		Map = 6
		CoordX = 20
		CoordY = 47
		
	elseif sorteioMove == 21
	then
		Move = "/arena8"
		Map = 6
		CoordX = 40
		CoordY = 10
		
	elseif sorteioMove == 22
	then
		Move = "/arena9"
		Map = 6
		CoordX = 60
		CoordY = 7
		
	elseif sorteioMove == 23
	then
		Move = "/arena10"
		Map = 6
		CoordX = 90
		CoordY = 40
		
	elseif sorteioMove == 24
	then
		Move = "/arena11"
		Map = 6
		CoordX = 90
		CoordY = 115
		
	elseif sorteioMove == 25
	then
		Move = "/atlans2"
		Map = 7
		CoordX = 226
		CoordY = 53
		
	elseif sorteioMove == 26
	then
		Move = "/atlans3"
		Map = 7
		CoordX = 63
		CoordY = 163
		
	elseif sorteioMove == 27
	then
		Move = "/devias2"
		Map = 2
		CoordX = 20
		CoordY = 25
		
	elseif sorteioMove == 28
	then
		Move = "/devias3"
		Map = 2
		CoordX = 225
		CoordY = 204
		
	elseif sorteioMove == 29
	then
		Move = "/devias4"
		Map = 2
		CoordX = 160
		CoordY = 142
		
	elseif sorteioMove == 30
	then
		Move = "/pvp2"
		Map = 2
		CoordX = 174
		CoordY = 41
		
	end
	
	
	LogAdd(string.format("[Moveu Achou] NPC nasceu em %s", Move))
	
	started = true
	MoveuAchou.InitNPC()

	idtimer = Timer.Interval(1, MoveuAchou.Running)
	timer_finish = Timer.Interval(3 * 60, MoveuAchou.FinishEvent)
	
	SendMessageGlobal(string.format('[Sistema] Evento Moveu Achou!'), 0)
	
end



function MoveuAchou.NpcTalk(Npc, Player)
	for i in pairs(TRADEWINS_NPC_CREATE) do
		if TRADEWINS_NPC_CREATE[i].NpcIndex == Npc
		then
			MoveuAchou.TradeWinsNpc(Npc, Player)
			return 1
		end
	end
	
	return 0
end


function MoveuAchou.TradeWinsNpc(Npc, aIndex)

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
	
	MoveuAchou.FinishEvent()
	
end



function MoveuAchou.InitNPC()
	for i, key in ipairs(TRADEWINS_NPC_CREATE) do
		if UserGetConnected(TRADEWINS_NPC_CREATE[key].NpcIndex) >= 1
		then
			gObjDel(TRADEWINS_NPC_CREATE[key].NpcIndex)
			gObjDel(249)
		end
	end
	
	TRADEWINS_NPC_CREATE = {}

	MoveuAchou.CreateNpc(249, Map, CoordX, CoordY, 3)
end

function MoveuAchou.CreateNpc(class, map, x, y, dir)
	index = AddMonster(map)
	
	if index == -1
	then
		LogAdd(string.format("[Moveu Achou] Problema ao criar o Npc :%d", class))
		return
	end
	
	SetMapMonster(index, map, x, y)
	
	UserSetDir(index, dir)

	SetMonster(index, class)
	
	TRADEWINS_NPC_CREATE[index] = {NpcIndex = index}
end




function MoveuAchou.FinishEvent()

	SendMessageGlobal(string.format("[Sistema] Moveu Achou Finalizado!"), 0)
	
	if #Players < 1
	then
		SendMessageGlobal(string.format("(Os players demoraram muito para encontrar o NPC)."), 0)
		
	elseif #Players == 1
	then
	
		for i, name in ipairs(Players) do 
			local index = Players[name]
			SendMessageGlobal(string.format("Vencedor: %s", UserGetName(index)), 0)
			
			
			
			
				
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(index))
			DataBase.SetAddValue("Character", COLUNA_MOVEUACHOU, PONTOS_EVENTINHOS, "Name", UserGetName(index))
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
		MoveuAchou.ClearByMonster(TRADEWINS_NPC_CREATE[i].NpcIndex)
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
	
	Timer.TimeOut(2, MoveuAchou.StatusOFFevent)
	
end


function MoveuAchou.ClearByMonster(index)
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


function MoveuAchou.Running()

	if started == false
	then
		return
	end
		
	SendMessageGlobal(string.format('[Sistema] Evento Moveu Achou!'), 0)
	
end

function MoveuAchou.CommandOpen(aIndex, Arguments)
	
	if UserGetAuthority(aIndex) == 1
	then
		return
	end
	
	if started == true
	then
		if gm == ''
		then
			SendMessage(string.format("[Sistema] Já existe um Moveu Achou aberto pelo Sistema!"), aIndex, 1)
			return
		else
			SendMessage(string.format("[Sistema] Já existe um Moveu Achou aberto pelo %s!", gm), aIndex, 1)
			return
		end
	end
	
	timer_check = nil
	timer_finish = nil
	timer_vivos = nil
	timer_vivos2 = nil
	gm = UserGetName(aIndex)
	
	Players = {}

	sorteioMove = math.random (1, 30)
	
	if sorteioMove == 1
	then
		Move = "/bar"
		Map = 0
		CoordX = 125
		CoordY = 125
		
	elseif sorteioMove == 2
	then
		Move = "/lorencia2"
		Map = 0
		CoordX = 76
		CoordY = 155
		
	elseif sorteioMove == 3
	then
		Move = "/lorencia3"
		Map = 0
		CoordX = 220
		CoordY = 200
		
	elseif sorteioMove == 4
	then
		Move = "/lorencia4"
		Map = 0
		CoordX = 210
		CoordY = 109
		
	elseif sorteioMove == 5
	then
		Move = "/cemiterio"
		Map = 0
		CoordX = 140
		CoordY = 225
		
	elseif sorteioMove == 6
	then
		Move = "/pvp1"
		Map = 0
		CoordX = 133
		CoordY = 90
		
	elseif sorteioMove == 7
	then
		Move = "/saida"
		Map = 0
		CoordX = 172
		CoordY = 128
		
	elseif sorteioMove == 8
	then
		Move = "/saida2"
		Map = 2
		CoordX = 222
		CoordY = 74
		
	elseif sorteioMove == 9
	then
		Move = "/tarkan2"
		Map = 8
		CoordX = 30
		CoordY = 225
		
	elseif sorteioMove == 10
	then
		Move = "/tarkan3"
		Map = 8
		CoordX = 50
		CoordY = 160
		
	elseif sorteioMove == 11
	then
		Move = "/tarkan4"
		Map = 8
		CoordX = 95
		CoordY = 35
		
	elseif sorteioMove == 12
	then
		Move = "/tarkan5"
		Map = 8
		CoordX = 160
		CoordY = 125
		
	elseif sorteioMove == 13
	then
		Move = "/arena"
		Map = 6
		CoordX = 66
		CoordY = 50
		
	elseif sorteioMove == 14
	then
		Move = "/arena1"
		Map = 6
		CoordX = 55
		CoordY = 80
		
	elseif sorteioMove == 15
	then
		Move = "/arena2"
		Map = 6
		CoordX = 38
		CoordY = 44
	
	elseif sorteioMove == 16
	then
		Move = "/arena3"
		Map = 6
		CoordX = 38
		CoordY = 66
		
	elseif sorteioMove == 17
	then
		Move = "/arena4"
		Map = 6
		CoordX = 38
		CoordY = 84
		
	elseif sorteioMove == 18
	then
		Move = "/arena5"
		Map = 6
		CoordX = 20
		CoordY = 83
		
	elseif sorteioMove == 19
	then
		Move = "/arena6"
		Map = 6
		CoordX = 20
		CoordY = 65
		
	elseif sorteioMove == 20
	then
		Move = "/arena7"
		Map = 6
		CoordX = 20
		CoordY = 47
		
	elseif sorteioMove == 21
	then
		Move = "/arena8"
		Map = 6
		CoordX = 40
		CoordY = 10
		
	elseif sorteioMove == 22
	then
		Move = "/arena9"
		Map = 6
		CoordX = 60
		CoordY = 7
		
	elseif sorteioMove == 23
	then
		Move = "/arena10"
		Map = 6
		CoordX = 90
		CoordY = 40
		
	elseif sorteioMove == 24
	then
		Move = "/arena11"
		Map = 6
		CoordX = 90
		CoordY = 115
		
	elseif sorteioMove == 25
	then
		Move = "/atlans2"
		Map = 7
		CoordX = 226
		CoordY = 53
		
	elseif sorteioMove == 26
	then
		Move = "/atlans3"
		Map = 7
		CoordX = 63
		CoordY = 163
		
	elseif sorteioMove == 27
	then
		Move = "/devias2"
		Map = 2
		CoordX = 20
		CoordY = 25
		
	elseif sorteioMove == 28
	then
		Move = "/devias3"
		Map = 2
		CoordX = 225
		CoordY = 204
		
	elseif sorteioMove == 29
	then
		Move = "/devias4"
		Map = 2
		CoordX = 160
		CoordY = 142
		
	elseif sorteioMove == 30
	then
		Move = "/pvp2"
		Map = 2
		CoordX = 174
		CoordY = 41
		
	end
	
	DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
	
	LogAdd(string.format("[Moveu Achou] NPC nasceu em %s", Move))
	
	started = true
	MoveuAchou.InitNPC()

	idtimer = Timer.Interval(1, MoveuAchou.Running)
	timer_finish = Timer.Interval(3 * 60, MoveuAchou.FinishEvent)
	
	SendMessageGlobal(string.format("[%s]", UserGetName(aIndex)), 0)
	SendMessageGlobal(string.format('Evento Moveu Achou!'), 0)
	
end


function MoveuAchou.RemoveUserPlayers(Name)
	for i, key in ipairs(Players) do
		if key == Name
		then
			table.remove(Players, i)
		end
	end
end


function MoveuAchou.StatusOFFevent()

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



Commands.Register("/abrirmoveuachou", MoveuAchou.CommandOpen)
GameServerFunctions.NpcTalk(MoveuAchou.NpcTalk)

MoveuAchou.TimerEvento()

return MoveuAchou
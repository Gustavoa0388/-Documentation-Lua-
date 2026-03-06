--[[
Sistema de evento in-game 
]]--

TradeWins = {}

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

function TradeWins.TimerEvento()

	TradeWins.ClearByMonster()
	Timer.Interval(30, TradeWins.Init)
end

function TradeWins.Init()

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
			TradeWins.CommandOpen_Auto()
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

		if EventoEscolhido == 'Trade Wins'
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			TradeWins.CommandOpen_Auto()
		else
			return
		end
	
	
	end
	
	
end


function TradeWins.CommandOpen_Auto()
	
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
		CoordX = 123
		CoordY = 128
		
	elseif sorteioMove == 2
	then
		Move = "/lorencia2"
		Map = 0
		CoordX = 76
		CoordY = 152
		
	elseif sorteioMove == 3
	then
		Move = "/lorencia3"
		Map = 0
		CoordX = 223
		CoordY = 202
		
	elseif sorteioMove == 4
	then
		Move = "/lorencia4"
		Map = 0
		CoordX = 216
		CoordY = 107
		
	elseif sorteioMove == 5
	then
		Move = "/cemiterio"
		Map = 0
		CoordX = 138
		CoordY = 229
		
	elseif sorteioMove == 6
	then
		Move = "/pvp1"
		Map = 0
		CoordX = 135
		CoordY = 95
		
	elseif sorteioMove == 7
	then
		Move = "/saida"
		Map = 0
		CoordX = 166
		CoordY = 129
		
	elseif sorteioMove == 8
	then
		Move = "/saida2"
		Map = 2
		CoordX = 221
		CoordY = 71
		
	elseif sorteioMove == 9
	then
		Move = "/tarkan2"
		Map = 8
		CoordX = 34
		CoordY = 228
		
	elseif sorteioMove == 10
	then
		Move = "/tarkan3"
		Map = 8
		CoordX = 52
		CoordY = 165
		
	elseif sorteioMove == 11
	then
		Move = "/tarkan4"
		Map = 8
		CoordX = 101
		CoordY = 30
		
	elseif sorteioMove == 12
	then
		Move = "/tarkan5"
		Map = 8
		CoordX = 166
		CoordY = 125
		
	elseif sorteioMove == 13
	then
		Move = "/arena"
		Map = 6
		CoordX = 69
		CoordY = 44
		
	elseif sorteioMove == 14
	then
		Move = "/arena1"
		Map = 6
		CoordX = 59
		CoordY = 85
		
	elseif sorteioMove == 15
	then
		Move = "/arena2"
		Map = 6
		CoordX = 40
		CoordY = 39
	
	elseif sorteioMove == 16
	then
		Move = "/arena3"
		Map = 6
		CoordX = 42
		CoordY = 67
		
	elseif sorteioMove == 17
	then
		Move = "/arena4"
		Map = 6
		CoordX = 31
		CoordY = 84
		
	elseif sorteioMove == 18
	then
		Move = "/arena5"
		Map = 6
		CoordX = 22
		CoordY = 78
		
	elseif sorteioMove == 19
	then
		Move = "/arena6"
		Map = 6
		CoordX = 16
		CoordY = 68
		
	elseif sorteioMove == 20
	then
		Move = "/arena7"
		Map = 6
		CoordX = 17
		CoordY = 45
		
	elseif sorteioMove == 21
	then
		Move = "/arena8"
		Map = 6
		CoordX = 44
		CoordY = 12
		
	elseif sorteioMove == 22
	then
		Move = "/arena9"
		Map = 6
		CoordX = 68
		CoordY = 8
		
	elseif sorteioMove == 23
	then
		Move = "/arena10"
		Map = 6
		CoordX = 84
		CoordY = 43
		
	elseif sorteioMove == 24
	then
		Move = "/arena11"
		Map = 6
		CoordX = 92
		CoordY = 119
		
	elseif sorteioMove == 25
	then
		Move = "/atlans2"
		Map = 7
		CoordX = 232
		CoordY = 56
		
	elseif sorteioMove == 26
	then
		Move = "/atlans3"
		Map = 7
		CoordX = 68
		CoordY = 160
		
	elseif sorteioMove == 27
	then
		Move = "/devias2"
		Map = 2
		CoordX = 19
		CoordY = 30
		
	elseif sorteioMove == 28
	then
		Move = "/devias3"
		Map = 2
		CoordX = 231
		CoordY = 204
		
	elseif sorteioMove == 29
	then
		Move = "/devias4"
		Map = 2
		CoordX = 159
		CoordY = 235
		
	elseif sorteioMove == 30
	then
		Move = "/pvp2"
		Map = 2
		CoordX = 178
		CoordY = 42
		
	end
	
	
	started = true
	TradeWins.InitNPC()

	idtimer = Timer.Interval(1, TradeWins.Running)
	timer_finish = Timer.Interval(3 * 60, TradeWins.FinishEvent)
	
	SendMessageGlobal(string.format("[Sistema] Evento Trade Wins!"), 0)
	SendMessageGlobal(string.format("~~>  %s  <~~", Move), 0)
	
end



function TradeWins.NpcTalk(Npc, Player)
	for i in pairs(TRADEWINS_NPC_CREATE) do
		if TRADEWINS_NPC_CREATE[i].NpcIndex == Npc
		then
			TradeWins.TradeWinsNpc(Npc, Player)
			return 1
		end
	end
	
	return 0
end


function TradeWins.TradeWinsNpc(Npc, aIndex)

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
	
	TradeWins.FinishEvent()
	
end



function TradeWins.InitNPC()
	for i, key in ipairs(TRADEWINS_NPC_CREATE) do
		if UserGetConnected(TRADEWINS_NPC_CREATE[key].NpcIndex) >= 1
		then
			gObjDel(TRADEWINS_NPC_CREATE[key].NpcIndex)
			gObjDel(249)
		end
	end
	
	TRADEWINS_NPC_CREATE = {}

	TradeWins.CreateNpc(249, Map, CoordX, CoordY, 3)
end

function TradeWins.CreateNpc(class, map, x, y, dir)
	index = AddMonster(map)
	
	if index == -1
	then
		LogAdd(string.format("[Trade Wins] Problema ao criar o Npc :%d", class))
		return
	end
	
	SetMapMonster(index, map, x, y)
	
	UserSetDir(index, dir)

	SetMonster(index, class)
	
	TRADEWINS_NPC_CREATE[index] = {NpcIndex = index}
end




function TradeWins.FinishEvent()

	SendMessageGlobal(string.format("[Sistema] Trade Wins Finalizado!"), 0)
	
	if #Players < 1
	then
		SendMessageGlobal(string.format("(Os players demoraram muito para encontrar o NPC)."), 0)
		
	elseif #Players == 1
	then
	
		for i, name in ipairs(Players) do 
			local index = Players[name]
			SendMessageGlobal(string.format("Vencedor: %s", UserGetName(index)), 0)
			
			
			
			
			
				
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTINHOS, "memb___id", UserGetAccountID(index))
			DataBase.SetAddValue("Character", COLUNA_TIMEXTIME, PONTOS_EVENTINHOS, "Name", UserGetName(index))
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
		TradeWins.ClearByMonster(TRADEWINS_NPC_CREATE[i].NpcIndex)
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
	
	Timer.TimeOut(2, TradeWins.StatusOFFevent)
	
end


function TradeWins.ClearByMonster(index)
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


function TradeWins.Running()

	if started == false
	then
		return
	end
		
	SendMessageGlobal(string.format("[Sistema] Trade Wins ~> %s", Move), 0)
	
end

function TradeWins.CommandOpen(aIndex, Arguments)
	
	if UserGetAuthority(aIndex) == 1
	then
		return
	end
	
	if started == true
	then
		if gm == ''
		then
			SendMessage(string.format("[Sistema] Já existe um Trade Wins aberto pelo Sistema!"), aIndex, 1)
			return
		else
			SendMessage(string.format("[Sistema] Já existe um Trade Wins aberto pelo %s!", gm), aIndex, 1)
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
		CoordX = 123
		CoordY = 128
		
	elseif sorteioMove == 2
	then
		Move = "/lorencia2"
		Map = 0
		CoordX = 76
		CoordY = 152
		
	elseif sorteioMove == 3
	then
		Move = "/lorencia3"
		Map = 0
		CoordX = 223
		CoordY = 202
		
	elseif sorteioMove == 4
	then
		Move = "/lorencia4"
		Map = 0
		CoordX = 216
		CoordY = 107
		
	elseif sorteioMove == 5
	then
		Move = "/cemiterio"
		Map = 0
		CoordX = 138
		CoordY = 229
		
	elseif sorteioMove == 6
	then
		Move = "/pvp1"
		Map = 0
		CoordX = 135
		CoordY = 95
		
	elseif sorteioMove == 7
	then
		Move = "/saida"
		Map = 0
		CoordX = 166
		CoordY = 129
		
	elseif sorteioMove == 8
	then
		Move = "/saida2"
		Map = 2
		CoordX = 221
		CoordY = 71
		
	elseif sorteioMove == 9
	then
		Move = "/tarkan2"
		Map = 8
		CoordX = 34
		CoordY = 228
		
	elseif sorteioMove == 10
	then
		Move = "/tarkan3"
		Map = 8
		CoordX = 52
		CoordY = 165
		
	elseif sorteioMove == 11
	then
		Move = "/tarkan4"
		Map = 8
		CoordX = 101
		CoordY = 30
		
	elseif sorteioMove == 12
	then
		Move = "/tarkan5"
		Map = 8
		CoordX = 166
		CoordY = 125
		
	elseif sorteioMove == 13
	then
		Move = "/arena"
		Map = 6
		CoordX = 69
		CoordY = 44
		
	elseif sorteioMove == 14
	then
		Move = "/arena1"
		Map = 6
		CoordX = 59
		CoordY = 85
		
	elseif sorteioMove == 15
	then
		Move = "/arena2"
		Map = 6
		CoordX = 40
		CoordY = 39
	
	elseif sorteioMove == 16
	then
		Move = "/arena3"
		Map = 6
		CoordX = 42
		CoordY = 67
		
	elseif sorteioMove == 17
	then
		Move = "/arena4"
		Map = 6
		CoordX = 31
		CoordY = 84
		
	elseif sorteioMove == 18
	then
		Move = "/arena5"
		Map = 6
		CoordX = 22
		CoordY = 78
		
	elseif sorteioMove == 19
	then
		Move = "/arena6"
		Map = 6
		CoordX = 16
		CoordY = 68
		
	elseif sorteioMove == 20
	then
		Move = "/arena7"
		Map = 6
		CoordX = 17
		CoordY = 45
		
	elseif sorteioMove == 21
	then
		Move = "/arena8"
		Map = 6
		CoordX = 44
		CoordY = 12
		
	elseif sorteioMove == 22
	then
		Move = "/arena9"
		Map = 6
		CoordX = 68
		CoordY = 8
		
	elseif sorteioMove == 23
	then
		Move = "/arena10"
		Map = 6
		CoordX = 84
		CoordY = 43
		
	elseif sorteioMove == 24
	then
		Move = "/arena11"
		Map = 6
		CoordX = 92
		CoordY = 119
		
	elseif sorteioMove == 25
	then
		Move = "/atlans2"
		Map = 7
		CoordX = 232
		CoordY = 56
		
	elseif sorteioMove == 26
	then
		Move = "/atlans3"
		Map = 7
		CoordX = 68
		CoordY = 160
		
	elseif sorteioMove == 27
	then
		Move = "/devias2"
		Map = 2
		CoordX = 19
		CoordY = 30
		
	elseif sorteioMove == 28
	then
		Move = "/devias3"
		Map = 2
		CoordX = 231
		CoordY = 204
		
	elseif sorteioMove == 29
	then
		Move = "/devias4"
		Map = 2
		CoordX = 159
		CoordY = 235
		
	elseif sorteioMove == 30
	then
		Move = "/pvp2"
		Map = 2
		CoordX = 178
		CoordY = 42
		
	end
	
	
	DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
	
	started = true
	TradeWins.InitNPC()

	idtimer = Timer.Interval(1, TradeWins.Running)
	timer_finish = Timer.Interval(3 * 60, TradeWins.FinishEvent)
	
	SendMessageGlobal(string.format("[%s]", UserGetName(aIndex)), 0)
	SendMessageGlobal(string.format("Evento Trade Wins!"), 0)
	SendMessageGlobal(string.format("~~>  %s  <~~", Move), 0)
	
end


function TradeWins.RemoveUserPlayers(Name)
	for i, key in ipairs(Players) do
		if key == Name
		then
			table.remove(Players, i)
		end
	end
end



function TradeWins.StatusOFFevent()

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



Commands.Register("/abrirtradewins", TradeWins.CommandOpen)
GameServerFunctions.NpcTalk(TradeWins.NpcTalk)

TradeWins.TimerEvento()

return TradeWins
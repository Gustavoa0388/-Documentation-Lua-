--[[Configurações System Mata-Mata]]--

MataMata = {}

local Players = {}
local Participantes = {}
local started = false
local open = false
local idtimercheck = -1
local idtimerParticipante = -1
local idtimer = -1
local side = 0
local Fight1 = nil
local Fight2 = nil
local StepRunning = 0
local KILL_MAP = 6
local KILL_MAP2 = 50
local DarkArena = 0
local AllBonus = 0
local AllClassico = 0
local Privado = 0
local timer_finish = nil
local timer_finish2 = nil
local timer_vivos = nil
local timer_vivos2 = nil
local gm = ''
local timer_chamar = nil
local timer_iniciar = nil
local timer_fase1 = nil
local Fase = 0
local segundo = ''
local terceiro = ''
local PlayersBlock = {}
local timerBlock = -1
local checkusers = false
local timer_block = nil
local timer_block2 = nil
local PlayersBlock2 = {}
local timerBlock2 = -1
local checkusers2 = false
local gmAbriu = ''
local NomeMT = ''
local timer = 0
local lutafinal = false
local Classe = 'BK / DL'
local NumeroClasse = 17

function MataMata.TimerEvento()

	Timer.Interval(30, MataMata.Init)
end

function MataMata.Init()

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
		
		if os.date("%X") >= "21:30:00" and os.date("%X") <= "21:31:00"
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			MataMata.CommandOpen_Auto()
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

		if EventoEscolhido == 'Mata-Mata'
		then
			DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
			MataMata.CommandOpen_Auto()
		else
			return
		end
	
	
	end
	
end


function MataMata.CommandOpen_Auto()
	
	AllBonus = 0
	AllClassico = 0
	Privado = 0
	NomeMT = 'ALL LIVRE'
	Classe = 'BK / DL'
	NumeroClasse = 17
	timer = 60
	
	gmAbriu = ''
	MataMata.AutoGM2()
	
	SendMessageGlobal(string.format("[Sistema] Mata-Mata %s!", NomeMT), 0)
	SendMessageGlobal(string.format("Digite: /mata-mata para participar."), 0)
end


function MataMata.CommandOpenAutoGM(aIndex, Arguments)
	
	if UserGetAuthority(aIndex) == 1
	then
		return
	end
	
	if started == true
	then
		SendMessage(string.format("[Sistema] Já existe um Mata-Mata aberto!"), aIndex, 1)
		return
	end
	
	
	local MtMtEscolhido = CommandGetString(Arguments, 1, 0)
	local Class = CommandGetString(Arguments, 2, 0)
	
	if MtMtEscolhido == ''
	then
		SendMessage(string.format("[Sistema] Informe o tipo de Mata-Mata! Exemplos:"), aIndex, 1)
		SendMessage(string.format("--> /abrirmata-mata livre"), aIndex, 1)
		SendMessage(string.format("--> /abrirmata-mata bonus"), aIndex, 1)
		SendMessage(string.format("--> /abrirmata-mata classico"), aIndex, 1)
		SendMessage(string.format("--> /abrirmata-mata privado"), aIndex, 1)
		return
	end
	
	if MtMtEscolhido == 'livre'
	then
		-- LIVRE
		AllBonus = 0
		AllClassico = 0
		Privado = 0
		NomeMT = 'ALL LIVRE'
		timer = 60
		
	elseif MtMtEscolhido == 'classico'
	then
		AllBonus = 0
		AllClassico = 1
		Privado = 0
		NomeMT = 'ALL CLASSICO'
		timer = 60
		
	elseif MtMtEscolhido == 'bonus'
	then
		AllBonus = 1
		AllClassico = 0
		Privado = 0
		NomeMT = 'ALL BONUS'
		timer = 60
		
	elseif MtMtEscolhido == 'privado'
	then
		AllBonus = 0
		AllClassico = 0
		Privado = 1
		NomeMT = 'PRIVADO'
		timer = 60
		
	else
		SendMessage(string.format("[Sistema] Informe o tipo de Mata-Mata! Exemplos:"), aIndex, 1)
		SendMessage(string.format("--> /abrirmata-mata livre"), aIndex, 1)
		SendMessage(string.format("--> /abrirmata-mata bonus"), aIndex, 1)
		SendMessage(string.format("--> /abrirmata-mata classico"), aIndex, 1)
		SendMessage(string.format("--> /abrirmata-mata privado"), aIndex, 1)
		return
	end
	
	
	if Class == 'elf'
	then
		Classe = 'ELF'
		NumeroClasse = 33
		
	elseif Class == 'bk'
	then
		Classe = 'BK / DL'
		NumeroClasse = 17
		
	elseif Class == 'sm'
	then
		Classe = 'SM'
		NumeroClasse = 1
		
	elseif Class == 'dl'
	then
		Classe = 'BK / DL'
		NumeroClasse = 17
		
	elseif Class == 'mg'
	then
		Classe = 'MG'
		NumeroClasse = 48
	
	else
	
		SendMessage(string.format("[Sistema] Classe do Mata-Mata não informada!"), aIndex, 1)
		SendMessage(string.format("--> Exemplo: /abrirmata-mata livre bk"), aIndex, 1)
		SendMessage(string.format("--> Exemplo 2: /abrirmata-mata livre elf"), aIndex, 1)
		return
		
	end
	
	
	gmAbriu = UserGetName(aIndex)
	
	MataMata.AutoGM2()
	
	DataBase.SetValue3("EVENTO_AUTO", "status", 1) -- status evento ON
	
	SendMessageGlobal(string.format("[%s]", UserGetName(aIndex)), 0)
	SendMessageGlobal(string.format("Evento Mata-Mata %s pra %s!", NomeMT, Classe), 0)
	SendMessageGlobal(string.format("Digite: /mata-mata para participar."), 0)
end

function MataMata.AutoGM2()

	timer_finish = nil
	timer_finish2 = nil
	timer_vivos = nil
	timer_vivos2 = nil
	gm = ''
	timer_chamar = nil
	timer_iniciar = nil
	timer_fase1 = nil
	segundo = ''
	terceiro = ''
	
	--timer = 60
	
	open = true
	started = false
	Players = {}
	Participantes = {}
	Fight1 = nil
	Fight2 = nil
	Fase = 0
	
	PlayersBlock = {}
	timerBlock = -1
	checkusers = false
	timer_block = nil
	PlayersBlock2 = {}
	timerBlock2 = -1
	checkusers2 = false
	timer_block2 = nil
	
	idtimer = Timer.Repeater(1, timer, MataMata.Running)
	
end


function MataMata.CheckParticipantes()
	for i, name in ipairs(Participantes) do 
		local index = Participantes[name].Index
		local nomeRemover = UserGetName(index)
		
		if UserGetConnected(index) < 3
		then
		
			--SendMessageGlobal(string.format("[Mata-Mata] %s saiu do jogo!", name), 0)

			if #Participantes == 3
			then
				terceiro = name
			end
					
			if #Participantes == 2
			then
				segundo = name
			end

			--Participantes[name].Index = -1
			--RemoveKey(Participantes, i)
			MataMata.RemoverPlayer(name)

		end


		if started == true
		then
			
			-- saiu do mapa do mt mt
			if UserGetMapNumber(index) ~= 6 and UserGetMapNumber(index) ~= 50
			then
				SendMessage(string.format("[Sistema] Você saiu do evento!"), index, 1)
				SendMessageGlobal(string.format("[Sistema] %s saiu do Mata-Mata!", name), 1)
				DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
					
				if #Participantes == 3
				then
					terceiro = name
				end
						
				if #Participantes == 2
				then
					segundo = name
				end
				
				Participantes[name].Index = -1
				RemoveKey(Participantes, i)
				MataMata.RemoverPlayer(name)
					
			end


			-- saiu de nova arena/dark arena por coordenada
			if UserGetMapNumber(index) == 6 or UserGetMapNumber(index) == 50
			then
				if UserGetX(index) < 186 and UserGetY(index) < 145 or UserGetX(index) > 246 and UserGetY(index) > 245
				then
					SendMessage(string.format("[Sistema] Você saiu do evento!"), index, 1)
					SendMessageGlobal(string.format("[Sistema] %s saiu do Mata-Mata!", name), 1)
					DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
					
					if #Participantes == 3
					then
						terceiro = name
					end
						
					if #Participantes == 2
					then
						segundo = name
					end
				
					Teleport(index, 0, 125, 125)
					Participantes[name].Index = -1
					RemoveKey(Participantes, i)
					MataMata.RemoverPlayer(name)
					
				end
			end
			
			
			-- checar itens mt mt all bônus
			
			if AllBonus == 1
			then
			
				-- set
				if InventoryGetIndex(index, 2) == GET_ITEM(7, MATAMATABONUS_ID_SET) and InventoryGetIndex(index, 3) == GET_ITEM(8, MATAMATABONUS_ID_SET) and InventoryGetIndex(index, 4) == GET_ITEM(9, MATAMATABONUS_ID_SET) and InventoryGetIndex(index, 5) == GET_ITEM(10, MATAMATABONUS_ID_SET) and InventoryGetIndex(index, 6) == GET_ITEM(11, MATAMATABONUS_ID_SET)
				then
					--
				else
					if #Participantes == 3
					then
						terceiro = name
					end
						
					if #Participantes == 2
					then
						segundo = name
					end
					
				
					Teleport(index, 0, 125, 125)
					SendMessageGlobal(string.format("[Sistema] %s movido por desequipar o Set do ALL Bônus!", name), 1)
					DataBase.SetValue("Character", "evento", 0, "Name", UserGetName(index)) -- remover participando evento
					DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
					Participantes[name].Index = -1
					RemoveKey(Participantes, i)
					MataMata.RemoverPlayer(name)
					return
				end
					
				-- sw
				if InventoryGetIndex(index, 0) == GET_ITEM(MATAMATABONUS_SECTION_ARMA, MATAMATABONUS_ID_ARMA)
				then
					--
				else
				
					if #Participantes == 3
					then
						terceiro = name
					end
						
					if #Participantes == 2
					then
						segundo = name
					end
					
					
					Teleport(index, 0, 125, 125)
					SendMessageGlobal(string.format("[Sistema] %s movido por desequipar a Arma do ALL Bônus!", name), 1)
					DataBase.SetValue("Character", "evento", 0, "Name", UserGetName(index)) -- remover participando evento
					DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
					Participantes[name].Index = -1
					RemoveKey(Participantes, i)
					MataMata.RemoverPlayer(name)
					return
				end
				
				-- sh
				if InventoryGetIndex(index, 1) == GET_ITEM(6, MATAMATABONUS_ID_SHIELD)
				then
					--
				else
				
					if #Participantes == 3
					then
						terceiro = name
					end
						
					if #Participantes == 2
					then
						segundo = name
					end
					

					Teleport(index, 0, 125, 125)
					SendMessageGlobal(string.format("[Sistema] %s movido por desequipar o Shield do ALL Bônus!", name), 1)
					DataBase.SetValue("Character", "evento", 0, "Name", UserGetName(index)) -- remover participando evento
					DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
					Participantes[name].Index = -1
					RemoveKey(Participantes, i)
					MataMata.RemoverPlayer(name)
					return
				end
				
				-- wing
				if InventoryGetIndex(index, 7) == GET_ITEM(12, MATAMATABONUS_ID_WING)
				then
					--
				else
					
					if #Participantes == 3
					then
						terceiro = name
					end
						
					if #Participantes == 2
					then
						segundo = name
					end

					Teleport(index, 0, 125, 125)
					SendMessageGlobal(string.format("[Sistema] %s movido por desequipar a Wing/Cape do ALL Bônus!", name), 1)
					DataBase.SetValue("Character", "evento", 0, "Name", UserGetName(index)) -- remover participando evento
					DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
					Participantes[name].Index = -1
					RemoveKey(Participantes, i)
					MataMata.RemoverPlayer(name)
					return
				end
				
				-- pet
				if InventoryGetIndex(index, 8) == GET_ITEM(13, MATAMATABONUS_ID_PET)
				then
					--
				else
					
					if #Participantes == 3
					then
						terceiro = name
					end
						
					if #Participantes == 2
					then
						segundo = name
					end
					

					Teleport(index, 0, 125, 125)
					SendMessageGlobal(string.format("[Sistema] %s movido por desequipar o Pet do ALL Bônus!", name), 1)
					DataBase.SetValue("Character", "evento", 0, "Name", UserGetName(index)) -- remover participando evento
					DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
					Participantes[name].Index = -1
					RemoveKey(Participantes, i)
					MataMata.RemoverPlayer(name)
					return
				end
				
				-- rings e pendant
				if InventoryGetIndex(index, 9) == GET_ITEM(13, MATAMATABONUS_ID_PENDANT) and InventoryGetIndex(index, 10) == GET_ITEM(13, MATAMATABONUS_ID_RING) and InventoryGetIndex(index, 11) == GET_ITEM(13, MATAMATABONUS_ID_RING)
				then
					--
				else
					
					if #Participantes == 3
					then
						terceiro = name
					end
						
					if #Participantes == 2
					then
						segundo = name
					end

					
					Teleport(index, 0, 125, 125)
					SendMessageGlobal(string.format("[Sistema] %s movido por desequipar o Kit Rings do ALL Bônus!", name), 1)
					DataBase.SetValue("Character", "evento", 0, "Name", UserGetName(index)) -- remover participando evento
					DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
					Participantes[name].Index = -1
					RemoveKey(Participantes, i)
					MataMata.RemoverPlayer(name)
					return
				end
			
			
			end
			
			-- fim checar itens mt mt all bônus




			-- checar itens mt mt clássico
			
			if AllClassico == 1
			then
			
				-- set
				if InventoryGetIndex(index, 2) >= GET_ITEM(7, 0) and InventoryGetIndex(index, 2) <= GET_ITEM(7, 31) and InventoryGetIndex(index, 3) >= GET_ITEM(8, 0) and InventoryGetIndex(index, 3) <= GET_ITEM(8, 31) and InventoryGetIndex(index, 4) >= GET_ITEM(9, 0) and InventoryGetIndex(index, 4) <= GET_ITEM(9, 31) and InventoryGetIndex(index, 5) >= GET_ITEM(10, 0) and InventoryGetIndex(index, 5) <= GET_ITEM(10, 31) and InventoryGetIndex(index, 6) >= GET_ITEM(11, 0) and InventoryGetIndex(index, 6) <= GET_ITEM(11, 31)
				then
					--
				else
					
					if #Participantes == 3
					then
						terceiro = name
					end
						
					if #Participantes == 2
					then
						segundo = name
					end
					

					SendMessage(string.format("[Sistema] Você foi movido por equipar um Set diferente dos Clássicos"), index, 1)
					Teleport(index, 0, 125, 125)
					SendMessageGlobal(string.format("[Sistema] %s movido por desequipar um item Clássico!", UserGetName(index)), 1)
					DataBase.SetValue("Character", "evento", 0, "Name", UserGetName(index)) -- remover participando evento
					DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
					Participantes[name].Index = -1
					RemoveKey(Participantes, i)
					MataMata.RemoverPlayer(name)
					return
				end
					
				-- sw
				if InventoryGetIndex(index, 0) >= GET_ITEM(0, 0) and InventoryGetIndex(index, 0) <= GET_ITEM(0, 31) or InventoryGetIndex(index, 0) >= GET_ITEM(1, 0) and InventoryGetIndex(index, 0) <= GET_ITEM(1, 8) or InventoryGetIndex(index, 0) >= GET_ITEM(2, 0) and InventoryGetIndex(index, 0) <= GET_ITEM(2, 13) or InventoryGetIndex(index, 0) ~= GET_ITEM(2, 7) or InventoryGetIndex(index, 0) <= GET_ITEM(2, 10)
				then
					--
				else
					
					if #Participantes == 3
					then
						terceiro = name
					end
						
					if #Participantes == 2
					then
						segundo = name
					end
					
					SendMessage(string.format("[Sistema] Você foi movido por equipar uma Sword diferente das Clássicas"), index, 1)
					Teleport(index, 0, 125, 125)
					SendMessageGlobal(string.format("[Sistema] %s movido por desequipar um item Clássico!", UserGetName(index)), 1)
					DataBase.SetValue("Character", "evento", 0, "Name", UserGetName(index)) -- remover participando evento
					DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
					Participantes[name].Index = -1
					RemoveKey(Participantes, i)
					MataMata.RemoverPlayer(name)
					return
				end
				
				-- sh
				if InventoryGetIndex(index, 1) >= GET_ITEM(6, 0) or InventoryGetIndex(index, 1) <= GET_ITEM(6, 16)
				then
					--
				else
					
					if #Participantes == 3
					then
						terceiro = name
					end
						
					if #Participantes == 2
					then
						segundo = name
					end
					
					
					SendMessage(string.format("[Sistema] Você foi movido por equipar um Shield diferente dos Clássicos"), index, 1)
					Teleport(index, 0, 125, 125)
					SendMessageGlobal(string.format("[Sistema] %s movido por desequipar um item Clássico!", UserGetName(index)), 1)
					DataBase.SetValue("Character", "evento", 0, "Name", UserGetName(index)) -- remover participando evento
					DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
					Participantes[name].Index = -1
					RemoveKey(Participantes, i)
					MataMata.RemoverPlayer(name)
					return
				end
				
				-- wing
				if InventoryGetIndex(index, 7) >= GET_ITEM(12, 0) or InventoryGetIndex(index, 7) <= GET_ITEM(12, 6)
				then
					--
				else
					
					if #Participantes == 3
					then
						terceiro = name
					end
						
					if #Participantes == 2
					then
						segundo = name
					end
					

					SendMessage(string.format("[Sistema] Você foi movido por equipar uma Wing diferente das Clássicas"), index, 1)
					Teleport(index, 0, 125, 125)
					SendMessageGlobal(string.format("[Sistema] %s movido por desequipar um item Clássico!", UserGetName(index)), 1)
					DataBase.SetValue("Character", "evento", 0, "Name", UserGetName(index)) -- remover participando evento
					DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
					Participantes[name].Index = -1
					RemoveKey(Participantes, i)
					MataMata.RemoverPlayer(name)
					return
				end
				
				-- pet
				if InventoryGetIndex(index, 8) >= GET_ITEM(13, 0) and InventoryGetIndex(index, 8) <= GET_ITEM(13, 2)
				then
					--
				else
					
					if #Participantes == 3
					then
						terceiro = name
					end
						
					if #Participantes == 2
					then
						segundo = name
					end

					
					SendMessage(string.format("[Sistema] Você foi movido por equipar um Pet diferente dos Clássicos"), index, 1)
					Teleport(index, 0, 125, 125)
					SendMessageGlobal(string.format("[Sistema] %s movido por desequipar um item Clássico!", UserGetName(index)), 1)
					DataBase.SetValue("Character", "evento", 0, "Name", UserGetName(index)) -- remover participando evento
					DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
					Participantes[name].Index = -1
					RemoveKey(Participantes, i)
					MataMata.RemoverPlayer(name)
					return
				end
				
				-- rings e pendant
				if InventoryGetIndex(index, 9) == GET_ITEM(13, 13) and InventoryGetIndex(index, 10) == GET_ITEM(13, 9) and InventoryGetIndex(index, 11) == GET_ITEM(13, 9) or InventoryGetIndex(index, 9) == GET_ITEM(13, 13) and InventoryGetIndex(index, 10) == GET_ITEM(13, 8) and InventoryGetIndex(index, 11) == GET_ITEM(13, 8) or InventoryGetIndex(index, 9) == GET_ITEM(13, 12) and InventoryGetIndex(index, 10) == GET_ITEM(13, 9) and InventoryGetIndex(index, 11) == GET_ITEM(13, 9) or InventoryGetIndex(index, 9) == GET_ITEM(13, 12) and InventoryGetIndex(index, 10) == GET_ITEM(13, 8) and InventoryGetIndex(index, 11) == GET_ITEM(13, 8)
				then
					--
				else
					
					if #Participantes == 3
					then
						terceiro = name
					end
						
					if #Participantes == 2
					then
						segundo = name
					end
					
					
					SendMessage(string.format("[Sistema] Você foi movido por equipar um Kit diferente dos Clássicos"), index, 1)
					Teleport(index, 0, 125, 125)
					SendMessageGlobal(string.format("[Sistema] %s movido por desequipar um item Clássico!", UserGetName(index)), 1)
					DataBase.SetValue("Character", "evento", 0, "Name", UserGetName(index)) -- remover participando evento
					DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
					Participantes[name].Index = -1
					RemoveKey(Participantes, i)
					MataMata.RemoverPlayer(name)
					return
				end
			
			
			end
			
			-- fim checar itens mt mt clássico

			
		

		end

		
	end
	
	if CountTable(Participantes) < 1
	then
		if idtimercheck ~= -1
		then
			Timer.Cancel(idtimercheck)
			idtimercheck = -1
		end
		
		if idtimerParticipante ~= -1
		then
			Timer.Cancel(idtimerParticipante)
			idtimerParticipante = -1
		end
	end
end


function MataMata.CommandVS(aIndex, Arguments)
	
	if UserGetAuthority(aIndex) == 1
	then
		return
	end
	
	if started == true
	then
		SendMessage(string.format("[Sistema] Você não pode puxar players para"), aIndex, 1)
		SendMessage(string.format("Nova Arena/Dark Arena neste momento."), aIndex, 1)
		return
	end
	
	local Name = CommandGetString(Arguments, 1, 0)
	local TargetIndex = GetIndex(Name)
	
	if TargetIndex == -1
	then
		SendMessage(string.format("[Sistema] %s está offline ou não existe", Name), aIndex, 1)
		return
	end
	
	local Name2 = CommandGetString(Arguments, 2, 0)
	local TargetIndex2 = GetIndex(Name2)
	
	if TargetIndex2 == -1
	then
		SendMessage(string.format("[Sistema] %s está offline ou não existe", Name2), aIndex, 1)
		return
	end
	
	SendMessageGlobal(string.format(".:: [ LUTA ENTRE: ] ::."), 0)
	SendMessageGlobal(string.format("<<~ %s [vs] %s ~>>", Name, Name2), 0)
	
	if DarkArena == 1
	then
		if started == true
		then
			InsertKey(Participantes, Name)
			Participantes[Name] = {Index = TargetIndex, Step = StepRunning}
		end
		
		Teleport(TargetIndex, KILL_MAP2, 215, 195)
		
		if started == true
		then
			InsertKey(Participantes, Name2)
			Participantes[Name2] = {Index = TargetIndex2, Step = StepRunning}
		end
		
		Teleport(TargetIndex2, KILL_MAP2, 216, 195)
	else
		
		if started == true
		then
			InsertKey(Participantes, Name)
			Participantes[Name] = {Index = TargetIndex, Step = StepRunning}
		end
		
		Teleport(TargetIndex, KILL_MAP, 215, 195)
		
		if started == true
		then
			InsertKey(Participantes, Name2)
			Participantes[Name2] = {Index = TargetIndex2, Step = StepRunning}
		end
		
		Teleport(TargetIndex2, KILL_MAP, 216, 195)
	end

	
end


function MataMata.CheckIntruders()
	if KILL_CHECK_USERS == 1
	then
		for i = 9000, 9999 do
			if UserGetConnected(i) == 3
			then
				if UserGetAuthority(i) == 1
				then
					if UserGetMapNumber(i) == KILL_MAP
					then
						if MataMata.IsParticipante(i) == 0
						then
							if UserGetX(i) >= KILL_AREA_CHECK_COORD_X_1 and UserGetY(i) >= KILL_AREA_CHECK_COORD_Y_1 and UserGetX(i) <= KILL_AREA_CHECK_COORD_X_2 and UserGetY(i) <= KILL_AREA_CHECK_COORD_Y_2
							then
								Teleport(i, 0, 125, 125)
								DataBase.SetValue("Character", "evento", 0, "Name", UserGetName(i)) -- remover participando evento
								SendMessage(string.format("[Sistema] Você não pode ficar em Nova Arena neste momento."), i, 1)
							end
						end
					end
					
					-- dark arena
					if UserGetMapNumber(i) == KILL_MAP2
					then
						if MataMata.IsParticipante(i) == 0
						then
							if UserGetX(i) >= KILL_AREA_CHECK_COORD_X_1 and UserGetY(i) >= KILL_AREA_CHECK_COORD_Y_1 and UserGetX(i) <= KILL_AREA_CHECK_COORD_X_2 and UserGetY(i) <= KILL_AREA_CHECK_COORD_Y_2
							then
								Teleport(i, 0, 125, 125)
								DataBase.SetValue("Character", "evento", 0, "Name", UserGetName(i)) -- remover participando evento
								SendMessage(string.format("[Sistema] Você não pode ficar em Dark Arena neste momento."), i, 1)
							end
						end
					end
					
					
				end
			end
		end
	end
end

function MataMata.IsParticipante(index)
	local IsParticipante = 0
	
	for i, name in ipairs(Participantes) do 
		if Participantes[name].Index == index
		then
			IsParticipante = 1
			break
		end
	end
	
	return IsParticipante
end

function MataMata.Running()
	if timer == 0
	then
	
		timer_vivos = Timer.Interval(3, MataMata.CheckVivos)
		timer_finish = Timer.TimeOut(20 * 60, MataMata.FinishEvent)
		PlayersBlock = {}
		PlayersBlock2 = {}
		lutafinal = false

		for i, name in ipairs(Players) do 
			local index = Players[name]
			
			Teleport(index, KILL_MAP, KILL_COORD_X, KILL_COORD_Y)
			DataBase.SetValue("Character", "block_limparpk", 1, "Name", UserGetName(index)) -- add block limpar pk
			UserSetPKLevel(index, 6)
			PkLevelSend(index, UserGetPKLevel(index))

			InsertKey(Participantes, name)
			Participantes[name] = {Index = index, Step = 1}
			
		end
		
		
		if #Participantes < 4
		then
			SendMessageGlobal(string.format("[Sistema] O evento não pode iniciar"), 0)
			SendMessageGlobal(string.format("porque vieram menos de 4 players!"), 0)
			
			for i, name in ipairs(Participantes) do 
				local index = Participantes[name].Index
				local NickRemover = UserGetName(index)
				
				if UserGetConnected(index) ~= 3
				then
					MataMata.RemoverPlayer(name)
				end
				
				Teleport(index, 0, 125, 125)
				DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
				
			end
			
			started = false

			if timer_finish ~= nil
			then
				Timer.Cancel(timer_finish)
				timer_finish = nil
			end
			
			if timer_finish2 ~= nil
			then
				Timer.Cancel(timer_finish2)
				timer_finish2 = nil
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
			
			if timer_iniciar ~= nil
			then
				Timer.Cancel(timer_iniciar)
				timer_iniciar = nil
			end
			
			if timer_chamar ~= nil
			then
				Timer.Cancel(timer_chamar)
				timer_chamar = nil
			end
			
			if timer_fase1 ~= nil
			then
				Timer.Cancel(timer_fase1)
				timer_fase1 = nil
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
			
			Timer.Cancel(idtimercheck)
			Timer.Cancel(idtimerParticipante)
			Timer.Cancel(timer_block)
			Timer.Cancel(timer_block2)
			Timer.Cancel(timerBlock)
			Timer.Cancel(timerBlock2)
			idtimercheck = -1
			idtimerParticipante = -1
			started = false
			Players = {}
			Participantes = {}
			StepRunning = 0
			AllBonus = 0
			Privado = 0
			segundo = ''
			terceiro = ''
			
			Timer.TimeOut(4, MataMata.StatusOFFevent)
			
			return
			
		end	

		
		open = false
		SendMessageGlobal(string.format("Move %s fechou!", KILL_COMMAND_GO), 0)
		
		DarkArena = 0
		
		if idtimercheck == -1
		then
			idtimercheck = Timer.Interval(1, MataMata.CheckParticipantes)
		else
			Timer.Cancel(idtimercheck)
			
			idtimercheck = Timer.Interval(1, MataMata.CheckParticipantes)
		end
		
		if idtimerParticipante == -1
		then
			idtimerParticipante = Timer.Interval(5, MataMata.CheckIntruders)
		else
			Timer.Cancel(idtimerParticipante)
			
			idtimerParticipante = Timer.Interval(5, MataMata.CheckIntruders)
		end
		
		timer_iniciar = Timer.TimeOut(3, MataMata.CommandInit)
		
	else
		SendMessageGlobal(string.format("%s %s para %s fecha em %d seg", KILL_COMMAND_GO, NomeMT, Classe, timer), 0)
		
		timer = timer - 1
	end
end



function MataMata.Contagem()

	if started == false
	then
		return
	end
	
	timer_andar = Timer.Interval(1, MataMata.CheckAndar)
	
	SendMessageGlobal(string.format("[Sistema]"), 0)
	SendMessageGlobal(string.format("ATENÇÃO - JAH!!!"), 0)

	DataBase.SetValue("Character", "eventoaguardehit", 0, "Name", UserGetName(Fight1)) -- remover participando evento aguarde hit
	DataBase.SetValue("Character", "eventoaguardehit", 0, "Name", UserGetName(Fight2)) -- remover participando evento aguarde hit
			

end


function MataMata.CheckAndar()

	if started == false
	then
		return
	end


	-- player1 saiu do jogo
	if UserGetConnected(Fight1) ~= 3
	then
		local Nick = UserGetName(Fight2)
		MataMata.AnunciarDC()
		MataMata.CommandWinsAuto(Nick)

	-- player2 saiu do jogo
	elseif UserGetConnected(Fight2) ~= 3
	then
		local Nick = UserGetName(Fight1)
		MataMata.AnunciarDC()
		MataMata.CommandWinsAuto(Nick)

	-- player1 e 2 saíram do jogo
	elseif UserGetConnected(Fight1) ~= 3 and UserGetConnected(Fight2) ~= 3
	then
		MataMata.AnunciarDCambos()
	
	-- player 1 andou
	elseif UserGetX(Fight1) ~= 216 and UserGetY(Fight1) ~= 195
	then
		local nomePlayer = UserGetName(Fight1)
		local Nick = UserGetName(Fight2)
		MataMata.AnunciarAndou(nomePlayer, Nick)
		Fight1 = nil
		Teleport(Fight1, 0, 125, 125)
		DataBase.SetValue("Character", "block_limparpk", 0, "Name", nomePlayer) -- remover block limpar pk
		
	-- player 2 andou
	elseif UserGetX(Fight2) ~= 217 and UserGetY(Fight2) ~= 195
	then
		local nomePlayer = UserGetName(Fight2)
		local Nick = UserGetName(Fight1)
		MataMata.AnunciarAndou(nomePlayer, Nick)
		Fight2 = nil
		Teleport(Fight2, 0, 125, 125)
		DataBase.SetValue("Character", "block_limparpk", 0, "Name", nomePlayer) -- remover block limpar pk
		
		
	end


end



function MataMata.AnunciarAndou(nomePlayer, Nick)

	if started == false
	then
		return
	end
	
	if timer_andar ~= nil
	then
		Timer.Cancel(timer_andar)
		timer_andar = nil
	end

	
	if GetIndex(nomePlayer) > 500
	then
		SendMessageGlobal(string.format("[Mata-Mata] %s andou!", nomePlayer), 0)
	end
	
	
	if #Participantes == 3
	then
		terceiro = nomePlayer
	end
		
	if #Participantes == 2
	then
		segundo = nomePlayer
	end
		
	
	-- wins para o vencedor
	MataMata.CommandWinsAuto(Nick)
	
	--MataMata.CheckVivos()
		
	
end





function MataMata.AnunciarDC()

	if started == false
	then
		return
	end
	
	if timer_andar ~= nil
	then
		Timer.Cancel(timer_andar)
		timer_andar = nil
	end


	SendMessageGlobal(string.format("[Mata-Mata] O adversário saiu do jogo! Sendo assim:"), 0)
	
		
end



function MataMata.AnunciarDCambos()

	if started == false
	then
		return
	end
	
	if timer_andar ~= nil
	then
		Timer.Cancel(timer_andar)
		timer_andar = nil
	end

	
	SendMessageGlobal(string.format("[Mata-Mata] Luta finalizada porque ambos os adversários saíram do jogo!"), 0)

	
	MataMata.CheckVivos()
	
	
	if #Participantes > 1
	then
		MataMata.CommandStepAuto()
	end
	
		
end



function MataMata.CommandGo(aIndex, Arguments)
	if KILL_SWITCH == 0
	then
		return
	end
	
	if open == false
	then
		SendMessage(string.format("[Sistema] Mata-Mata não está aberto neste momento!"), aIndex, 1)
		return
	end
	
	
	if NumeroClasse == 17
	then
	
		if UserGetDbClass(aIndex) ~= NumeroClasse and UserGetDbClass(aIndex) ~= 64
		then
			SendMessage(string.format("[Sistema] Esse Mata-Mata é somente para a classe: %s!", Classe), aIndex, 1)
			return
		end
		
	else
	
		if UserGetDbClass(aIndex) ~= NumeroClasse
		then
			SendMessage(string.format("[Sistema] Esse Mata-Mata é somente para a classe: %s!", Classe), aIndex, 1)
			return
		end
		
	end
	
	
	if UserGetLevel(aIndex) < 100
	then
		SendMessage(string.format("[Sistema] Você precisa estar acima do level %d", 100), aIndex, 1)
		return
	end
	
	if DataBase.GetValue(TABLE_VIP, COLUMN_VIP, WHERE_VIP, UserGetAccountID(aIndex)) < KILL_VIP
	then
		SendMessage(string.format("[Sistema] Somente usuários vip podem usar este comando!"), aIndex, 1)
		return
	end
	
	local Name = UserGetName(aIndex)

	if DataBase.GetValue(TABLE_RESET, COLUMN_RESET[0], WHERE_RESET, Name) < KILL_RESETS
	then
		SendMessage(string.format("[Sistema] Você precisa de %d resets", KILL_RESETS), aIndex, 1)
		return
	end
	
	if DataBase.GetValue(TABLE_MRESET, COLUMN_MRESET[0], WHERE_MRESET, Name) < KILL_MRESETS
	then
		SendMessage(string.format("[Sistema] Você precisa de %d M.Resets", KILL_MRESETS), aIndex, 1)
		return
	end
	
	
	
	
	-- Mata-Mata ALL Bônus
	
	if AllBonus == 1
	then
	
		-- set
		if InventoryGetIndex(aIndex, 2) == GET_ITEM(7, MATAMATABONUS_ID_SET) and InventoryGetIndex(aIndex, 3) == GET_ITEM(8, MATAMATABONUS_ID_SET) and InventoryGetIndex(aIndex, 4) == GET_ITEM(9, MATAMATABONUS_ID_SET) and InventoryGetIndex(aIndex, 5) == GET_ITEM(10, MATAMATABONUS_ID_SET) and InventoryGetIndex(aIndex, 6) == GET_ITEM(11, MATAMATABONUS_ID_SET)
		then
			--
		else
			SendMessage(string.format("[Sistema] Você precisa estar equipado com %s", MATAMATABONUS_NOME_SET), aIndex, 1)
			--SendMessage(string.format("--> Caso não tenha um, digite: /bonus"), aIndex, 1)
			return
		end
			
		-- sw
		if InventoryGetIndex(aIndex, 0) == GET_ITEM(MATAMATABONUS_SECTION_ARMA, MATAMATABONUS_ID_ARMA)
		then
			--
		else
			SendMessage(string.format("[Sistema] Você precisa estar com %s", MATAMATABONUS_NOME_ARMA), aIndex, 1)
			--SendMessage(string.format("--> Caso não tenha uma, digite: /bonus"), aIndex, 1)
			return
		end
		
		-- sh
		if InventoryGetIndex(aIndex, 1) == GET_ITEM(6, MATAMATABONUS_ID_SHIELD)
		then
			--
		else
			SendMessage(string.format("[Sistema] Você precisa estar equipado com %s", MATAMATABONUS_NOME_SHIELD), aIndex, 1)
			--SendMessage(string.format("--> Caso não tenha um, digite: /bonus"), aIndex, 1)
			return
		end
		
		-- wing
		if InventoryGetIndex(aIndex, 7) == GET_ITEM(12, MATAMATABONUS_ID_WING)
		then
			--
		else
			SendMessage(string.format("[Sistema] Você precisa estar equipado com %s", MATAMATABONUS_NOME_WING), aIndex, 1)
			--SendMessage(string.format("--> Caso não tenha uma, digite: /bonus"), aIndex, 1)
			return
		end
		
		-- pet
		if InventoryGetIndex(aIndex, 8) == GET_ITEM(13, MATAMATABONUS_ID_PET)
		then
			--
		else
			SendMessage(string.format("[Sistema] Você precisa estar equipado com %s", MATAMATABONUS_NOME_PET), aIndex, 1)
			--SendMessage(string.format("--> Caso não tenha um, digite: /bonus"), aIndex, 1)
			return
		end
		
		-- pendant
		if InventoryGetIndex(aIndex, 9) == GET_ITEM(13, MATAMATABONUS_ID_PENDANT)
		then
			--
		else
			SendMessage(string.format("[Sistema] Você precisa estar equipado com %s", MATAMATABONUS_NOME_PENDANT), aIndex, 1)
			--SendMessage(string.format("--> Caso não tenha, digite: /bonus"), aIndex, 1)
			return
		end
		
		-- ring
		if InventoryGetIndex(aIndex, 10) == GET_ITEM(13, MATAMATABONUS_ID_RING) and InventoryGetIndex(aIndex, 11) == GET_ITEM(13, MATAMATABONUS_ID_RING)
		then
			--
		else
			SendMessage(string.format("[Sistema] Você precisa estar equipado com 2 %s", MATAMATABONUS_NOME_RING), aIndex, 1)
			--SendMessage(string.format("--> Caso não tenha, digite: /bonus"), aIndex, 1)
			return
		end
		
	
	end
	
	
	----
	
	
	if AllClassico == 1
	then
	
		-- set
		if InventoryGetIndex(aIndex, 2) >= GET_ITEM(7, 0) and InventoryGetIndex(aIndex, 2) <= GET_ITEM(7, 31) and InventoryGetIndex(aIndex, 3) >= GET_ITEM(8, 0) and InventoryGetIndex(aIndex, 3) <= GET_ITEM(8, 31) and InventoryGetIndex(aIndex, 4) >= GET_ITEM(9, 0) and InventoryGetIndex(aIndex, 4) <= GET_ITEM(9, 31) and InventoryGetIndex(aIndex, 5) >= GET_ITEM(10, 0) and InventoryGetIndex(aIndex, 5) <= GET_ITEM(10, 31) and InventoryGetIndex(aIndex, 6) >= GET_ITEM(11, 0) and InventoryGetIndex(aIndex, 6) <= GET_ITEM(11, 31)
		then
			--
		else
			SendMessage(string.format("[Sistema] Você precisa estar equipado com Set Clássico!"), aIndex, 1)
			return
		end
				
		-- sw
		if InventoryGetIndex(aIndex, 0) >= GET_ITEM(0, 0) and InventoryGetIndex(aIndex, 0) <= GET_ITEM(0, 31) or InventoryGetIndex(aIndex, 0) >= GET_ITEM(1, 0) and InventoryGetIndex(aIndex, 0) <= GET_ITEM(1, 8) or InventoryGetIndex(aIndex, 0) >= GET_ITEM(2, 0) and InventoryGetIndex(aIndex, 0) <= GET_ITEM(2, 13)
		then
			--
		else
			SendMessage(string.format("[Sistema] Você precisa estar equipado com Arma Clássica!"), aIndex, 1)
			return
		end
			
		-- sh
		if InventoryGetIndex(aIndex, 1) >= GET_ITEM(6, 0) or InventoryGetIndex(aIndex, 1) <= GET_ITEM(6, 16)
		then
			--
		else
			SendMessage(string.format("[Sistema] Você precisa estar equipado com Shield Clássico!"), aIndex, 1)
			return
		end
			
		-- wing
		if InventoryGetIndex(aIndex, 7) >= GET_ITEM(12, 0) or InventoryGetIndex(aIndex, 7) <= GET_ITEM(12, 6)
		then
			--
		else
			SendMessage(string.format("[Sistema] Você precisa estar equipado com Wing Clássica!"), aIndex, 1)
			return
		end
			
		-- pet
		if InventoryGetIndex(aIndex, 8) >= GET_ITEM(13, 0) and InventoryGetIndex(aIndex, 8) <= GET_ITEM(13, 2)
		then
			--
		else
			SendMessage(string.format("[Sistema] Você precisa estar equipado com Pet Clássico!"), aIndex, 1)
			return
		end
			
		-- rings e pendant
		if InventoryGetIndex(aIndex, 9) == GET_ITEM(13, 13) and InventoryGetIndex(aIndex, 10) == GET_ITEM(13, 9) and InventoryGetIndex(aIndex, 11) == GET_ITEM(13, 9) or InventoryGetIndex(aIndex, 9) == GET_ITEM(13, 13) and InventoryGetIndex(aIndex, 10) == GET_ITEM(13, 8) and InventoryGetIndex(aIndex, 11) == GET_ITEM(13, 8) or InventoryGetIndex(aIndex, 9) == GET_ITEM(13, 12) and InventoryGetIndex(aIndex, 10) == GET_ITEM(13, 9) and InventoryGetIndex(aIndex, 11) == GET_ITEM(13, 9) or InventoryGetIndex(aIndex, 9) == GET_ITEM(13, 12) and InventoryGetIndex(aIndex, 10) == GET_ITEM(13, 8) and InventoryGetIndex(aIndex, 11) == GET_ITEM(13, 8)
		then
			--
		else
			SendMessage(string.format("[Sistema] Você precisa estar equipado com Rings Poison e Pendant Fire!"), aIndex, 1)
			return
		end
	
	
	end
	
	
	
	
	------
	
	
	
	if Privado == 1
	then
	
		local items_uso = 0
		
		for i = 12, 75 do
			if InventoryIsItem(aIndex, i) == 1
			then
				if InventoryGetIndex(aIndex, i) == GET_ITEM(14, 77)
				then
					if InventoryGetLevel(aIndex, i) == 0
					then
						items_uso = items_uso + 1
					end
				end
					
					
			end
		end
		

		if items_uso < 1
		then
			SendMessage(string.format("[Sistema] Você precisa ter 1 Convite de Mata-Mata Privado no seu inventário!"), aIndex, 1)
			return
		end
		
		if items_uso > 1
		then
			SendMessage(string.format("[Sistema] Deixe apenas (1) Convite no seu inventário. Nem mais, nem menos!"), aIndex, 1)
			return
		end
		
		
		for i = 12, 75 do
			if InventoryIsItem(aIndex, i) == 1
			then
				if InventoryGetIndex(aIndex, i) == GET_ITEM(14, 77)
				then
					if InventoryGetLevel(aIndex, i) == 0
					then
						InventoryDeleteItem(aIndex, i)
						SendInventoryDeleteItem(aIndex, i)
					end
						
				end
			end
		end
	
	
	
	end
	
	
	
	-----
	
	
	
	
	if UserGetAuthority(aIndex) ~= 1
	then
		SendMessage(string.format("[Sistema] STAFFERs não podem participar de eventos!"), aIndex, 1)
		return
	end
	
	if Players[UserGetName(aIndex)] == nil
	then
		InsertKey(Players, UserGetName(aIndex))
		
		Players[UserGetName(aIndex)] = aIndex
		
		Teleport(aIndex, 50, 241, 195)
		
		SendMessage(string.format("[Sistema] Você foi movido para o Mata-Mata! Aguarde começar..."), aIndex, 1)
	else
		Teleport(aIndex, 50, 241, 195)
		SendMessage(string.format("[Sistema] Você foi movido para o Mata-Mata! Aguarde começar..."), aIndex, 1)
	end
end

function MataMata.CommandInit(aIndex, Arguments)
	
	
	SendMessageGlobal(string.format(" "), 0)
	SendMessageGlobal(string.format(" --- MATA-MATA INICIADO! --- "), 0)

	Fase = 0
	started = true
	
	timer_fase1 = Timer.TimeOut(3, MataMata.CommandStepAuto)
	timer_block = MataMata.CommandOpenBlock()
	timer_block2 = MataMata.CommandOpenBlock2()
	
	
end


function MataMata.CommandStepAuto()
	
	if started == false
	then
		return
	end
	
	if timer_andar ~= nil
	then
		Timer.Cancel(timer_andar)
		timer_andar = nil
	end
	
	local Step = Fase
	
	Step = math.floor(Step+1)
	Fase = Step
	
	-- ao digitar /fase 1
	if Step == 1
	then
		DarkArena = 0
	end
	
	-- ao digitar /fase maior que 1
	if Step > 1
	then
		DarkArena = 1
	end
	
	
	if Step % 2 == 0
	then
		side = 2
	else
		side = 1
	end
	
	StepRunning = Step
	
	
	if #Participantes == 1
	then
		MataMata.CheckVivos()
		return
	end
	
	if #Participantes == 3
	then
		SendMessageGlobal(string.format("========================"), 0)
		SendMessageGlobal(string.format("~ SEMI-FINAL DO MATA-MATA! ~"), 0)
		SendMessageGlobal(string.format("========================"), 0)
		
	elseif #Participantes == 2
	then
		SendMessageGlobal(string.format("========================"), 0)
		SendMessageGlobal(string.format("~ FINAL DO MATA-MATA! ~"), 0)
		SendMessageGlobal(string.format("========================"), 0)
		
	else
		SendMessageGlobal(string.format("========================"), 0)
		SendMessageGlobal(string.format("~ Fase (%d) iniciada! ~", Step), 0)
		
		if Step == 2
		then
			SendMessageGlobal(string.format("(O evento agora será em Dark Arena)"), 0)
		end
		
		SendMessageGlobal(string.format("========================"), 0)
	end
	
	
	if DarkArena == 1
	then
		-- teleportar o gm para o meio
		Teleport(aIndex, KILL_MAP2, 216, 192)
	else
	-- teleportar o gm para o meio
		Teleport(aIndex, KILL_MAP, 216, 192)
	end
	
	
	if #Participantes > 1
	then
		timer_chamar = Timer.TimeOut(2, MataMata.CommandCallAuto)
	end
	
end


function MataMata.CommandWinsAuto(Nick)

	if started == false
	then
		return
	end
	
	if timer_andar ~= nil
	then
		Timer.Cancel(timer_andar)
		timer_andar = nil
	end
	
	if timer_finish2 ~= nil
	then
		Timer.Cancel(timer_finish2)
		timer_finish2 = nil
	end
	
	local Name = Nick
	local TargetIndex = GetIndex(Nick)
	
	
	if UserGetConnected(TargetIndex) ~= 3
	then
	
		SendMessageGlobal(string.format("[Mata-Mata] O vencedor da luta saiu do jogo!"), 0)
		
		Fight1 = nil
		Fight2 = nil
		
		if #Participantes > 1 and lutafinal == false
		then
			timer_chamar = Timer.TimeOut(3, MataMata.CommandCallAuto) -- chamar
			
		elseif #Participantes > 1 and lutafinal == true
		then
			MataMata.CheckVivos()
			
		elseif #Participantes == 1
		then
			MataMata.CheckVivos()
		end
		
		return
		
	end
	
	
	if TargetIndex > 500
	then
		SendMessageGlobal(string.format("%s Wins!", Name), 0)
	end

		
	if TargetIndex == Fight1
	then
		if UserGetConnected(Fight2) == 3 and Participantes[UserGetName(Fight2)] ~= nil
		then
			MataMata.RemoverPlayer(UserGetName(Fight2))
			Teleport(Fight2, 0, 125, 125)
			DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(Fight2)) -- remover block limpar pk
		end

	elseif TargetIndex == Fight2
	then
		if UserGetConnected(Fight1) == 3 and Participantes[UserGetName(Fight1)] ~= nil
		then
			MataMata.RemoverPlayer(UserGetName(Fight1))
			Teleport(Fight1, 0, 125, 125)
			DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(Fight1)) -- remover block limpar pk
		end
		
	end
	
	Fight1 = nil
	Fight2 = nil
	
	MataMata.MovePlayerWins(TargetIndex, Name)
	

	if #Participantes > 1 and lutafinal == false
	then
		timer_chamar = Timer.TimeOut(3, MataMata.CommandCallAuto) -- chamar
		
	elseif #Participantes > 1 and lutafinal == true
	then
		MataMata.CheckVivos()
		
	elseif #Participantes == 1
	then
		MataMata.CheckVivos()
	end
	
	
end

function MataMata.MovePlayerWins(aIndex, Name)
	Participantes[Name].Step = Participantes[Name].Step + 1
	
	if side == 1
	then
		if DarkArena == 1
		then
			Teleport(aIndex, KILL_MAP2, KILL_COORD_TOP_X, KILL_COORD_TOP_Y)
		else
			Teleport(aIndex, KILL_MAP, KILL_COORD_TOP_X, KILL_COORD_TOP_Y)
		end
	else
		if DarkArena == 1
		then
			Teleport(aIndex, KILL_MAP2, KILL_COORD_DOWN_X, KILL_COORD_DOWN_Y)
		else
			Teleport(aIndex, KILL_MAP, KILL_COORD_DOWN_X, KILL_COORD_DOWN_Y)
		end
		
	end
end

function MataMata.RemoverPlayer(Player)
	for i, name in ipairs(Participantes) do
		if name == Player
		then
			Participantes[name].Index = -1
			RemoveKey(Participantes, i)
		end
	end
end


function MataMata.RemoveUser(Player)
	for i, name in ipairs(Players) do
		if name == Player
		then
			Players[name].Index = -1
			RemoveKey(Players, i)
		end
	end
end



function MataMata.CommandCallAuto()
	
	if started == false
	then
		return
	end
	
	
	if #Participantes == 1
	then
		MataMata.CheckVivos()
		return
	end
	
	
	if timer_andar ~= nil
	then
		Timer.Cancel(timer_andar)
		timer_andar = nil
	end
	


	-- caso só tenha 2 no mt mt 
	
	if #Participantes == 2
	then
	
		lutafinal = true
		
		SendMessageGlobal(string.format("========================"), 0)
		SendMessageGlobal(string.format("~ FINAL DO MATA-MATA! ~"), 0)
		SendMessageGlobal(string.format("========================"), 0)
		
		pls = {}
	
		for key, value in pairs(Participantes) do
			if type(key) ~= "number"
			then
				if Participantes[key].Index ~= -1
				then
					if UserGetConnected(Participantes[key].Index) == 3
					then
						InsertKey(pls, key)
						pls[key] = Participantes[key].Index
					end
				end
			end
		end
			
		local total = CountTable(pls)
			
		Name1 = pls[1]
		Name2 = pls[2]
		
		local TargetIndex1 = GetIndex(Name1)
		local TargetIndex2 = GetIndex(Name2)
			
		Fight1 = TargetIndex1
		Fight2 = TargetIndex2
			
		SendMessage(string.format("[Sistema] Sua vez de lutar!"), index, 1)

		if DarkArena == 1
		then
			Teleport(TargetIndex1, 50, 216, 195)
			Teleport(TargetIndex2, 50, 217, 195)
		else
			Teleport(TargetIndex1, 6, 216, 195)
			Teleport(TargetIndex2, 6, 217, 195)
		end

		SendMessageGlobal(string.format("[Sistema]"), 0)
		SendMessageGlobal(string.format("<<~ %s [vs] %s ~>>", Name1, Name2), 0)
			
		DataBase.SetValue("Character", "eventoaguardehit", 1, "Name", UserGetName(Fight1)) -- add participando evento aguarde hit
		DataBase.SetValue("Character", "eventoaguardehit", 1, "Name", UserGetName(Fight2)) -- add participando evento aguarde hit

		timer_contar = Timer.TimeOut(5, MataMata.Contagem)
		timer_finish2 = Timer.TimeOut(3 * 60, MataMata.FinishLuta)
	
		return
	
	
	--- mais de 2 players no mt mt:
	elseif #Participantes > 2
	then
	
		pls = {}
		
		for key, value in pairs(Participantes) do
			if type(key) ~= "number"
			then
				if Participantes[key].Index ~= -1
				then
					if UserGetConnected(Participantes[key].Index) == 3
					then
						if Participantes[key].Step == StepRunning
						then
							InsertKey(pls, key)
							pls[key] = Participantes[key].Index
						end
					end
				end
			end
		end
		
		local total = CountTable(pls)
		
		if total > 1
		then
			Name1 = pls[1]
			Name2 = pls[2]
			
			local TargetIndex1 = GetIndex(Name1)
			
			if DarkArena == 1
			then
				Teleport(TargetIndex1, KILL_MAP2, KILL_COORD_DUEL_X_1, KILL_COORD_DUEL_Y_1)
			else
				Teleport(TargetIndex1, KILL_MAP, KILL_COORD_DUEL_X_1, KILL_COORD_DUEL_Y_1)
			end
			
			Fight1 = TargetIndex1
			SendMessage(string.format("[Sistema] Sua vez de lutar!"), TargetIndex1, 1)
			
			local TargetIndex2 = GetIndex(Name2)
			
			if DarkArena == 1
			then
				Teleport(TargetIndex2, KILL_MAP2, KILL_COORD_DUEL_X_2, KILL_COORD_DUEL_Y_2)
			else
				Teleport(TargetIndex2, KILL_MAP, KILL_COORD_DUEL_X_2, KILL_COORD_DUEL_Y_2)
			end
			
			Fight2 = TargetIndex2
			SendMessage(string.format("[Sistema] Sua vez de lutar!"), TargetIndex2, 1)
			
			SendMessageGlobal(string.format("[Sistema]"), 0)
			SendMessageGlobal(string.format("<<~ %s [vs] %s ~>>", Name1, Name2), 0)
			
			DataBase.SetValue("Character", "eventoaguardehit", 1, "Name", UserGetName(Fight1)) -- add participando evento aguarde hit
			DataBase.SetValue("Character", "eventoaguardehit", 1, "Name", UserGetName(Fight2)) -- add participando evento aguarde hit

			timer_contar = Timer.TimeOut(5, MataMata.Contagem)
			timer_finish2 = Timer.TimeOut(3 * 60, MataMata.FinishLuta)
			
			
		elseif total == 1
		then
			Name = pls[1]
			
			local TargetIndex = GetIndex(Name)
			
			MataMata.MovePlayerWins(TargetIndex, Name)
			
			SendMessageGlobal(string.format("[Mata-Mata] %s passa para a próxima fase por falta de adversário!", Name), 0)
			timer_fase1 = MataMata.CommandStepAuto()
			
			
		else
		
			timer_fase1 = MataMata.CommandStepAuto() -- não há mais jogadores, passar de fase...
			
		end
		
	
	end
	
	
end



function MataMata.Morte(aIndex, TargetIndex)

	if started == false
	then
		return
	end
	
	if Participantes[UserGetName(aIndex)].Index == Fight1 or Participantes[UserGetName(TargetIndex)].Index == Fight1 or Participantes[UserGetName(aIndex)].Index == Fight2 or Participantes[UserGetName(TargetIndex)].Index == Fight2
	then
		SendMessage(string.format("[Mata-Mata] Você matou %s", UserGetName(TargetIndex)), aIndex, 1)
		SendMessage(string.format("[Mata-Mata] %s matou você!", UserGetName(aIndex)), TargetIndex, 1)


		-- quem matou ainda ta on
		if UserGetConnected(aIndex) == 3
		then
		
			if #Participantes == 3
			then
				terceiro = UserGetName(TargetIndex)
			end
			
			if #Participantes == 2
			then
				segundo = UserGetName(TargetIndex)
			end
			
			local Nick = UserGetName(aIndex)
			MataMata.CommandWinsAuto(Nick)
			
			--Teleport(TargetIndex, 0, 125, 125)
			local nomeRemover = UserGetName(TargetIndex)
			MataMata.RemoverPlayer(nomeRemover)
			
			
		-- matou e tomou dc
		else
		
			if #Participantes == 3
			then
				terceiro = UserGetName(aIndex)
			end
			
			if #Participantes == 2
			then
				segundo = UserGetName(aIndex)
			end
			
			local Nick = UserGetName(TargetIndex)
			MataMata.CommandWinsAuto(Nick)
			
			--Teleport(TargetIndex, 0, 125, 125)
			local nomeRemover = UserGetName(aIndex)
			MataMata.RemoverPlayer(nomeRemover)
			
		end
		
		--MataMata.CheckVivos()
		
	end
	

end




function MataMata.FinishLuta()

	if started == false
	then
		return
	end
	
	if timer_finish2 ~= nil
	then
		Timer.Cancel(timer_finish2)
		timer_finish2 = nil
	end

	if Fight1 ~= nil and Fight2 ~= nil
	then
		if UserGetX(Fight1) == 216 and UserGetY(Fight1) == 195 or UserGetX(Fight2) == 217 and UserGetY(Fight2) == 195
		then
			sortearWins = math.random(1, 2)
			
			if sortearWins == 1
			then
				if #Participantes == 3
				then
					terceiro = UserGetName(Fight2)
				end
					
				if #Participantes == 2
				then
					segundo = UserGetName(Fight2)
				end
			
				local Nick = UserGetName(Fight1)
				MataMata.CommandWinsAuto(Nick)
				Participantes[name].Index = -1
				RemoveKey(Participantes, i)
				MataMata.RemoverPlayer(UserGetName(Fight2))
				
			else
			
				if #Participantes == 3
				then
					terceiro = UserGetName(Fight1)
				end
					
				if #Participantes == 2
				then
					segundo = UserGetName(Fight1)
				end
				
				local Nick = UserGetName(Fight2)
				MataMata.CommandWinsAuto(Nick)
				Participantes[name].Index = -1
				RemoveKey(Participantes, i)
				MataMata.RemoverPlayer(UserGetName(Fight1))
			end
	
		
			Fight1 = nil
			Fight2 = nil
			
		end
		
	end
	
	
end


function MataMata.CheckVivos()

	if started == false
	then
		return
	end

	if #Participantes == 1
	then
		
		MataMata.FinishEvent()
	
	end
		
end



function MataMata.FinishEvent()

	SendMessageGlobal(string.format("[Sistema] Mata-Mata finalizado!"), 0)
	
	if #Participantes >= 2 or #Participantes < 1
	then
	
		SendMessageGlobal(string.format("(Nenhum vencedor)"), 0)
		
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name].Index
			local NickRemover = UserGetName(index)
				
			if UserGetConnected(index) ~= 3
			then
				MataMata.RemoverPlayer(name)
			end
				
			Teleport(index, 0, 125, 125)
				
		end
		
		
	elseif #Participantes == 1
	then
	
		for i, name in ipairs(Participantes) do 
			local index = Participantes[name].Index
			
			--SendMessageGlobal(string.format("Vencedor: %s", UserGetName(index)), 0)
			
			
			
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTOGRANDE_1LUGAR, "memb___id", UserGetAccountID(index))
			DataBase.SetAddValue("Character", COLUNA_MATAMATA, PONTOS_1LUGAR, "Name", UserGetName(index))
			Teleport(index, 0, 125, 125)
			DataBase.SetValue("Character", "block_limparpk", 0, "Name", UserGetName(index)) -- remover block limpar pk
			
			-- pontos eventos total
			DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(index))
			DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(index))
			DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(index))
				
			
		
		
			
			-- prêmio 2º lugar
			local indexSegundo = GetIndex(segundo)
			
			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTOGRANDE_2LUGAR, "memb___id", UserGetAccountID(indexSegundo))
			DataBase.SetAddValue("Character", COLUNA_MATAMATA, PONTOS_2LUGAR, "Name", segundo)
			DataBase.SetValue("Character", "block_limparpk", 0, "Name", segundo) -- remover block limpar pk
			
			-- pontos eventos total
			DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(indexSegundo))
			DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(indexSegundo))
			DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(indexSegundo))
				
			
			
			
			-- prêmio 3º lugar
			local indexTerceiro = GetIndex(terceiro)

			DataBase.SetAddValue("MEMB_INFO", COLUNA_PREMIOEVENTOS, PREMIO_EVENTOGRANDE_3LUGAR, "memb___id", UserGetAccountID(indexTerceiro))
			DataBase.SetAddValue("Character", COLUNA_MATAMATA, PONTOS_3LUGAR, "Name", terceiro)
			DataBase.SetValue("Character", "block_limparpk", 0, "Name", terceiro) -- remover block limpar pk
			
			-- pontos eventos total
			DataBase.SetAddValue("Character", "eventos_total", 1, "Name", UserGetName(indexTerceiro))
			DataBase.SetAddValue("Character", "eventos_diario", 1, "Name", UserGetName(indexTerceiro))
			DataBase.SetAddValue("Character", "eventos_semanal", 1, "Name", UserGetName(indexTerceiro))
				
			
			
			
			-- anunciar vencedores
			SendMessageGlobal(string.format("1º Lugar: %s (%d %s)", UserGetName(index), PREMIO_EVENTOGRANDE_1LUGAR, NOME_MOEDA_EVENTO), 0)
			SendMessageGlobal(string.format("2º Lugar: %s (%d %s)", segundo, PREMIO_EVENTOGRANDE_2LUGAR, NOME_MOEDA_EVENTO), 0)
			SendMessageGlobal(string.format("3º Lugar: %s (%d %s)", terceiro, PREMIO_EVENTOGRANDE_3LUGAR, NOME_MOEDA_EVENTO), 0)
			
		end
		
	end
	
	started = false

	if timer_finish ~= nil
	then
		Timer.Cancel(timer_finish)
		timer_finish = nil
	end
	
	if timer_finish2 ~= nil
	then
		Timer.Cancel(timer_finish2)
		timer_finish2 = nil
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
	
	if timer_iniciar ~= nil
	then
		Timer.Cancel(timer_iniciar)
		timer_iniciar = nil
	end
	
	if timer_fase1 ~= nil
	then
		Timer.Cancel(timer_fase1)
		timer_fase1 = nil
	end
	
	if timer_andar ~= nil
	then
		Timer.Cancel(timer_andar)
		timer_andar = nil
	end
	
	if timer_chamar ~= nil
	then
		Timer.Cancel(timer_chamar)
		timer_chamar = nil
	end
	
	if timer_check ~= nil
	then
		Timer.Cancel(timer_check)
		timer_check = nil
	end
	
	if timer_block ~= nil
	then
		Timer.Cancel(timer_block)
		timer_block = nil
	end
	
	if timer_block2 ~= nil
	then
		Timer.Cancel(timer_block2)
		timer_block2 = nil
	end
	
	Timer.Cancel(idtimercheck)
	Timer.Cancel(idtimerParticipante)
	Timer.Cancel(timerBlock)
	Timer.Cancel(timerBlock2)
	idtimercheck = -1
	idtimerParticipante = -1
	started = false
	Players = {}
	Participantes = {}
	StepRunning = 0
	AllBonus = 0
	Privado = 0
	segundo = ''
	terceiro = ''
	Fase = 0
	gmAbriu = ''
	lutafinal = false
	
	Timer.TimeOut(4, MataMata.StatusOFFevent)
	
end




function MataMata.CommandOpenBlock()

	for i = 9000, 9999 do
		if UserGetAuthority(i) == 1
		then
			if MataMata.InArea(UserGetMapNumber(i), UserGetX(i), UserGetY(i)) == 1
			then
				InsertKey(PlayersBlock, UserGetName(aIndex))
			
				PlayersBlock[UserGetName(aIndex)] = {Index = i, Time = BLOCK_AREA_TIME, Block = true}
				
			end
		end
	end
	
	checkusers = true
	timerBlock = Timer.Interval(1, MataMata.RunningBlock)
end

function MataMata.CommandClose()
	
	PlayersBlock = {}
	checkusers = false
	
	if timerBlock ~= -1
	then
		Timer.Cancel(timerBlock)
		timerBlock = -1
	end
end

function MataMata.RunningBlock()
	for i, key in ipairs(PlayersBlock) do
		local playertime = PlayersBlock[key].Time
		
		if UserGetConnected(PlayersBlock[key].Index) ~= 3
		then
			RemoveKey(PlayersBlock, i)
		end
		
		if UserGetAuthority(PlayersBlock[key].Index) ~= 1
		then
			RemoveKey(PlayersBlock, i)
		end
		
		if playertime > 0
		then
			playertime = playertime - 1
			
			PlayersBlock[key].Time = playertime
		
			SendMessage(string.format("[Sistema] Você tem %d segundos para sair da área bloqueada!", playertime), PlayersBlock[key].Index, 1)
		else
			SendMessageGlobal(string.format("[Mata-Mata] %s movido por entrar na área bloqueada!", UserGetName(PlayersBlock[key].Index)), 1)
			Teleport(PlayersBlock[key].Index, 0, 125, 125)
			RemoveKey(PlayersBlock, i)
			Participantes[name].Index = -1
			RemoveKey(Participantes, i)
			MataMata.RemoverPlayer(nomeRemover)
		end
	end
end

function MataMata.PlayerMove(aIndex, map, x, y, sx, sy)
	if checkusers == false
	then
		return
	end
	
	if map ~= 6
	then
		return
	end
	
	if MataMata.InArea(map, x, y) == 1
	then
		if PlayersBlock[UserGetName(aIndex)] == nil
		then
			InsertKey(PlayersBlock, UserGetName(aIndex))
			
			PlayersBlock[UserGetName(aIndex)] = {Index = aIndex, Time = BLOCK_AREA_TIME, Block = true}
			
			SendMessage(string.format("[Sistema] Saia da área bloqueada ou será movido!"), aIndex, 1)
		else
			if PlayersBlock[UserGetName(aIndex)].Block == false and PlayersBlock[UserGetName(aIndex)].Index ~= aIndex
			then
				InsertKey(PlayersBlock, UserGetName(aIndex))
				
				PlayersBlock[UserGetName(aIndex)].Index = aIndex
				
				PlayersBlock[UserGetName(aIndex)].Time = BLOCK_AREA_TIME
				
				PlayersBlock[UserGetName(aIndex)].Block = true

				SendMessage(string.format("[Sistema] Saia da área bloqueada ou será movido!"), aIndex, 1)
			end
		end
	else
		if PlayersBlock[UserGetName(aIndex)] ~= nil
		then
			if PlayersBlock[UserGetName(aIndex)].Index == aIndex
			then
				SendMessage(string.format("[Sistema] Não volte para área bloqueada ou será movido!"), aIndex, 1)
				MataMata.RemoveUserBlock(UserGetName(aIndex))
			end
		end
	end
end

function MataMata.InArea(map, x, y)
	if map == 6
	then
		if x >= BLOCK_AREA_CHECK_COORD_X_1 and y >= BLOCK_AREA_CHECK_COORD_Y_1 and x <= BLOCK_AREA_CHECK_COORD_X_2 and y <= BLOCK_AREA_CHECK_COORD_Y_2
		then
			if x >= BLOCK_AREA_CHECK_FREE_COORD_X_1 and y >= BLOCK_AREA_CHECK_FREE_COORD_Y_1 and x <= BLOCK_AREA_CHECK_FREE_COORD_X_2 and y <= BLOCK_AREA_CHECK_FREE_COORD_Y_2
			then
				return 0
			end
			
			return 1
		end
	end

	return 0
end

function MataMata.RemoveUserBlock(Name)
	for i, key in ipairs(PlayersBlock) do
		if key == Name
		then
			PlayersBlock[Name].Index = 0
			PlayersBlock[Name].Block = false
			RemoveKey(PlayersBlock, i)
			break
		end
	end
end



function MataMata.CommandOpenBlock2()

	for i = 9000, 9999 do
		if UserGetAuthority(i) == 1
		then
			if MataMata.InArea2(UserGetMapNumber(i), UserGetX(i), UserGetY(i)) == 1
			then
				InsertKey(PlayersBlock2, UserGetName(aIndex))
			
				PlayersBlock2[UserGetName(aIndex)] = {Index = i, Time = BLOCK_AREA_TIME, Block = true}
				
			end
		end
	end
	
	checkusers2 = true
	timerBlock2 = Timer.Interval(1, MataMata.RunningBlock2)
end

function MataMata.CommandClose2()
	
	PlayersBlock2 = {}
	checkusers2 = false
	
	if timerBlock2 ~= -1
	then
		Timer.Cancel(timerBlock2)
		timerBlock2 = -1
	end
end

function MataMata.RunningBlock2()
	for i, key in ipairs(PlayersBlock2) do
		local playertime2 = PlayersBlock2[key].Time
		
		if UserGetConnected(PlayersBlock2[key].Index) ~= 3
		then
			RemoveKey(PlayersBlock2, i)
		end
		
		if UserGetAuthority(PlayersBlock2[key].Index) ~= 1
		then
			RemoveKey(PlayersBlock2, i)
		end
		
		if playertime2 > 0
		then
			playertime2 = playertime2 - 1
			
			PlayersBlock2[key].Time = playertime2
		
			SendMessage(string.format("[Sistema] Você tem %d segundos para sair da área bloqueada!", playertime2), PlayersBlock2[key].Index, 1)
		else
			SendMessageGlobal(string.format("[Mata-Mata] %s movido por entrar na área bloqueada!", UserGetName(PlayersBlock2[key].Index)), 1)
			Teleport(PlayersBlock2[key].Index, 0, 125, 125)
			RemoveKey(PlayersBlock2, i)
			Participantes[name].Index = -1
			RemoveKey(Participantes, i)
			MataMata.RemoverPlayer(nomeRemover)
		end
	end
end

function MataMata.PlayerMove2(aIndex, map, x, y, sx, sy)
	if checkusers2 == false
	then
		return
	end
	
	if map ~= 50
	then
		return
	end
	
	if MataMata.InArea2(map, x, y) == 1
	then
		if PlayersBlock2[UserGetName(aIndex)] == nil
		then
			InsertKey(PlayersBlock2, UserGetName(aIndex))
			
			PlayersBlock2[UserGetName(aIndex)] = {Index = aIndex, Time = BLOCK_AREA_TIME, Block = true}
			
			SendMessage(string.format("[Sistema] Saia da área bloqueada ou será movido!"), aIndex, 1)
		else
			if PlayersBlock2[UserGetName(aIndex)].Block == false and PlayersBlock2[UserGetName(aIndex)].Index ~= aIndex
			then
				InsertKey(PlayersBlock2, UserGetName(aIndex))
				
				PlayersBlock2[UserGetName(aIndex)].Index = aIndex
				
				PlayersBlock2[UserGetName(aIndex)].Time = BLOCK_AREA_TIME
				
				PlayersBlock2[UserGetName(aIndex)].Block = true

				SendMessage(string.format("[Sistema] Saia da área bloqueada ou será movido!"), aIndex, 1)
			end
		end
	else
		if PlayersBlock2[UserGetName(aIndex)] ~= nil
		then
			if PlayersBlock2[UserGetName(aIndex)].Index == aIndex
			then
				SendMessage(string.format("[Sistema] Não volte para área bloqueada ou será movido!"), aIndex, 1)
				MataMata.RemoveUserBlock2(UserGetName(aIndex))
			end
		end
	end
end

function MataMata.InArea2(map, x, y)
	if map == 50
	then
		if x >= BLOCK_AREA_CHECK_COORD_X_1 and y >= BLOCK_AREA_CHECK_COORD_Y_1 and x <= BLOCK_AREA_CHECK_COORD_X_2 and y <= BLOCK_AREA_CHECK_COORD_Y_2
		then
			if x >= BLOCK_AREA_CHECK_FREE_COORD_X_1 and y >= BLOCK_AREA_CHECK_FREE_COORD_Y_1 and x <= BLOCK_AREA_CHECK_FREE_COORD_X_2 and y <= BLOCK_AREA_CHECK_FREE_COORD_Y_2
			then
				return 0
			end
			
			return 1
		end
	end

	return 0
end

function MataMata.RemoveUserBlock2(Name)
	for i, key in ipairs(PlayersBlock2) do
		if key == Name
		then
			PlayersBlock2[Name].Index = 0
			PlayersBlock2[Name].Block = false
			RemoveKey(PlayersBlock2, i)
			break
		end
	end
end



function MataMata.StatusOFFevent()

	DataBase.SetValue3("EVENTO_AUTO", "status", 0) -- status evento OFF
	
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
	
	
	
	elseif evento == 188
	then
		DataBase.SetValue4("EVENTO_AUTO", "evento", "Ataque Zumbi")
		
	end

end


Commands.Register("/abrirmata-mata", MataMata.CommandOpenAutoGM)
Commands.Register("/abrirmata-mata_bonus123213", MataMata.CommandOpen_Bonus)
Commands.Register("/abrirmata-mata_privado123123", MataMata.CommandOpen_Privado)
Commands.Register("/abrirmata-mata_classico123123", MataMata.CommandOpen_Classico)
Commands.Register(KILL_COMMAND_GO, MataMata.CommandGo)
Commands.Register("/vs", MataMata.CommandVS)
GameServerFunctions.PlayerDie(MataMata.Morte)
GameServerFunctions.PlayerMove(MataMata.PlayerMove)

MataMata.TimerEvento()

return MataMata
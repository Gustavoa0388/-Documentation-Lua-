local CONFIG = require("Scripts\\AllMix\\Config")


BridgeFunctionAttach('OnNpcTalk', 'NewCM_NPC_TALK')

NewCM 		= {}
NewCM.VIP 	= 0


NewCM.NPC = {
	{ MonsterID = 249, Map = 0, CoordX = 142, CoordY = 140, cmID = 0 },
	{ MonsterID = 249, Map = 2, CoordX = 204, CoordY = 030, cmID = 1 },
	{ MonsterID = 249, Map = 4, CoordX = 200, CoordY = 078, cmID = 2 },

	{ MonsterID = 249, Map = 2, CoordX = 222, CoordY = 007, cmID = 3 }, 	--apo
	{ MonsterID = 249, Map = 2, CoordX = 224, CoordY = 007, cmID = 4 }, 	--apo

}

NewCM.Require = {
	--{cmID = 0, ItemIndex = 6174, ItemLevel = 15, ItemName = "Bundle of Bless (Mix 160)", Quantidade = 1},
	--{cmID = 0, ItemIndex = 6174, ItemLevel = 14, ItemName = "Bundle of Bless (Mix 150)", Quantidade = 1},
	
	--MANTICORE CRAFT
	{cmID = 0, ItemIndex = GET_ITEM(14,145), ItemLevel = -1, ItemName = "Fragmento Manticore 1", Quantidade = 1},
	{cmID = 0, ItemIndex = GET_ITEM(12,30), ItemLevel = 15, ItemName = "Bundle of Bless (Mix 160)", Quantidade = 1},
	{cmID = 0, ItemIndex = GET_ITEM(12,31), ItemLevel = 15, ItemName = "Bundle of Soul (Mix 160)", Quantidade = 1},
	{cmID = 0, ItemIndex = GET_ITEM(12,141), ItemLevel = 15, ItemName = "Bundle of Chaos (Mix 160)", Quantidade = 1},

    {cmID = 1, ItemIndex = GET_ITEM(14,146), ItemLevel = -1, ItemName = "Fragmento Manticore 2", Quantidade = 20},
	{cmID = 1, ItemIndex = GET_ITEM(12,30), ItemLevel = 15, ItemName = "Bundle of Bless (Mix 160)", Quantidade = 8},
	{cmID = 1, ItemIndex = GET_ITEM(12,31), ItemLevel = 15, ItemName = "Bundle of Soul (Mix 160)", Quantidade = 8},
	{cmID = 1, ItemIndex = GET_ITEM(12,141), ItemLevel = 15, ItemName = "Bundle of Chaos (Mix 160)", Quantidade = 8},
	
    {cmID = 2, ItemIndex = GET_ITEM(14,147), ItemLevel = -1, ItemName = "Fragmento Manticore 3", Quantidade = 10},
  
	-- APO CRAFT
    {cmID = 3, ItemIndex = GET_ITEM(14,149), ItemLevel = -1, ItemName = "Apocalipse Key", Quantidade = 50},

    {cmID = 4, ItemIndex = GET_ITEM(14,058), ItemLevel = -1, ItemName = "Crown of the apocalypse", Quantidade = 1},
    {cmID = 4, ItemIndex = GET_ITEM(12,136), ItemLevel = 15, ItemName = "Bundle of Life (Mix 160)", Quantidade = 30},
    {cmID = 4, ItemIndex = GET_ITEM(12,137), ItemLevel = 15, ItemName = "Bundle of Creation (Mix 160)", Quantidade = 15},
	{cmID = 4, ItemIndex = GET_ITEM(12,141), ItemLevel = 15, ItemName = "Bundle of Chaos (Mix 160)", Quantidade = 4},
	



	--{cmID = 0, ItemIndex = 6281, ItemLevel = 15, ItemName = "Bundle of Creation (Mix 160)", Quantidade = 1},
	--{cmID = 0, ItemIndex = 6159, ItemLevel = 0, ItemName = "Jewel of Chaos", Quantidade = 1},
}

NewCM.Mix = {
	{cmID = 0, Rate = 100, RateVIP1 = 100, RateVIP2 = 100, RateVIP3 = 100},
	{cmID = 1, Rate = 100, RateVIP1 = 100, RateVIP2 = 100, RateVIP3 = 100},
	{cmID = 2, Rate = 100, RateVIP1 = 100, RateVIP2 = 100, RateVIP3 = 100},

	{cmID = 3, Rate = 100, RateVIP1 = 100, RateVIP2 = 100, RateVIP3 = 100},
	{cmID = 4, Rate = 100, RateVIP1 = 100, RateVIP2 = 100, RateVIP3 = 100},
}

NewCM.ItemList = {
	{cmID = 0, SpecialBag = 520},
	{cmID = 1, SpecialBag = 521},
	{cmID = 2, SpecialBag = 522},

	{cmID = 3, SpecialBag = 523},
	{cmID = 4, SpecialBag = 524},
}
	


function NewCM_NPC_TALK(aIndex, player)
	
	NewCM.Clicked(aIndex, player)
	
	return 0

end


function NewCM.Clicked(aIndex, player)
	
	-- Verifica qual NPC foi clicado com base nas coordenadas e ID
	for i = 1, #NewCM.NPC do
		local entry = NewCM.NPC[i]
		
		if GetObjectClass(aIndex) == entry.MonsterID and entry.Map == GetObjectMap(aIndex) and entry.CoordX == GetObjectMapX(aIndex) and entry.CoordY == GetObjectMapY(aIndex) then
			-- Verificar se o jogador possui todos os itens necessários para esse cmID
		
			local faltaItem = false
			c = 1
			for j = 1, #NewCM.Require do
				local req = NewCM.Require[j]
				if req.cmID == entry.cmID then
					if InventoryGetItemCount(player, req.ItemIndex, req.ItemLevel) < req.Quantidade then
						
						NoticeSend(player, 1, string.format("[%s] Você precisa de %d %s.", c, req.Quantidade, req.ItemName))
						ChatTargetSend(aIndex, player, string.format("Faltam itens para a combinação."))
						c = c + 1
						faltaItem = true
					end
				end
			end
		
			if faltaItem then
				c = 1
				return
			end

			-- Remover os itens necessários
			for j = 1, #NewCM.Require do
				local req = NewCM.Require[j]
				if req.cmID == entry.cmID then
					InventoryDelItemCount(player,req.ItemIndex,req.ItemLevel,0, 0, req.Quantidade)
					LogColor(2, string.format("[%s] Item %d x%d removido.", GetObjectAccount(player), req.ItemIndex, req.Quantidade))
				end
			end

			-- Verificar chance de sucesso do mix
			for j = 1, #NewCM.Mix do
					local mix = NewCM.Mix[j]
					if mix.cmID == entry.cmID then
						local chance = math.random(0, 99)
						
						if GetObjectAccountLevel(player) == 0 then
							NewCM.VIP = mix.Rate
						elseif GetObjectAccountLevel(player) == 1 then
							NewCM.VIP = mix.RateVIP1
						elseif GetObjectAccountLevel(player) == 2 then
							NewCM.VIP = mix.RateVIP2
						elseif GetObjectAccountLevel(player) == 3 then
							NewCM.VIP = mix.RateVIP3
						end
						
							
						if chance < NewCM.VIP then
							--LogColor(2, string.format("[%s] Mix bem-sucedido! Taxa: %s%% (Rolado: %s)", GetObjectAccount(player), NewCM.VIP, chance))
							ChatTargetSend(aIndex,player,string.format("Mix bem-sucedido!"))
							LogColor(2, string.format('[%s] Mix bem-sucedido!', GetObjectAccount(player)))
--
							-- Criar recompensas
							for k = 1, #NewCM.ItemList do
								local item = NewCM.ItemList[k]
								if item.cmID == entry.cmID then
									--ItemGiveEx(player, item.ItemIndex, item.Quantidade)
									ItemGive(player,item.SpecialBag)
							    end
							end
						else
							--LogColor(2, string.format("[%s] Mix falhou! Taxa: %s%% (Rolado: %s)", GetObjectAccount(player), mix.Rate, chance))
							ChatTargetSend(aIndex,player,string.format("Mix falhou!"))
							LogColor(2, string.format('[%s] Mix Falhou!', GetObjectAccount(player)))
						end
						break
					end

			end

			return 1 -- já tratou o NPC, não precisa continuar o loop
		end
	end
	--
	return 0
end

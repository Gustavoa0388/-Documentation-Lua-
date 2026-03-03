return {

    Enable = 1, -- 0 Desativado, 1 Ativado
    Cash = 100, -- Quanto Saldo o NPC vai requerir
    CashBackMin = 50, -- Mínimo de retorno de Saldo
    CashBackMax = 200, -- Máximo de retorno de Saldo
    MaxNumberRandom = 6, -- Coloque 1 Número a mais da tabela de itens abaixo para o cashback, caso nao queira sorteio de cash back, coloque a mesma quantia da tabela
    Tabela = 'CashShopData', -- Tabela da onde vai puxar o Saldo
    ColunaSaldo = 'WCoinC', -- Coluna do Saldo
    ColunaConta = 'AccountID', -- Coluna para a verificação da conta
    Type = 0, -- 0 = Direto no NPC Rescue Item (Ogocx base/Louis), 1 = Direto no inventário

    Item = {

        { cash = 0, Name = "Box of Kundun +5", ItemIndex = GET_ITEM(14, 11), Level = 12, },  
        { cash = 0, Name = "Galo Claudio", ItemIndex = GET_ITEM(13, 253), Level = 0, },  
        { cash = 0, Name = "Box 380 (Sets)", ItemIndex = GET_ITEM(12, 32), Level = 0, },  
        { cash = 0, Name = "Box 380 (Armas)", ItemIndex = GET_ITEM(12, 33), Level = 0, },  
        { cash = 0, Name = "Box 380 (All)", ItemIndex = GET_ITEM(12, 34), Level = 0, }, 
        { cash = 1, Name = "FCoin x1", ItemIndex = 50, Level = 200, },  
        { cash = 0, Name = "Box of Kundun +5", ItemIndex = GET_ITEM(14, 11), Level = 12, },  
        { cash = 0, Name = "Galo Claudio", ItemIndex = GET_ITEM(13, 253), Level = 0, },  
        { cash = 0, Name = "Box 380 (Sets)", ItemIndex = GET_ITEM(12, 32), Level = 0, },  
        { cash = 0, Name = "Box 380 (Armas)", ItemIndex = GET_ITEM(12, 33), Level = 0, },  
        { cash = 0, Name = "Box 380 (All)", ItemIndex = GET_ITEM(12, 34), Level = 0, }, 
        { cash = 1, Name = "FCoin x1", ItemIndex = 50, Level = 200, },  
        { cash = 0, Name = "Box of Kundun +5", ItemIndex = GET_ITEM(14, 11), Level = 12, },  
        { cash = 0, Name = "Galo Claudio", ItemIndex = GET_ITEM(13, 253), Level = 0, },  
        { cash = 0, Name = "Box 380 (Sets)", ItemIndex = GET_ITEM(12, 32), Level = 0, },  
        { cash = 0, Name = "Box 380 (Armas)", ItemIndex = GET_ITEM(12, 33), Level = 0, },  
        { cash = 0, Name = "Box 380 (All)", ItemIndex = GET_ITEM(12, 34), Level = 0, }, 
        { cash = 1, Name = "FCoin x1", ItemIndex = 50, Level = 200, },  
        { cash = 0, Name = "Box of Kundun +5", ItemIndex = GET_ITEM(14, 11), Level = 12, },  
        { cash = 0, Name = "Galo Claudio", ItemIndex = GET_ITEM(13, 253), Level = 0, },  
        { cash = 0, Name = "Box 380 (Sets)", ItemIndex = GET_ITEM(12, 32), Level = 0, },  
        { cash = 0, Name = "Box 380 (Armas)", ItemIndex = GET_ITEM(12, 33), Level = 0, },  
        { cash = 0, Name = "Box 380 (All)", ItemIndex = GET_ITEM(12, 34), Level = 0, }, 
        { cash = 1, Name = "FCoin x1", ItemIndex = 50, Level = 200, },  

        
        { cash = 0, Name = "Box of Kundun +5", ItemIndex = GET_ITEM(14, 11), Level = 12, },  
        { cash = 0, Name = "Galo Claudio", ItemIndex = GET_ITEM(13, 253), Level = 0, },  
        { cash = 0, Name = "Box 380 (Sets)", ItemIndex = GET_ITEM(12, 32), Level = 0, },  
        { cash = 0, Name = "Box 380 (Armas)", ItemIndex = GET_ITEM(12, 33), Level = 0, },  
        { cash = 0, Name = "Box 380 (All)", ItemIndex = GET_ITEM(12, 34), Level = 0, }, 
        
        { cash = 1, Name = "FCoin x1", ItemIndex = 50, Level = 200, },  
        { cash = 1, Name = "FCoin x2", ItemIndex = 100, Level = 400, },  
        { cash = 1, Name = "FCoin x3", ItemIndex = 200, Level = 800, },  


        { cash = 0, Name = "DarkAngel Wizard Helm", ItemIndex = GET_ITEM(7, 108), Level = 0 },  
        { cash = 0, Name = "DarkAngel Knight Helm", ItemIndex = GET_ITEM(7, 109), Level = 0 },  
        { cash = 0, Name = "DarkAngel Elf Helm"   , ItemIndex = GET_ITEM(7, 110), Level = 0 },  
        { cash = 0, Name = "DarkAngel Lord Helm"  , ItemIndex = GET_ITEM(7, 112), Level = 0 },  
        { cash = 0, Name = "DarkAngel Rage Helm"  , ItemIndex = GET_ITEM(7, 113), Level = 0 },  
        { cash = 0, Name = "DarkAngel Summon Helm", ItemIndex = GET_ITEM(7, 114), Level = 0 },  
		
		{ cash = 0, Name = "DarkAngel Wizard Armor", ItemIndex = GET_ITEM(8, 108), Level = 0 },  
        { cash = 0, Name = "DarkAngel Knight Armor", ItemIndex = GET_ITEM(8, 109), Level = 0 },  
        { cash = 0, Name = "DarkAngel Elf Armor"   , ItemIndex = GET_ITEM(8, 110), Level = 0 },  
        { cash = 0, Name = "DarkAngel Magic Armor" , ItemIndex = GET_ITEM(8, 111), Level = 0 },  
        { cash = 0, Name = "DarkAngel Lord Armor"  , ItemIndex = GET_ITEM(8, 112), Level = 0 },  
        { cash = 0, Name = "DarkAngel Rage Armor"  , ItemIndex = GET_ITEM(8, 113), Level = 0 },  
        { cash = 0, Name = "DarkAngel Summon Armor", ItemIndex = GET_ITEM(8, 114), Level = 0 },  
		
		{ cash = 0, Name = "DarkAngel Wizard Pants", ItemIndex = GET_ITEM(9, 108), Level = 0 },  
        { cash = 0, Name = "DarkAngel Knight Pants", ItemIndex = GET_ITEM(9, 109), Level = 0 },  
        { cash = 0, Name = "DarkAngel Elf Pants"   , ItemIndex = GET_ITEM(9, 110), Level = 0 },  
        { cash = 0, Name = "DarkAngel Magic Pants" , ItemIndex = GET_ITEM(9, 111), Level = 0 },  
        { cash = 0, Name = "DarkAngel Lord Pants"  , ItemIndex = GET_ITEM(9, 112), Level = 0 },  
        { cash = 0, Name = "DarkAngel Rage Pants"  , ItemIndex = GET_ITEM(9, 113), Level = 0 },  
        { cash = 0, Name = "DarkAngel Summon Pants", ItemIndex = GET_ITEM(9, 114), Level = 0 },  
		
		{ cash = 0, Name = "DarkAngel Wizard Gloves", ItemIndex = GET_ITEM(10, 108), Level = 0 },  
        { cash = 0, Name = "DarkAngel Knight Gloves", ItemIndex = GET_ITEM(10, 109), Level = 0 },  
        { cash = 0, Name = "DarkAngel Elf Gloves"   , ItemIndex = GET_ITEM(10, 110), Level = 0 },  
        { cash = 0, Name = "DarkAngel Magic Gloves" , ItemIndex = GET_ITEM(10, 111), Level = 0 },  
        { cash = 0, Name = "DarkAngel Lord Gloves"  , ItemIndex = GET_ITEM(10, 112), Level = 0 },  
        { cash = 0, Name = "DarkAngel Summon Gloves", ItemIndex = GET_ITEM(10, 114), Level = 0 },  
		
		{ cash = 0, Name = "DarkAngel Wizard Boots", ItemIndex = GET_ITEM(11, 108), Level = 0 },  
        { cash = 0, Name = "DarkAngel Knight Boots", ItemIndex = GET_ITEM(11, 109), Level = 0 },  
        { cash = 0, Name = "DarkAngel Elf Boots"   , ItemIndex = GET_ITEM(11, 110), Level = 0 },  
        { cash = 0, Name = "DarkAngel Magic Boots" , ItemIndex = GET_ITEM(11, 111), Level = 0 },  
        { cash = 0, Name = "DarkAngel Lord Boots"  , ItemIndex = GET_ITEM(11, 112), Level = 0 },  
        { cash = 0, Name = "DarkAngel Rage Boots"  , ItemIndex = GET_ITEM(11, 113), Level = 0 },  
        { cash = 0, Name = "DarkAngel Summon Boots", ItemIndex = GET_ITEM(11, 114), Level = 0 },  
    }
}
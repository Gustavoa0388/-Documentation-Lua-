return {
	Enable = 1,				-- Ativa / Desativa
	Command = "/trocar",	-- Comando
    Tabela = 'CashShopData', -- Tabela da onde vai puxar o Saldo
    ColunaGP = 'GoblinPoint', -- Coluna do Saldo
    ColunaGold = 'WCoinP', -- Coluna do Saldo
    ColunaConta = 'AccountID', -- Coluna para a verificação da conta

    PACKET = 55,
    PACKETNAME = "HUNTTRADE",
}
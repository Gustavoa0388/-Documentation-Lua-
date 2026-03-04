-- ================================================================
--  MarketPlace/Config.lua
--  Emulador: Louis Season 6
--  TODAS as configurações do sistema ficam aqui
-- ================================================================

MP_Config = {

    -- ─── GERAL ───────────────────────────────────────────────────
    Enable               = 1,
    MaxListingsPerPlayer = 5,        -- Máx anúncios por player
    AuctionDuration      = 172800,   -- Duração em segundos (48h)
    CheckExpiredInterval = 60,       -- Checar expirados a cada Ns
    TransactionDelay     = 3,        -- Delay de segurança em segundos

    -- ─── TABELAS SQL ─────────────────────────────────────────────
    TableListings = "MP_Listings",
    TableTrades   = "MP_Trades",
    TableLog      = "MP_Log",

    -- ─── TAXA DE VENDA ───────────────────────────────────────────
    -- A moeda da taxa é SEMPRE a mesma moeda escolhida pelo vendedor
    SellTax = {
        Percent = 5,  -- 5% sobre o valor da venda, na mesma moeda
    },

    -- ─── TAXA DE TROCA ───────────────────────────────────────────
    -- Na troca não há moeda de venda, taxa é em moeda fixa
    TradeTax = {
        Currency = "Zen",
        FlatFee  = 1000000, -- Valor fixo cobrado de CADA lado
    },

    -- ─── LIMITES DE PREÇO POR MOEDA ──────────────────────────────
    PriceLimits = {
        Zen = { Min = 100000,  Max = 2000000000 },
        WC  = { Min = 1,       Max = 100000     },
        WP  = { Min = 1,       Max = 100000     },
        GP  = { Min = 1,       Max = 100000     },
    },

    -- ─── MOEDAS ACEITAS ──────────────────────────────────────────
    AllowedCurrencies = { "Zen", "WC", "WP", "GP" },

    -- ─── NPC ─────────────────────────────────────────────────────
    NPC = {
        MonsterID = 449,
        Map       = 0,
        PosX      = 140,
        PosY      = 125,
    },

    -- ─── CATEGORIAS ──────────────────────────────────────────────
    Categories = {
        [0]  = "Todos",
        [1]  = "Swords",
        [2]  = "Axes",
        [3]  = "Maces",
        [4]  = "Spears",
        [5]  = "Bows",
        [6]  = "Staffs",
        [7]  = "Shields",
        [8]  = "Helms",
        [9]  = "Armors",
        [10] = "Pants",
        [11] = "Gloves",
        [12] = "Boots",
        [13] = "Wings",
        [14] = "Rings",
        [15] = "Misc",
    },

    CategoryByType = {
        [0]  = 1,   [1]  = 2,   [2]  = 3,
        [3]  = 4,   [4]  = 5,   [5]  = 6,
        [6]  = 8,   [7]  = 9,   [8]  = 10,
        [9]  = 11,  [10] = 12,  [11] = 7,
        [12] = 15,  [13] = 13,  [14] = 15,
        [15] = 14,
    },

    -- ─── ITENS POR PÁGINA ────────────────────────────────────────
    ItemsPerPage = 9,

    -- ─── MENSAGENS ───────────────────────────────────────────────
    Msg = {
        Disabled        = "[MarketPlace] Sistema desativado.",
        NoSpace         = "[MarketPlace] Seu inventario esta cheio!",
        NotFound        = "[MarketPlace] Anuncio nao encontrado.",
        NotYours        = "[MarketPlace] Este anuncio nao pertence a voce.",
        OwnItem         = "[MarketPlace] Voce nao pode comprar/trocar seu proprio item.",
        NoMoney         = "[MarketPlace] Moeda insuficiente.",
        MaxListings     = "[MarketPlace] Limite de %d anuncios atingido.",
        InvalidPrice    = "[MarketPlace] Preco invalido para %s: min %d | max %d.",
        InvalidSlot     = "[MarketPlace] Slot invalido ou sem item.",
        EquippedItem    = "[MarketPlace] Nao pode anunciar itens equipados.",
        TxPending       = "[MarketPlace] Processando transacao... aguarde %ds.",
        SellSuccess     = "[MarketPlace] Item anunciado! ID:%d | %d %s | %dh restantes.",
        BuySuccess      = "[MarketPlace] Compra realizada! %d %s debitados.",
        SoldOnline      = "[MarketPlace] Seu item (ID:%d) foi vendido! +%d %s (taxa:%d).",
        SoldOffline     = "[MarketPlace] Voce tem %d %s pendentes de vendas!",
        CancelOk        = "[MarketPlace] Anuncio ID:%d cancelado. Item devolvido.",
        TradeOffered    = "[MarketPlace] Proposta de troca enviada! TradeID:%d",
        TradeReceived   = "[MarketPlace] Nova proposta de troca recebida!",
        TradeAccepted   = "[MarketPlace] Troca aceita! Itens transferidos.",
        TradeDeclined   = "[MarketPlace] Proposta recusada.",
        TradeTaxNoMoney = "[MarketPlace] Voce precisa de %d %s para a taxa de troca.",
        ExpiredReturn   = "[MarketPlace] Item devolvido (anuncio expirado).",
        ExpiredOffline  = "[MarketPlace] Item expirado devolvido ao logar.",
        AlreadyTx       = "[MarketPlace] Este item ja esta em transacao.",
    },
}
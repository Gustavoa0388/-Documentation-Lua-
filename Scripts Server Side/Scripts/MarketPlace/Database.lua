-- ================================================================
--  MarketPlace/Database.lua
--  Criação das tabelas SQL + helpers de moeda
-- ================================================================

MP_DB = {}

function MP_DB.Init()
    local T  = MP_Config.TableListings
    local TT = MP_Config.TableTrades
    local TL = MP_Config.TableLog

    ExecuteQuery(string.format([[
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='%s' AND xtype='U')
        CREATE TABLE %s (
            ID           INT IDENTITY(1,1) PRIMARY KEY,
            SellerName   VARCHAR(10)  NOT NULL,
            Category     INT          NOT NULL DEFAULT 0,
            ItemIndex    INT          NOT NULL,
            ItemLevel    INT          NOT NULL DEFAULT 0,
            ItemDur      INT          NOT NULL DEFAULT 255,
            ItemOp1      INT          NOT NULL DEFAULT 0,
            ItemOp2      INT          NOT NULL DEFAULT 0,
            ItemOp3      INT          NOT NULL DEFAULT 0,
            ItemNewOpt   INT          NOT NULL DEFAULT 0,
            ItemSetOpt   INT          NOT NULL DEFAULT 0,
            ItemJoH      INT          NOT NULL DEFAULT 0,
            ItemOptEx    INT          NOT NULL DEFAULT 0,
            ItemSock1    INT          NOT NULL DEFAULT 255,
            ItemSock2    INT          NOT NULL DEFAULT 255,
            ItemSock3    INT          NOT NULL DEFAULT 255,
            ItemSock4    INT          NOT NULL DEFAULT 255,
            ItemSock5    INT          NOT NULL DEFAULT 255,
            ItemSockB    INT          NOT NULL DEFAULT 255,
            Price        BIGINT       NOT NULL DEFAULT 0,
            Currency     VARCHAR(4)   NOT NULL DEFAULT 'Zen',
            AcceptTrade  INT          NOT NULL DEFAULT 0,
            TradeNote    VARCHAR(100) NOT NULL DEFAULT '',
            ExpireTime   BIGINT       NOT NULL DEFAULT 0,
            Status       INT          NOT NULL DEFAULT 0,
            CreatedAt    DATETIME     NOT NULL DEFAULT GETDATE()
        )
    ]], T, T))

    -- Status MP_Listings:
    -- 0=Ativo | 1=Em transação | 2=Vendido(zen pendente)
    -- 3=Finalizado | 4=Cancelado | 5=Expirado(item pendente)

    ExecuteQuery(string.format([[
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='%s' AND xtype='U')
        CREATE TABLE %s (
            ID             INT IDENTITY(1,1) PRIMARY KEY,
            ListingID      INT          NOT NULL,
            ProposerName   VARCHAR(10)  NOT NULL,
            OffItemIndex   INT          NOT NULL,
            OffItemLevel   INT          NOT NULL DEFAULT 0,
            OffItemDur     INT          NOT NULL DEFAULT 255,
            OffItemOp1     INT          NOT NULL DEFAULT 0,
            OffItemOp2     INT          NOT NULL DEFAULT 0,
            OffItemOp3     INT          NOT NULL DEFAULT 0,
            OffItemNewOpt  INT          NOT NULL DEFAULT 0,
            OffItemSetOpt  INT          NOT NULL DEFAULT 0,
            OffItemJoH     INT          NOT NULL DEFAULT 0,
            OffItemOptEx   INT          NOT NULL DEFAULT 0,
            OffItemSock1   INT          NOT NULL DEFAULT 255,
            OffItemSock2   INT          NOT NULL DEFAULT 255,
            OffItemSock3   INT          NOT NULL DEFAULT 255,
            OffItemSock4   INT          NOT NULL DEFAULT 255,
            OffItemSock5   INT          NOT NULL DEFAULT 255,
            OffItemSockB   INT          NOT NULL DEFAULT 255,
            Status         INT          NOT NULL DEFAULT 0,
            CreatedAt      DATETIME     NOT NULL DEFAULT GETDATE()
        )
    ]], TT, TT))

    -- Status MP_Trades:
    -- 0=Pendente | 1=Aceita | 2=Recusada | 3=Cancelada

    ExecuteQuery(string.format([[
        IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='%s' AND xtype='U')
        CREATE TABLE %s (
            ID          INT IDENTITY(1,1) PRIMARY KEY,
            Action      VARCHAR(30)  NOT NULL,
            PlayerA     VARCHAR(10),
            PlayerB     VARCHAR(10),
            ListingID   INT,
            TradeID     INT,
            ItemIndex   INT,
            ItemLevel   INT,
            Price       BIGINT,
            Currency    VARCHAR(4),
            Extra       VARCHAR(200),
            LogTime     DATETIME     NOT NULL DEFAULT GETDATE()
        )
    ]], TL, TL))

    LogColor(3, "[MarketPlace] Tabelas SQL verificadas/criadas com sucesso.")
end

function MP_DB.Log(action, playerA, playerB, listingID, tradeID, itemIndex, itemLevel, price, currency, extra)
    ExecuteQuery(string.format([[
        INSERT INTO %s
        (Action,PlayerA,PlayerB,ListingID,TradeID,ItemIndex,ItemLevel,Price,Currency,Extra)
        VALUES('%s','%s','%s',%d,%d,%d,%d,%d,'%s','%s')
    ]],
        MP_Config.TableLog,
        action    or "UNKNOWN",
        playerA   or "",
        playerB   or "",
        listingID or 0,
        tradeID   or 0,
        itemIndex or 0,
        itemLevel or 0,
        price     or 0,
        currency  or "Zen",
        extra     or ""
    ))
end

function MP_DB.GetCurrency(aIndex, currency)
    if currency == "Zen" then
        return GetObjectMoney(aIndex)
    elseif currency == "WC" then
        local c1,_,_ = ObjectGetCoin(aIndex); return c1
    elseif currency == "WP" then
        local _,c2,_ = ObjectGetCoin(aIndex); return c2
    elseif currency == "GP" then
        local _,_,c3 = ObjectGetCoin(aIndex); return c3
    end
    return 0
end

function MP_DB.SubCurrency(aIndex, currency, amount)
    if currency == "Zen" then
        SetObjectMoney(aIndex, GetObjectMoney(aIndex) - amount)
        MoneySend(aIndex)
    elseif currency == "WC" then
        ObjectSubCoin(aIndex, amount, 0, 0)
    elseif currency == "WP" then
        ObjectSubCoin(aIndex, 0, amount, 0)
    elseif currency == "GP" then
        ObjectSubCoin(aIndex, 0, 0, amount)
    end
end

function MP_DB.AddCurrency(aIndex, currency, amount)
    if currency == "Zen" then
        SetObjectMoney(aIndex, GetObjectMoney(aIndex) + amount)
        MoneySend(aIndex)
    elseif currency == "WC" then
        ObjectAddCoin(aIndex, amount, 0, 0)
    elseif currency == "WP" then
        ObjectAddCoin(aIndex, 0, amount, 0)
    elseif currency == "GP" then
        ObjectAddCoin(aIndex, 0, 0, amount)
    end
end

function MP_DB.GetCategory(itemIndex)
    local itemType = math.floor(itemIndex / 512)
    return MP_Config.CategoryByType[itemType] or 15
end

function MP_DB.GiveItem(aIndex, d)
    ItemGiveEx(
        aIndex,
        d.ItemIndex, d.ItemLevel, d.ItemDur,
        d.ItemOp1,   d.ItemOp2,   d.ItemOp3,
        d.ItemNewOpt,d.ItemSetOpt,d.ItemJoH,
        d.ItemOptEx,
        d.ItemSock1, d.ItemSock2, d.ItemSock3,
        d.ItemSock4, d.ItemSock5, d.ItemSockB,
        0
    )
end

function MP_DB.ReadItemRow(identification, prefix)
    prefix = prefix or ""
    return {
        ItemIndex  = tonumber(QueryAsyncGetValue(identification, prefix.."ItemIndex"))  or 0,
        ItemLevel  = tonumber(QueryAsyncGetValue(identification, prefix.."ItemLevel"))  or 0,
        ItemDur    = tonumber(QueryAsyncGetValue(identification, prefix.."ItemDur"))    or 255,
        ItemOp1    = tonumber(QueryAsyncGetValue(identification, prefix.."ItemOp1"))    or 0,
        ItemOp2    = tonumber(QueryAsyncGetValue(identification, prefix.."ItemOp2"))    or 0,
        ItemOp3    = tonumber(QueryAsyncGetValue(identification, prefix.."ItemOp3"))    or 0,
        ItemNewOpt = tonumber(QueryAsyncGetValue(identification, prefix.."ItemNewOpt")) or 0,
        ItemSetOpt = tonumber(QueryAsyncGetValue(identification, prefix.."ItemSetOpt")) or 0,
        ItemJoH    = tonumber(QueryAsyncGetValue(identification, prefix.."ItemJoH"))    or 0,
        ItemOptEx  = tonumber(QueryAsyncGetValue(identification, prefix.."ItemOptEx"))  or 0,
        ItemSock1  = tonumber(QueryAsyncGetValue(identification, prefix.."ItemSock1"))  or 255,
        ItemSock2  = tonumber(QueryAsyncGetValue(identification, prefix.."ItemSock2"))  or 255,
        ItemSock3  = tonumber(QueryAsyncGetValue(identification, prefix.."ItemSock3"))  or 255,
        ItemSock4  = tonumber(QueryAsyncGetValue(identification, prefix.."ItemSock4"))  or 255,
        ItemSock5  = tonumber(QueryAsyncGetValue(identification, prefix.."ItemSock5"))  or 255,
        ItemSockB  = tonumber(QueryAsyncGetValue(identification, prefix.."ItemSockB"))  or 255,
    }
end
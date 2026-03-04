MP_Sell = {}

local PendingSell   = {}
local PendingCancel = {}

function MP_Sell.Register(aIndex, slot, price, currency, acceptTrade, tradeNote)
    if MP_Config.Enable ~= 1 then
        CommandSend(aIndex, MP_Config.Msg.Disabled); return
    end

    local currencyValid = false
    for _, c in ipairs(MP_Config.AllowedCurrencies) do
        if c == currency then currencyValid = true; break end
    end
    if not currencyValid then
        CommandSend(aIndex, "[MP] Moeda invalida."); return
    end

    local limits = MP_Config.PriceLimits[currency]
    if price < limits.Min or price > limits.Max then
        CommandSend(aIndex, string.format(
            MP_Config.Msg.InvalidPrice, currency, limits.Min, limits.Max))
        return
    end

    if slot < InventoryGetWearSize() then
        CommandSend(aIndex, MP_Config.Msg.EquippedItem); return
    end

    local itemIndex = InventoryGetItemIndex(aIndex, slot)
    if not itemIndex or itemIndex < 0 then
        CommandSend(aIndex, MP_Config.Msg.InvalidSlot); return
    end

    local itemData = InventoryGetItemTable(aIndex, slot)
    if not itemData then
        CommandSend(aIndex, "[MP] Erro ao ler dados do item."); return
    end

    PendingSell[aIndex] = {
        slot        = slot,
        price       = price,
        currency    = currency,
        acceptTrade = acceptTrade,
        tradeNote   = tradeNote or "",
        itemData    = itemData,
        category    = MP_DB.GetCategory(itemIndex),
        charName    = GetObjectName(aIndex),
    }

    CreateAsyncQuery("MP_SellCount",
        string.format([[
            SELECT COUNT(*) AS Total FROM %s
            WHERE SellerName='%s' AND Status=0
        ]], MP_Config.TableListings, GetObjectName(aIndex)),
        aIndex, "MP_SellCount_"..aIndex)
end

function MP_Sell.OnCountResult(identification, aIndex)
    local total = tonumber(QueryAsyncGetValue(identification, "Total")) or 0
    QueryAsyncDelete(identification)

    if total >= MP_Config.MaxListingsPerPlayer then
        CommandSend(aIndex, string.format(
            MP_Config.Msg.MaxListings, MP_Config.MaxListingsPerPlayer))
        PendingSell[aIndex] = nil; return
    end

    local p = PendingSell[aIndex]
    if not p then return end

    local checkIdx = InventoryGetItemIndex(aIndex, p.slot)
    if not checkIdx or checkIdx < 0 then
        CommandSend(aIndex, MP_Config.Msg.InvalidSlot)
        PendingSell[aIndex] = nil; return
    end

    InventoryDelItemIndex(aIndex, p.slot)

    local d          = p.itemData
    local expireTime = os.time() + MP_Config.AuctionDuration
    local tradeNote  = p.tradeNote:sub(1, 100)

    ExecuteQuery(string.format([[
        INSERT INTO %s
        (SellerName,Category,
         ItemIndex,ItemLevel,ItemDur,
         ItemOp1,ItemOp2,ItemOp3,ItemNewOpt,ItemSetOpt,
         ItemJoH,ItemOptEx,
         ItemSock1,ItemSock2,ItemSock3,ItemSock4,ItemSock5,ItemSockB,
         Price,Currency,AcceptTrade,TradeNote,ExpireTime,Status)
        VALUES
        ('%s',%d,
         %d,%d,%d,
         %d,%d,%d,%d,%d,
         %d,%d,
         %d,%d,%d,%d,%d,%d,
         %d,'%s',%d,'%s',%d,0)
    ]],
        MP_Config.TableListings,
        p.charName, p.category,
        d.Index    or 0,
        d.Level    or 0,
        d.Dur      or 255,
        d.Option1  or 0,
        d.Option2  or 0,
        d.Option3  or 0,
        d.NewOption            or 0,
        d.SetOption            or 0,
        d.JewelOfHarmonyOption or 0,
        d.OptionEx             or 0,
        d.SocketOption1        or 255,
        d.SocketOption2        or 255,
        d.SocketOption3        or 255,
        d.SocketOption4        or 255,
        d.SocketOption5        or 255,
        d.SocketOptionBonus    or 255,
        p.price, p.currency,
        p.acceptTrade,
        tradeNote,
        expireTime
    ))

    SQLQuery(string.format([[
        SELECT TOP 1 ID FROM %s
        WHERE SellerName='%s' AND Status=0
        ORDER BY ID DESC
    ]], MP_Config.TableListings, p.charName))
    SQLFetch()
    local newID = SQLGetNumber("ID")
    SQLClose()

    UserInfoSend(aIndex)
    MP_Core.SendOpenWindow(aIndex)

    MP_DB.Log("SELL_LIST", p.charName, nil, newID, 0,
        d.Index or 0, d.Level or 0, p.price, p.currency, "")

    CommandSend(aIndex, string.format(
        MP_Config.Msg.SellSuccess,
        newID, p.price, p.currency,
        MP_Config.AuctionDuration / 3600))

    PendingSell[aIndex] = nil
end

function MP_Sell.Cancel(aIndex, listingID)
    if not listingID then
        CommandSend(aIndex, "[MP] ID invalido."); return
    end

    PendingCancel[aIndex] = { id = listingID }

    CreateAsyncQuery("MP_CancelCheck",
        string.format([[
            SELECT ID,
            ItemIndex,ItemLevel,ItemDur,
            ItemOp1,ItemOp2,ItemOp3,ItemNewOpt,ItemSetOpt,
            ItemJoH,ItemOptEx,
            ItemSock1,ItemSock2,ItemSock3,ItemSock4,ItemSock5,ItemSockB
            FROM %s WHERE ID=%d AND Status=0 AND SellerName='%s'
        ]], MP_Config.TableListings, listingID, GetObjectName(aIndex)),
        aIndex, "MP_CancelCheck_"..aIndex)
end

function MP_Sell.OnCancelResult(identification, aIndex)
    local id = QueryAsyncGetValue(identification, "ID")
    if not id then
        QueryAsyncDelete(identification)
        CommandSend(aIndex, MP_Config.Msg.NotFound)
        PendingCancel[aIndex] = nil; return
    end

    local itemData = MP_DB.ReadItemRow(identification)
    local realID   = tonumber(id)
    QueryAsyncDelete(identification)

    if InventoryGetFreeSlotCount(aIndex) <= 0 then
        CommandSend(aIndex, MP_Config.Msg.NoSpace)
        PendingCancel[aIndex] = nil; return
    end

    local charName = GetObjectName(aIndex)
    CommandSend(aIndex, string.format(
        MP_Config.Msg.TxPending, MP_Config.TransactionDelay))

    MP_Core.EnqueueTx(function()
        MP_DB.GiveItem(aIndex, itemData)
        ExecuteQuery(string.format(
            "UPDATE %s SET Status=4 WHERE ID=%d",
            MP_Config.TableListings, realID))
        ExecuteQuery(string.format(
            "UPDATE %s SET Status=3 WHERE ListingID=%d AND Status=0",
            MP_Config.TableTrades, realID))
        UserInfoSend(aIndex)
        CommandSend(aIndex, string.format(
            MP_Config.Msg.CancelOk, realID))
        MP_DB.Log("CANCEL", charName, nil, realID, 0,
            itemData.ItemIndex, itemData.ItemLevel, 0, "N/A", "")
    end)

    PendingCancel[aIndex] = nil
end
MP_Trade = {}

local PendingOffer   = {}
local PendingAccept  = {}
local PendingDecline = {}

function MP_Trade.Offer(aIndex, listingID, slot)
    if not listingID or not slot then
        CommandSend(aIndex, "[MP] Dados invalidos."); return
    end

    if slot < InventoryGetWearSize() then
        CommandSend(aIndex, MP_Config.Msg.EquippedItem); return
    end

    local offItemIdx = InventoryGetItemIndex(aIndex, slot)
    if not offItemIdx or offItemIdx < 0 then
        CommandSend(aIndex, MP_Config.Msg.InvalidSlot); return
    end

    local itemData = InventoryGetItemTable(aIndex, slot)
    if not itemData then
        CommandSend(aIndex, "[MP] Erro ao ler item."); return
    end

    local taxCfg = MP_Config.TradeTax
    if MP_DB.GetCurrency(aIndex, taxCfg.Currency) < taxCfg.FlatFee then
        CommandSend(aIndex, string.format(
            MP_Config.Msg.TradeTaxNoMoney,
            taxCfg.FlatFee, taxCfg.Currency))
        return
    end

    PendingOffer[aIndex] = {
        listingID = listingID,
        slot      = slot,
        itemData  = itemData,
        charName  = GetObjectName(aIndex),
    }

    CreateAsyncQuery("MP_TradeOfferCheck",
        string.format([[
            SELECT ID,SellerName,AcceptTrade FROM %s
            WHERE ID=%d AND Status=0
        ]], MP_Config.TableListings, listingID),
        aIndex, "MP_TradeOfferCheck_"..aIndex)
end

function MP_Trade.OnOfferCheckResult(identification, aIndex)
    local id = QueryAsyncGetValue(identification, "ID")
    if not id then
        QueryAsyncDelete(identification)
        CommandSend(aIndex, MP_Config.Msg.NotFound)
        PendingOffer[aIndex] = nil; return
    end

    local seller      = QueryAsyncGetValue(identification, "SellerName") or ""
    local acceptTrade = tonumber(QueryAsyncGetValue(identification, "AcceptTrade")) or 0
    QueryAsyncDelete(identification)

    local p = PendingOffer[aIndex]
    if not p then return end

    if seller == p.charName then
        CommandSend(aIndex, MP_Config.Msg.OwnItem)
        PendingOffer[aIndex] = nil; return
    end

    if acceptTrade ~= 1 then
        CommandSend(aIndex, "[MP] Este anuncio nao aceita trocas.")
        PendingOffer[aIndex] = nil; return
    end

    CommandSend(aIndex, string.format(
        MP_Config.Msg.TxPending, MP_Config.TransactionDelay))

    MP_Core.EnqueueTx(function()
        local checkIdx = InventoryGetItemIndex(aIndex, p.slot)
        if not checkIdx or checkIdx < 0 then
            CommandSend(aIndex, MP_Config.Msg.InvalidSlot); return
        end

        local taxCfg = MP_Config.TradeTax
        MP_DB.SubCurrency(aIndex, taxCfg.Currency, taxCfg.FlatFee)
        InventoryDelItemIndex(aIndex, p.slot)

        local d = p.itemData
        ExecuteQuery(string.format([[
            INSERT INTO %s
            (ListingID,ProposerName,
             OffItemIndex,OffItemLevel,OffItemDur,
             OffItemOp1,OffItemOp2,OffItemOp3,
             OffItemNewOpt,OffItemSetOpt,OffItemJoH,OffItemOptEx,
             OffItemSock1,OffItemSock2,OffItemSock3,
             OffItemSock4,OffItemSock5,OffItemSockB,Status)
            VALUES
            (%d,'%s',
             %d,%d,%d,
             %d,%d,%d,
             %d,%d,%d,%d,
             %d,%d,%d,
             %d,%d,%d,0)
        ]],
            MP_Config.TableTrades,
            p.listingID, p.charName,
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
            d.SocketOptionBonus    or 255
        ))

        SQLQuery(string.format([[
            SELECT TOP 1 ID FROM %s
            WHERE ListingID=%d AND ProposerName='%s'
            ORDER BY ID DESC
        ]], MP_Config.TableTrades, p.listingID, p.charName))
        SQLFetch()
        local newTradeID = SQLGetNumber("ID")
        SQLClose()

        UserInfoSend(aIndex)
        CommandSend(aIndex, string.format(
            MP_Config.Msg.TradeOffered, newTradeID))

        local sellerIdx = GetObjectIndexByName(seller)
        if sellerIdx and sellerIdx >= 0
        and GetObjectConnected(sellerIdx) == 1 then
            CommandSend(sellerIdx, MP_Config.Msg.TradeReceived)
        end

        MP_DB.Log("TRADE_OFFER", p.charName, seller,
            p.listingID, newTradeID,
            d.Index or 0, d.Level or 0, 0, "N/A", "")
    end)

    PendingOffer[aIndex] = nil
end

function MP_Trade.Accept(aIndex, tradeID)
    if not tradeID then
        CommandSend(aIndex, "[MP] ID invalido."); return
    end

    local charName = GetObjectName(aIndex)
    PendingAccept[aIndex] = { tradeID = tradeID }

    CreateAsyncQuery("MP_TradeAcceptCheck",
        string.format([[
            SELECT t.ID,t.ProposerName,t.ListingID,
            t.OffItemIndex,t.OffItemLevel,t.OffItemDur,
            t.OffItemOp1,t.OffItemOp2,t.OffItemOp3,
            t.OffItemNewOpt,t.OffItemSetOpt,t.OffItemJoH,t.OffItemOptEx,
            t.OffItemSock1,t.OffItemSock2,t.OffItemSock3,
            t.OffItemSock4,t.OffItemSock5,t.OffItemSockB,
            l.ItemIndex,l.ItemLevel,l.ItemDur,
            l.ItemOp1,l.ItemOp2,l.ItemOp3,
            l.ItemNewOpt,l.ItemSetOpt,l.ItemJoH,l.ItemOptEx,
            l.ItemSock1,l.ItemSock2,l.ItemSock3,
            l.ItemSock4,l.ItemSock5,l.ItemSockB,
            l.SellerName
            FROM %s t
            INNER JOIN %s l ON l.ID=t.ListingID
            WHERE t.ID=%d AND t.Status=0
            AND l.SellerName='%s' AND l.Status=0
        ]],
        MP_Config.TableTrades,
        MP_Config.TableListings,
        tradeID, charName),
        aIndex, "MP_TradeAcceptCheck_"..aIndex)
end

function MP_Trade.OnAcceptResult(identification, aIndex)
    local id = QueryAsyncGetValue(identification, "ID")
    if not id then
        QueryAsyncDelete(identification)
        CommandSend(aIndex, MP_Config.Msg.NotFound)
        PendingAccept[aIndex] = nil; return
    end

    local data = {
        tradeID    = tonumber(id),
        proposer   = QueryAsyncGetValue(identification, "ProposerName") or "",
        listingID  = tonumber(QueryAsyncGetValue(identification, "ListingID")) or 0,
        seller     = QueryAsyncGetValue(identification, "SellerName") or "",
        offItem    = MP_DB.ReadItemRow(identification, "Off"),
        sellerItem = MP_DB.ReadItemRow(identification, ""),
    }
    QueryAsyncDelete(identification)

    local taxCfg = MP_Config.TradeTax
    if MP_DB.GetCurrency(aIndex, taxCfg.Currency) < taxCfg.FlatFee then
        CommandSend(aIndex, string.format(
            MP_Config.Msg.TradeTaxNoMoney,
            taxCfg.FlatFee, taxCfg.Currency))
        PendingAccept[aIndex] = nil; return
    end

    if InventoryGetFreeSlotCount(aIndex) <= 0 then
        CommandSend(aIndex, MP_Config.Msg.NoSpace)
        PendingAccept[aIndex] = nil; return
    end

    ExecuteQuery(string.format(
        "UPDATE %s SET Status=1 WHERE ID=%d AND Status=0",
        MP_Config.TableListings, data.listingID))

    CommandSend(aIndex, string.format(
        MP_Config.Msg.TxPending, MP_Config.TransactionDelay))

    MP_Core.EnqueueTx(function()
        MP_DB.SubCurrency(aIndex, taxCfg.Currency, taxCfg.FlatFee)

        MP_DB.GiveItem(aIndex, data.offItem)
        UserInfoSend(aIndex)
        CommandSend(aIndex, MP_Config.Msg.TradeAccepted)

        local propIdx    = GetObjectIndexByName(data.proposer)
        local propOnline = propIdx ~= nil
                        and propIdx >= 0
                        and GetObjectConnected(propIdx) == 1

        if propOnline then
            if InventoryGetFreeSlotCount(propIdx) > 0 then
                MP_DB.GiveItem(propIdx, data.sellerItem)
                UserInfoSend(propIdx)
                CommandSend(propIdx, MP_Config.Msg.TradeAccepted)
            end
        end

        ExecuteQuery(string.format(
            "UPDATE %s SET Status=1 WHERE ID=%d",
            MP_Config.TableTrades, data.tradeID))
        ExecuteQuery(string.format(
            "UPDATE %s SET Status=3 WHERE ID=%d",
            MP_Config.TableListings, data.listingID))
        ExecuteQuery(string.format(
            "UPDATE %s SET Status=3 WHERE ListingID=%d AND Status=0 AND ID<>%d",
            MP_Config.TableTrades, data.listingID, data.tradeID))

        MP_DB.Log("TRADE_ACCEPT", data.seller, data.proposer,
            data.listingID, data.tradeID,
            data.sellerItem.ItemIndex, data.sellerItem.ItemLevel,
            0, "N/A", "")
    end)

    PendingAccept[aIndex] = nil
end

function MP_Trade.Decline(aIndex, tradeID)
    if not tradeID then
        CommandSend(aIndex, "[MP] ID invalido."); return
    end

    local charName = GetObjectName(aIndex)

    CreateAsyncQuery("MP_TradeDeclineCheck",
        string.format([[
            SELECT t.ID,t.ProposerName,
            t.OffItemIndex,t.OffItemLevel,t.OffItemDur,
            t.OffItemOp1,t.OffItemOp2,t.OffItemOp3,
            t.OffItemNewOpt,t.OffItemSetOpt,t.OffItemJoH,t.OffItemOptEx,
            t.OffItemSock1,t.OffItemSock2,t.OffItemSock3,
            t.OffItemSock4,t.OffItemSock5,t.OffItemSockB
            FROM %s t
            INNER JOIN %s l ON l.ID=t.ListingID
            WHERE t.ID=%d AND t.Status=0
            AND l.SellerName='%s'
        ]],
        MP_Config.TableTrades,
        MP_Config.TableListings,
        tradeID, charName),
        aIndex, "MP_TradeDeclineCheck_"..aIndex)
end

function MP_Trade.OnDeclineResult(identification, aIndex)
    local id = QueryAsyncGetValue(identification, "ID")
    if not id then
        QueryAsyncDelete(identification)
        CommandSend(aIndex, MP_Config.Msg.NotFound)
        return
    end

    local proposer = QueryAsyncGetValue(identification, "ProposerName") or ""
    local offItem  = MP_DB.ReadItemRow(identification, "Off")
    local realID   = tonumber(id)
    QueryAsyncDelete(identification)

    MP_Core.EnqueueTx(function()
        -- Devolve item ao propositor
        local propIdx    = GetObjectIndexByName(proposer)
        local propOnline = propIdx ~= nil
                        and propIdx >= 0
                        and GetObjectConnected(propIdx) == 1

        if propOnline then
            if InventoryGetFreeSlotCount(propIdx) > 0 then
                MP_DB.GiveItem(propIdx, offItem)
                UserInfoSend(propIdx)
                CommandSend(propIdx, MP_Config.Msg.TradeDeclined)
            end
        end

        ExecuteQuery(string.format(
            "UPDATE %s SET Status=2 WHERE ID=%d",
            MP_Config.TableTrades, realID))

        local charName = GetObjectName(aIndex)
        CommandSend(aIndex, MP_Config.Msg.TradeDeclined)

        MP_DB.Log("TRADE_DECLINE", charName, proposer,
            0, realID, offItem.ItemIndex, offItem.ItemLevel,
            0, "N/A", "")
    end)
end
MP_Buy = {}

local PendingBuy = {}

function MP_Buy.Start(aIndex, listingID)
    if not listingID then
        CommandSend(aIndex, "[MP] ID invalido."); return
    end

    PendingBuy[aIndex] = { id = listingID }

    CreateAsyncQuery("MP_BuyCheck",
        string.format([[
            SELECT ID,SellerName,
            ItemIndex,ItemLevel,ItemDur,
            ItemOp1,ItemOp2,ItemOp3,ItemNewOpt,ItemSetOpt,
            ItemJoH,ItemOptEx,
            ItemSock1,ItemSock2,ItemSock3,ItemSock4,ItemSock5,ItemSockB,
            Price,Currency,ExpireTime
            FROM %s WHERE ID=%d AND Status=0
        ]], MP_Config.TableListings, listingID),
        aIndex, "MP_BuyCheck_"..aIndex)
end

function MP_Buy.OnCheckResult(identification, aIndex)
    local id = QueryAsyncGetValue(identification, "ID")
    if not id then
        QueryAsyncDelete(identification)
        CommandSend(aIndex, MP_Config.Msg.NotFound)
        PendingBuy[aIndex] = nil; return
    end

    local data = {
        id       = tonumber(id),
        seller   = QueryAsyncGetValue(identification, "SellerName") or "",
        price    = tonumber(QueryAsyncGetValue(identification, "Price"))      or 0,
        currency = QueryAsyncGetValue(identification, "Currency") or "Zen",
        expire   = tonumber(QueryAsyncGetValue(identification, "ExpireTime")) or 0,
        item     = MP_DB.ReadItemRow(identification),
    }
    QueryAsyncDelete(identification)

    local charName = GetObjectName(aIndex)

    if os.time() >= data.expire then
        CommandSend(aIndex, "[MP] Anuncio expirado.")
        PendingBuy[aIndex] = nil; return
    end

    if data.seller == charName then
        CommandSend(aIndex, MP_Config.Msg.OwnItem)
        PendingBuy[aIndex] = nil; return
    end

    if MP_DB.GetCurrency(aIndex, data.currency) < data.price then
        CommandSend(aIndex, MP_Config.Msg.NoMoney)
        PendingBuy[aIndex] = nil; return
    end

    if InventoryGetFreeSlotCount(aIndex) <= 0 then
        CommandSend(aIndex, MP_Config.Msg.NoSpace)
        PendingBuy[aIndex] = nil; return
    end

    ExecuteQuery(string.format(
        "UPDATE %s SET Status=1 WHERE ID=%d AND Status=0",
        MP_Config.TableListings, data.id))

    local tax    = math.floor(data.price * MP_Config.SellTax.Percent / 100)
    local netVal = data.price - tax

    CommandSend(aIndex, string.format(
        MP_Config.Msg.TxPending, MP_Config.TransactionDelay))

    MP_Core.EnqueueTx(function()
        MP_DB.SubCurrency(aIndex, data.currency, data.price)

        MP_DB.GiveItem(aIndex, data.item)
        UserInfoSend(aIndex)

        CommandSend(aIndex, string.format(
            MP_Config.Msg.BuySuccess, data.price, data.currency))

        ExecuteQuery(string.format(
            "UPDATE %s SET Status=3 WHERE ListingID=%d AND Status=0",
            MP_Config.TableTrades, data.id))

        local sellerIdx = GetObjectIndexByName(data.seller)
        local online    = sellerIdx ~= nil
                       and sellerIdx >= 0
                       and GetObjectConnected(sellerIdx) == 1

        if online then
            MP_DB.AddCurrency(sellerIdx, data.currency, netVal)
            CommandSend(sellerIdx, string.format(
                MP_Config.Msg.SoldOnline,
                data.id, netVal, data.currency, tax))
            ExecuteQuery(string.format(
                "UPDATE %s SET Status=3 WHERE ID=%d",
                MP_Config.TableListings, data.id))
        else
            ExecuteQuery(string.format(
                "UPDATE %s SET Status=2, Price=%d WHERE ID=%d",
                MP_Config.TableListings, netVal, data.id))
        end

        MP_DB.Log("BUY", data.seller, charName, data.id, 0,
            data.item.ItemIndex, data.item.ItemLevel,
            data.price, data.currency,
            string.format("Tax:%d Net:%d Online:%s",
                tax, netVal, tostring(online)))
    end)

    PendingBuy[aIndex] = nil
end
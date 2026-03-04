MP_Core = {}

local TimerCounter = 0
local TxQueue      = {}

function MP_Core.EnqueueTx(fn)
    table.insert(TxQueue, {
        executeAt = os.time() + MP_Config.TransactionDelay,
        fn        = fn,
    })
end

local function ProcessTxQueue()
    if #TxQueue == 0 then return end
    local now, remaining = os.time(), {}
    for _, tx in ipairs(TxQueue) do
        if now >= tx.executeAt then
            local ok, err = pcall(tx.fn)
            if not ok then
                LogColor(1, "[MarketPlace] ERRO: "..tostring(err))
            end
        else
            table.insert(remaining, tx)
        end
    end
    TxQueue = remaining
end

function MP_Core.OnTimerThread()
    ProcessTxQueue()
    TimerCounter = TimerCounter + 1
    if TimerCounter >= MP_Config.CheckExpiredInterval then
        TimerCounter = 0
        MP_Core.ProcessExpired()
    end
end

function MP_Core.ProcessExpired()
    local T   = MP_Config.TableListings
    local now = os.time()
    SQLQuery(string.format([[
        SELECT ID,SellerName,
        ItemIndex,ItemLevel,ItemDur,
        ItemOp1,ItemOp2,ItemOp3,ItemNewOpt,ItemSetOpt,
        ItemJoH,ItemOptEx,
        ItemSock1,ItemSock2,ItemSock3,ItemSock4,ItemSock5,ItemSockB
        FROM %s WHERE Status=0 AND ExpireTime<=%d
    ]], T, now))
    local expired = {}
    while SQLFetch() do
        table.insert(expired, {
            id     = SQLGetNumber("ID"),
            seller = SQLGetString("SellerName"),
            item   = {
                ItemIndex  = SQLGetNumber("ItemIndex"),
                ItemLevel  = SQLGetNumber("ItemLevel"),
                ItemDur    = SQLGetNumber("ItemDur"),
                ItemOp1    = SQLGetNumber("ItemOp1"),
                ItemOp2    = SQLGetNumber("ItemOp2"),
                ItemOp3    = SQLGetNumber("ItemOp3"),
                ItemNewOpt = SQLGetNumber("ItemNewOpt"),
                ItemSetOpt = SQLGetNumber("ItemSetOpt"),
                ItemJoH    = SQLGetNumber("ItemJoH"),
                ItemOptEx  = SQLGetNumber("ItemOptEx"),
                ItemSock1  = SQLGetNumber("ItemSock1"),
                ItemSock2  = SQLGetNumber("ItemSock2"),
                ItemSock3  = SQLGetNumber("ItemSock3"),
                ItemSock4  = SQLGetNumber("ItemSock4"),
                ItemSock5  = SQLGetNumber("ItemSock5"),
                ItemSockB  = SQLGetNumber("ItemSockB"),
            }
        })
    end
    SQLClose()
    for _, entry in ipairs(expired) do
        local sellerIdx = GetObjectIndexByName(entry.seller)
        local online = sellerIdx ~= nil
                    and sellerIdx >= 0
                    and GetObjectConnected(sellerIdx) == 1
        if online and InventoryGetFreeSlotCount(sellerIdx) > 0 then
            MP_DB.GiveItem(sellerIdx, entry.item)
            UserInfoSend(sellerIdx)
            CommandSend(sellerIdx, MP_Config.Msg.ExpiredReturn)
            ExecuteQuery(string.format(
                "UPDATE %s SET Status=4 WHERE ID=%d", T, entry.id))
        else
            ExecuteQuery(string.format(
                "UPDATE %s SET Status=5 WHERE ID=%d", T, entry.id))
        end
        ExecuteQuery(string.format(
            "UPDATE %s SET Status=3 WHERE ListingID=%d AND Status=0",
            MP_Config.TableTrades, entry.id))
        MP_DB.Log("EXPIRED", entry.seller, nil, entry.id, 0,
            entry.item.ItemIndex, entry.item.ItemLevel, 0, "N/A", "")
    end
end

function MP_Core.OnCharacterEntry(aIndex)
    local charName = GetObjectName(aIndex)
    CreateAsyncQuery("MP_PendingMoney",
        string.format([[
            SELECT ID,Price,Currency FROM %s
            WHERE SellerName='%s' AND Status=2
        ]], MP_Config.TableListings, charName),
        aIndex, "MP_PendMoney_"..aIndex)
    CreateAsyncQuery("MP_PendingReturn",
        string.format([[
            SELECT ID,
            ItemIndex,ItemLevel,ItemDur,
            ItemOp1,ItemOp2,ItemOp3,ItemNewOpt,ItemSetOpt,
            ItemJoH,ItemOptEx,
            ItemSock1,ItemSock2,ItemSock3,ItemSock4,ItemSock5,ItemSockB
            FROM %s WHERE SellerName='%s' AND Status=5
        ]], MP_Config.TableListings, charName),
        aIndex, "MP_PendReturn_"..aIndex)
end

function MP_Core.DeliverPendingMoney(identification, aIndex)
    local totals = { Zen=0, WC=0, WP=0, GP=0 }
    local ids    = {}
    repeat
        local id = QueryAsyncGetValue(identification, "ID")
        if id == nil then break end
        local price    = tonumber(QueryAsyncGetValue(identification, "Price")) or 0
        local currency = QueryAsyncGetValue(identification, "Currency") or "Zen"
        local tax      = math.floor(price * MP_Config.SellTax.Percent / 100)
        totals[currency] = (totals[currency] or 0) + (price - tax)
        table.insert(ids, tostring(id))
    until not SQLFetch()
    QueryAsyncDelete(identification)
    for currency, amount in pairs(totals) do
        if amount > 0 then
            MP_DB.AddCurrency(aIndex, currency, amount)
            CommandSend(aIndex, string.format(
                MP_Config.Msg.SoldOffline, amount, currency))
        end
    end
    if #ids > 0 then
        ExecuteQuery(string.format(
            "UPDATE %s SET Status=3 WHERE ID IN (%s)",
            MP_Config.TableListings, table.concat(ids, ",")))
    end
end

function MP_Core.DeliverPendingReturn(identification, aIndex)
    local ids = {}
    repeat
        local id = QueryAsyncGetValue(identification, "ID")
        if id == nil then break end
        local itemData = MP_DB.ReadItemRow(identification)
        if InventoryGetFreeSlotCount(aIndex) > 0 then
            MP_DB.GiveItem(aIndex, itemData)
            table.insert(ids, tostring(id))
            CommandSend(aIndex, MP_Config.Msg.ExpiredOffline)
        end
    until not SQLFetch()
    QueryAsyncDelete(identification)
    if #ids > 0 then
        ExecuteQuery(string.format(
            "UPDATE %s SET Status=4 WHERE ID IN (%s)",
            MP_Config.TableListings, table.concat(ids, ",")))
        UserInfoSend(aIndex)
    end
end

function MP_Core.OnNpcTalk(npcIndex, playerIndex)
    if MP_Config.Enable ~= 1 then return 0 end
    local cfg = MP_Config.NPC
    if GetObjectClass(npcIndex) == cfg.MonsterID
    and GetObjectMap(npcIndex)  == cfg.Map
    and GetObjectMapX(npcIndex) == cfg.PosX
    and GetObjectMapY(npcIndex) == cfg.PosY then
        MP_Core.SendOpenWindow(playerIndex)
        return 1
    end
    return 0
end

function MP_Core.SendOpenWindow(aIndex)
    CreatePacket("MP_Open", 0xF1)
    SetBytePacket("MP_Open", 0x01)
    SendPacket("MP_Open", aIndex)
    ClearPacket("MP_Open")
end

function MP_Core.SendItemList(identification, aIndex)
    local items   = {}
    local currMap = { Zen=0, WC=1, WP=2, GP=3 }
    repeat
        local id = QueryAsyncGetValue(identification, "ID")
        if id == nil then break end
        table.insert(items, {
            id          = tonumber(id),
            seller      = QueryAsyncGetValue(identification, "SellerName") or "",
            itemIndex   = tonumber(QueryAsyncGetValue(identification, "ItemIndex"))   or 0,
            itemLevel   = tonumber(QueryAsyncGetValue(identification, "ItemLevel"))   or 0,
            itemDur     = tonumber(QueryAsyncGetValue(identification, "ItemDur"))     or 255,
            itemOp1     = tonumber(QueryAsyncGetValue(identification, "ItemOp1"))     or 0,
            itemOp2     = tonumber(QueryAsyncGetValue(identification, "ItemOp2"))     or 0,
            itemOp3     = tonumber(QueryAsyncGetValue(identification, "ItemOp3"))     or 0,
            itemNewOpt  = tonumber(QueryAsyncGetValue(identification, "ItemNewOpt"))  or 0,
            itemSetOpt  = tonumber(QueryAsyncGetValue(identification, "ItemSetOpt"))  or 0,
            itemJoH     = tonumber(QueryAsyncGetValue(identification, "ItemJoH"))     or 0,
            itemOptEx   = tonumber(QueryAsyncGetValue(identification, "ItemOptEx"))   or 0,
            itemSock1   = tonumber(QueryAsyncGetValue(identification, "ItemSock1"))   or 255,
            itemSock2   = tonumber(QueryAsyncGetValue(identification, "ItemSock2"))   or 255,
            itemSock3   = tonumber(QueryAsyncGetValue(identification, "ItemSock3"))   or 255,
            itemSock4   = tonumber(QueryAsyncGetValue(identification, "ItemSock4"))   or 255,
            itemSock5   = tonumber(QueryAsyncGetValue(identification, "ItemSock5"))   or 255,
            itemSockB   = tonumber(QueryAsyncGetValue(identification, "ItemSockB"))   or 255,
            price       = tonumber(QueryAsyncGetValue(identification, "Price"))       or 0,
            currency    = QueryAsyncGetValue(identification, "Currency") or "Zen",
            acceptTrade = tonumber(QueryAsyncGetValue(identification, "AcceptTrade")) or 0,
            tradeNote   = QueryAsyncGetValue(identification, "TradeNote") or "",
            expireTime  = tonumber(QueryAsyncGetValue(identification, "ExpireTime"))  or 0,
        })
    until not SQLFetch()
    QueryAsyncDelete(identification)
    CreatePacket("MP_ItemList", 0xF2)
    SetBytePacket("MP_ItemList", #items)
    for _, it in ipairs(items) do
        local hours = math.max(0,
            math.floor((it.expireTime - os.time()) / 3600))
        SetDwordPacket("MP_ItemList", it.id)
        SetDwordPacket("MP_ItemList", it.itemIndex)
        SetBytePacket ("MP_ItemList", it.itemLevel)
        SetBytePacket ("MP_ItemList", it.itemDur)
        SetDwordPacket("MP_ItemList", it.itemOp1)
        SetDwordPacket("MP_ItemList", it.itemOp2)
        SetDwordPacket("MP_ItemList", it.itemOp3)
        SetDwordPacket("MP_ItemList", it.itemNewOpt)
        SetDwordPacket("MP_ItemList", it.itemSetOpt)
        SetBytePacket ("MP_ItemList", it.itemJoH)
        SetDwordPacket("MP_ItemList", it.itemOptEx)
        SetBytePacket ("MP_ItemList", it.itemSock1)
        SetBytePacket ("MP_ItemList", it.itemSock2)
        SetBytePacket ("MP_ItemList", it.itemSock3)
        SetBytePacket ("MP_ItemList", it.itemSock4)
        SetBytePacket ("MP_ItemList", it.itemSock5)
        SetBytePacket ("MP_ItemList", it.itemSockB)
        SetDwordPacket("MP_ItemList", it.price)
        SetBytePacket ("MP_ItemList", currMap[it.currency] or 0)
        SetBytePacket ("MP_ItemList", it.acceptTrade)
        SetWordPacket ("MP_ItemList", hours)
        SetCharPacket ("MP_ItemList", it.seller)
        SetCharPacketLength("MP_ItemList", it.tradeNote, 100)
    end
    SendPacket("MP_ItemList", aIndex)
    ClearPacket("MP_ItemList")
end

function MP_Core.SendMyItems(identification, aIndex)
    local items   = {}
    local currMap = { Zen=0, WC=1, WP=2, GP=3 }
    repeat
        local id = QueryAsyncGetValue(identification, "ID")
        if id == nil then break end
        table.insert(items, {
            id          = tonumber(id),
            itemIndex   = tonumber(QueryAsyncGetValue(identification, "ItemIndex"))  or 0,
            itemLevel   = tonumber(QueryAsyncGetValue(identification, "ItemLevel"))  or 0,
            itemNewOpt  = tonumber(QueryAsyncGetValue(identification, "ItemNewOpt")) or 0,
            price       = tonumber(QueryAsyncGetValue(identification, "Price"))      or 0,
            currency    = QueryAsyncGetValue(identification, "Currency") or "Zen",
            acceptTrade = tonumber(QueryAsyncGetValue(identification, "AcceptTrade"))or 0,
            expireTime  = tonumber(QueryAsyncGetValue(identification, "ExpireTime")) or 0,
        })
    until not SQLFetch()
    QueryAsyncDelete(identification)
    CreatePacket("MP_MyItems", 0xF3)
    SetBytePacket("MP_MyItems", #items)
    for _, it in ipairs(items) do
        local hours = math.max(0,
            math.floor((it.expireTime - os.time()) / 3600))
        SetDwordPacket("MP_MyItems", it.id)
        SetDwordPacket("MP_MyItems", it.itemIndex)
        SetBytePacket ("MP_MyItems", it.itemLevel)
        SetDwordPacket("MP_MyItems", it.itemNewOpt)
        SetDwordPacket("MP_MyItems", it.price)
        SetBytePacket ("MP_MyItems", currMap[it.currency] or 0)
        SetBytePacket ("MP_MyItems", it.acceptTrade)
        SetWordPacket ("MP_MyItems", hours)
    end
    SendPacket("MP_MyItems", aIndex)
    ClearPacket("MP_MyItems")
end

function MP_Core.SendTradeList(identification, aIndex)
    local items = {}
    repeat
        local id = QueryAsyncGetValue(identification, "ID")
        if id == nil then break end
        table.insert(items, {
            tradeID    = tonumber(id),
            listingID  = tonumber(QueryAsyncGetValue(identification, "ListingID"))    or 0,
            proposer   = QueryAsyncGetValue(identification, "ProposerName") or "",
            offItemIdx = tonumber(QueryAsyncGetValue(identification, "OffItemIndex")) or 0,
            offItemLvl = tonumber(QueryAsyncGetValue(identification, "OffItemLevel")) or 0,
            offItemNew = tonumber(QueryAsyncGetValue(identification, "OffItemNewOpt"))or 0,
        })
    until not SQLFetch()
    QueryAsyncDelete(identification)
    CreatePacket("MP_TradeList", 0xF4)
    SetBytePacket("MP_TradeList", #items)
    for _, it in ipairs(items) do
        SetDwordPacket("MP_TradeList", it.tradeID)
        SetDwordPacket("MP_TradeList", it.listingID)
        SetCharPacket ("MP_TradeList", it.proposer)
        SetDwordPacket("MP_TradeList", it.offItemIdx)
        SetBytePacket ("MP_TradeList", it.offItemLvl)
        SetDwordPacket("MP_TradeList", it.offItemNew)
    end
    SendPacket("MP_TradeList", aIndex)
    ClearPacket("MP_TradeList")
end
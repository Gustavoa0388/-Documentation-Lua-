-- ================================================================
--  MarketPlace/Init.lua
--  Inicialização e dispatcher de todos os eventos
-- ================================================================

-- ─── INICIALIZAÇÃO ───────────────────────────────────────────────
MP_DB.Init()
LogColor(3, "[MarketPlace] Sistema carregado com sucesso!")

-- ─── TIMER ───────────────────────────────────────────────────────
RegisterTimer("MP_Timer", 1000, function()
    MP_Core.OnTimerThread()
end)

-- ─── ENTRADA DO PLAYER ───────────────────────────────────────────
RegisterEvent("OnCharacterEntry", function(aIndex)
    MP_Core.OnCharacterEntry(aIndex)
end)

-- ─── NPC TALK ────────────────────────────────────────────────────
RegisterEvent("OnNpcTalk", function(npcIndex, playerIndex)
    return MP_Core.OnNpcTalk(npcIndex, playerIndex)
end)

-- ─── ASYNC QUERY RESULTS ─────────────────────────────────────────
RegisterEvent("OnAsyncQueryResult", function(identification, aIndex)

    -- Pendências de dinheiro ao logar
    if string.find(identification, "MP_PendMoney_") then
        MP_Core.DeliverPendingMoney(identification, aIndex)
        return
    end

    -- Pendências de item expirado ao logar
    if string.find(identification, "MP_PendReturn_") then
        MP_Core.DeliverPendingReturn(identification, aIndex)
        return
    end

    -- Contagem de anúncios ao cadastrar
    if string.find(identification, "MP_SellCount_") then
        MP_Sell.OnCountResult(identification, aIndex)
        return
    end

    -- Verificação ao cancelar anúncio
    if string.find(identification, "MP_CancelCheck_") then
        MP_Sell.OnCancelResult(identification, aIndex)
        return
    end

    -- Verificação ao comprar
    if string.find(identification, "MP_BuyCheck_") then
        MP_Buy.OnCheckResult(identification, aIndex)
        return
    end

    -- Lista de itens do marketplace
    if string.find(identification, "MP_ItemList_") then
        MP_Core.SendItemList(identification, aIndex)
        return
    end

    -- Meus anúncios
    if string.find(identification, "MP_MyItems_") then
        MP_Core.SendMyItems(identification, aIndex)
        return
    end

    -- Verificação de proposta de troca
    if string.find(identification, "MP_TradeOfferCheck_") then
        MP_Trade.OnOfferCheckResult(identification, aIndex)
        return
    end

    -- Verificação de aceite de troca
    if string.find(identification, "MP_TradeAcceptCheck_") then
        MP_Trade.OnAcceptResult(identification, aIndex)
        return
    end

    -- Verificação de recusa de troca
    if string.find(identification, "MP_TradeDeclineCheck_") then
        MP_Trade.OnDeclineResult(identification, aIndex)
        return
    end

    -- Lista de propostas de troca
    if string.find(identification, "MP_TradeList_") then
        MP_Core.SendTradeList(identification, aIndex)
        return
    end

end)

-- ─── PACKETS DO CLIENT ───────────────────────────────────────────
-- Packet principal: 0xF0
-- Sub-códigos:
--   0x01 = Solicitar lista de itens
--   0x02 = Cadastrar item para venda
--   0x03 = Cancelar anúncio
--   0x04 = Comprar item
--   0x05 = Propor troca
--   0x06 = Aceitar troca
--   0x07 = Recusar troca
--   0x08 = Solicitar meus anúncios
--   0x09 = Solicitar lista de propostas recebidas

RegisterEvent("OnPacketReceived", function(aIndex, packetID, subCode)
    if packetID ~= 0xF0 then return end

    -- 0x01 — Solicitar lista de itens
    if subCode == 0x01 then
        local page     = GetBytePacket()   -- página (0-based)
        local category = GetBytePacket()   -- categoria (0=todos)

        local whereCategory = ""
        if category ~= nil and category > 0 then
            whereCategory = string.format("AND Category=%d", category)
        end

        local offset = (page or 0) * MP_Config.ItemsPerPage

        CreateAsyncQuery("MP_ItemList",
            string.format([[
                SELECT ID,SellerName,Category,
                ItemIndex,ItemLevel,ItemDur,
                ItemOp1,ItemOp2,ItemOp3,ItemNewOpt,ItemSetOpt,
                ItemJoH,ItemOptEx,
                ItemSock1,ItemSock2,ItemSock3,ItemSock4,ItemSock5,ItemSockB,
                Price,Currency,AcceptTrade,TradeNote,ExpireTime
                FROM %s
                WHERE Status=0 %s
                ORDER BY ID DESC
                OFFSET %d ROWS FETCH NEXT %d ROWS ONLY
            ]],
            MP_Config.TableListings,
            whereCategory,
            offset,
            MP_Config.ItemsPerPage),
            aIndex, "MP_ItemList_"..aIndex)
        return
    end

    -- 0x02 — Cadastrar item para venda
    if subCode == 0x02 then
        local slot        = GetBytePacket()
        local price       = GetDwordPacket()
        local currencyID  = GetBytePacket()
        local acceptTrade = GetBytePacket()
        local tradeNote   = GetCharPacketLength(100)

        local currencyMap = { [0]="Zen", [1]="WC", [2]="WP", [3]="GP" }
        local currency    = currencyMap[currencyID] or "Zen"

        MP_Sell.Register(aIndex, slot, price, currency,
            acceptTrade, tradeNote)
        return
    end

    -- 0x03 — Cancelar anúncio
    if subCode == 0x03 then
        local listingID = GetDwordPacket()
        MP_Sell.Cancel(aIndex, listingID)
        return
    end

    -- 0x04 — Comprar item
    if subCode == 0x04 then
        local listingID = GetDwordPacket()
        MP_Buy.Start(aIndex, listingID)
        return
    end

    -- 0x05 — Propor troca
    if subCode == 0x05 then
        local listingID = GetDwordPacket()
        local slot      = GetBytePacket()
        MP_Trade.Offer(aIndex, listingID, slot)
        return
    end

    -- 0x06 — Aceitar troca
    if subCode == 0x06 then
        local tradeID = GetDwordPacket()
        MP_Trade.Accept(aIndex, tradeID)
        return
    end

    -- 0x07 — Recusar troca
    if subCode == 0x07 then
        local tradeID = GetDwordPacket()
        MP_Trade.Decline(aIndex, tradeID)
        return
    end

    -- 0x08 — Meus anúncios
    if subCode == 0x08 then
        CreateAsyncQuery("MP_MyItems",
            string.format([[
                SELECT ID,ItemIndex,ItemLevel,ItemNewOpt,
                Price,Currency,AcceptTrade,ExpireTime
                FROM %s
                WHERE SellerName='%s' AND Status=0
                ORDER BY ID DESC
            ]],
            MP_Config.TableListings,
            GetObjectName(aIndex)),
            aIndex, "MP_MyItems_"..aIndex)
        return
    end

    -- 0x09 — Propostas de troca recebidas
    if subCode == 0x09 then
        CreateAsyncQuery("MP_TradeList",
            string.format([[
                SELECT t.ID,t.ListingID,t.ProposerName,
                t.OffItemIndex,t.OffItemLevel,t.OffItemNewOpt
                FROM %s t
                INNER JOIN %s l ON l.ID=t.ListingID
                WHERE l.SellerName='%s' AND t.Status=0
                ORDER BY t.ID DESC
            ]],
            MP_Config.TableTrades,
            MP_Config.TableListings,
            GetObjectName(aIndex)),
            aIndex, "MP_TradeList_"..aIndex)
        return
    end

end)

LogColor(3, "[MarketPlace] Eventos e packets registrados!")
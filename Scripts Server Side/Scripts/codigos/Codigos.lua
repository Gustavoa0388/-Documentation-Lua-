local CONFIG = require("Scripts\\codigos\\Config")

Codigo = {}
Mec = " "

-- Tabela de códigos com múltiplos itens associados
Codigos = { 
    { 
    SM   = { 
        { Index = GET_ITEM(05, 0005), Level = 15, Luck = 1, Skill = 1, Life = 7, Ex = 63 }, 
        { Index = GET_ITEM(06, 0014), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(07, 0003), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(08, 0003), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(09, 0003), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(10, 0003), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(11, 0003), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(12, 0004), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 15 },
        { Index = GET_ITEM(14, 0012), Level = 00, Luck = 0, Skill = 0, Life = 0, Ex = 00 },
    },
    BK = { 
        { Index = GET_ITEM(00, 0016), Level = 15, Luck = 1, Skill = 1, Life = 7, Ex = 63 }, 
        { Index = GET_ITEM(06, 0007), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(07, 0001), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(08, 0001), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(09, 0001), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(10, 0001), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(11, 0001), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(12, 0005), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 15 },
        { Index = GET_ITEM(14, 0012), Level = 00, Luck = 0, Skill = 0, Life = 0, Ex = 00 },
    },
    ELF = { 
        { Index = GET_ITEM(04, 0006), Level = 15, Luck = 1, Skill = 1, Life = 7, Ex = 63 }, 
        { Index = GET_ITEM(07, 0010), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(08, 0010), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(09, 0010), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(10, 0010), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(11, 0010), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(12, 0003), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 15 },
        { Index = GET_ITEM(14, 0012), Level = 00, Luck = 0, Skill = 0, Life = 0, Ex = 00 },
    },
    MG = { 
        { Index = GET_ITEM(00, 0031), Level = 15, Luck = 1, Skill = 1, Life = 7, Ex = 63 }, 
        { Index = GET_ITEM(08, 0001), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(09, 0001), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(10, 0001), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(11, 0001), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(12, 0006), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 15 },
        { Index = GET_ITEM(14, 0012), Level = 00, Luck = 0, Skill = 0, Life = 0, Ex = 00 },
    },
    DL = { 
        { Index = GET_ITEM(02, 0008), Level = 15, Luck = 1, Skill = 1, Life = 7, Ex = 63 }, 
        { Index = GET_ITEM(06, 0007), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(07, 0026), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(08, 0026), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(09, 0026), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(10, 0026), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(11, 0026), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(13, 0030), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 15 },
        { Index = GET_ITEM(14, 0012), Level = 00, Luck = 0, Skill = 0, Life = 0, Ex = 00 },
    },
    SUM = { 
        { Index = GET_ITEM(05, 0014), Level = 15, Luck = 1, Skill = 1, Life = 7, Ex = 63 }, 
        { Index = GET_ITEM(05, 0021), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(07, 0039), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(08, 0039), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(09, 0039), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(10, 0039), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(11, 0039), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(12, 0042), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 15 },
        { Index = GET_ITEM(14, 0012), Level = 00, Luck = 0, Skill = 0, Life = 0, Ex = 00 },
    },
    RF = { 
        { Index = GET_ITEM(00, 0032), Level = 15, Luck = 1, Skill = 1, Life = 7, Ex = 63 }, 
        { Index = GET_ITEM(00, 0032), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(07, 0059), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(08, 0059), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(09, 0059), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(11, 0059), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 63 },
        { Index = GET_ITEM(12, 0049), Level = 15, Luck = 0, Skill = 1, Life = 5, Ex = 15 },
        { Index = GET_ITEM(14, 0012), Level = 00, Luck = 0, Skill = 0, Life = 0, Ex = 00 },
    }
    }
        
    }

    
BridgeFunctionAttach('OnCharacterEntry','InitEnterCharacter')
BridgeFunctionAttach('OnCommandManager','InitCommandManager')


function InitEnterCharacter(aIndex)
    GetHWID(aIndex)
end

function InitCommandManager(aIndex, Arguments)

    local Command = CommandGetArgString(Arguments,0)

    if not (Command == CONFIG.Command) then
		return 0
	end
    LogColor(1, 'teste1')
    Codigo.Command(aIndex, Arguments)

end

function GetHWID(aIndex)

    local HWID = DataBase.GetString('MEMB_STAT', 'HARDWAREID', 'memb___id', GetObjectAccount(aIndex))
    Mec = HWID

end


function Codigo.Check(aIndex)

    local GetValue = Codigo.GetValue('Codigos', 'Premiado', 'AccountID', GetObjectAccount(aIndex))

    if GetValue == 0 then 
        return 0
    else
        return 1
    end

end


function Codigo.Msg1(aIndex)
    MessageSend(aIndex, 1, 0, string.format("Você só pode usar este codigo 1x"))
end

function Codigo.Msg2(aIndex, string)
    MessageSend(aIndex, 1, 0, string.format("%s",string))
    LogColor(2, string.format("%s",string))
end


function Codigo.Command(aIndex, Arguments)

	local Account = GetObjectAccount(aIndex)

    local Argument = CommandGetArgString(Arguments,1)

	local cod	 = DataBase.GetString('PainelCodigos', 'Codigo', 'Codigo', Argument)

    GetHWID(aIndex)

    for i, codigo in ipairs(Codigos) do
		
        	if string.lower(Argument) == string.lower(cod) then --

                if Codigo.Check(aIndex) == 1 then   Codigo.Msg1(aIndex)  return   end
				if  DataBase.GetString('Codigos', 'HWID', 'AccountID', Account) == Mec then  Msg1(aIndex) return end

						if GetObjectClass(aIndex) == 0 then
							for _, item in ipairs(codigo.SM) do
                                --if CONFIG.Type == 0 then
                                --    ItemGiveEx(aIndex,item.Index,item.Level,-1,item.Luck,item.Skill,item.Life,item.Ex,0,0,0,255,255,255,255,255,0,0)
                                --else
                                    LogColor(2, string.format('%s adicionados para %s', item.Index, Account))
                                    Codigo.InsertItem(GetObjectAccount(aIndex), item.Index, item.Level, item.Luck, item.Skill, item.Life, item.Ex, 0, 0, 0, 255, 255, 255, 255, 255, 0, 4*86400)
                                --end
							end
						elseif GetObjectClass(aIndex) == 1 then
							for _, item in ipairs(codigo.BK) do
                            --    ItemGiveEx(aIndex,item.Index,item.Level,-1,item.Luck,item.Skill,item.Life,item.Ex,0,0,0,255,255,255,255,255,0,0)
                                LogColor(2, string.format('%s adicionados para %s', item.Index, Account))
                                Codigo.InsertItem(GetObjectAccount(aIndex), item.Index, item.Level, item.Luck, item.Skill, item.Life, item.Ex, 0, 0, 0, 255, 255, 255, 255, 255, 0, 4*86400)
							end
						elseif GetObjectClass(aIndex) == 2 then						
							for _, item in ipairs(codigo.ELF) do
                             --   ItemGiveEx(aIndex,item.Index,item.Level,-1,item.Luck,item.Skill,item.Life,item.Ex,0,0,0,255,255,255,255,255,0,0)
                             LogColor(2, string.format('%s adicionados para %s', item.Index, Account))
                                Codigo.InsertItem(GetObjectAccount(aIndex), item.Index, item.Level, item.Luck, item.Skill, item.Life, item.Ex, 0, 0, 0, 255, 255, 255, 255, 255, 0, 4*86400)
							end
						elseif GetObjectClass(aIndex) == 3 then						
							for _, item in ipairs(codigo.MG) do
                             --   ItemGiveEx(aIndex,item.Index,item.Level,-1,item.Luck,item.Skill,item.Life,item.Ex,0,0,0,255,255,255,255,255,0,0)
                             LogColor(2, string.format('%s adicionados para %s', item.Index, Account))
                                Codigo.InsertItem(GetObjectAccount(aIndex), item.Index, item.Level, item.Luck, item.Skill, item.Life, item.Ex, 0, 0, 0, 255, 255, 255, 255, 255, 0, 4*86400)
							end
						elseif GetObjectClass(aIndex) == 4 then						
							for _, item in ipairs(codigo.DL) do
                              --  ItemGiveEx(aIndex,item.Index,item.Level,-1,item.Luck,item.Skill,item.Life,item.Ex,0,0,0,255,255,255,255,255,0,0)
                              LogColor(2, string.format('%s adicionados para %s', item.Index, Account))
                                Codigo.InsertItem(GetObjectAccount(aIndex), item.Index, item.Level, item.Luck, item.Skill, item.Life, item.Ex, 0, 0, 0, 255, 255, 255, 255, 255, 0, 4*86400)
							end
						elseif GetObjectClass(aIndex) == 5 then						
							for _, item in ipairs(codigo.SUM) do
                              --  ItemGiveEx(aIndex,item.Index,item.Level,-1,item.Luck,item.Skill,item.Life,item.Ex,0,0,0,255,255,255,255,255,0,0)
                              LogColor(2, string.format('%s adicionados para %s', item.Index, Account))
                                Codigo.InsertItem(GetObjectAccount(aIndex), item.Index, item.Level, item.Luck, item.Skill, item.Life, item.Ex, 0, 0, 0, 255, 255, 255, 255, 255, 0, 4*86400)
							end					
						elseif GetObjectClass(aIndex) == 6 then						
							for _, item in ipairs(codigo.RF) do
                               -- ItemGiveEx(aIndex,item.Index,item.Level,-1,item.Luck,item.Skill,item.Life,item.Ex,0,0,0,255,255,255,255,255,0,0)
                               LogColor(2, string.format('%s adicionados para %s', item.Index, Account))
                                Codigo.InsertItem(GetObjectAccount(aIndex), item.Index, item.Level, item.Luck, item.Skill, item.Life, item.Ex, 0, 0, 0, 255, 255, 255, 255, 255, 0, 4*86400)
							end
						end

                        Codigo.Msg2(aIndex, string.format("Itens do código '%s' adicionados ao NPC Rescue Item.", cod,Mec))

                            

                        DataBase.InsertCodigo("Codigos", Account, cod, Mec)

					    return
        	
                        else 
                            Codigo.Msg2(aIndex, 'Código inexistente ou inválido!')        
                        end
    end
end




function Codigo.GetValue(Table, Column, Where, Name)
	local Query = string.format("SELECT %s FROM %s WHERE %s = '%s'", Column, Table, Where, Name)
	ret = SQLQuery(Query)

	nRet = SQLFetch()
	
	if nRet == SQL_NO_DATA
	then
		SQLClose()
		return 0
	end
	
	local val = SQLGetNumber(Column)
	SQLClose()
	return val
end

function Codigo.InsertItem(Account, Item, Itemlevel, iOp1, iOp2, iOp3, iExc, iAncient, iJoH, iSockCount, iSock1, iSock2, iSock3, iSock4, iSock5, DaysExpire, ItemTimeExpire)
    -- Verifica se ItemTimeExpire é nulo, se for, atribui 0
    if ItemTimeExpire == nil then
        ItemTimeExpire = 0
    end

    -- Chama a função DataBase.InsertNpcRescueItem para inserir o item
    DataBase.InsertNpcRescueItem(Account, Item, Itemlevel, iOp1, iOp2, iOp3, iExc, iAncient, iJoH, iSockCount, iSock1, iSock2, iSock3, iSock4, iSock5, ItemTimeExpire, DaysExpire)
end
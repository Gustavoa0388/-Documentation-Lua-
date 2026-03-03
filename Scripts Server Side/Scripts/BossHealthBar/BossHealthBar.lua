local CONFIG = require("Scripts\\BossHealthBar\\Config")

Boss = {}
Boss.Int = 0
Boss.BufferLife = 0

BridgeFunctionAttach('OnMonsterDamage','BossOnMonsterDamage')
BridgeFunctionAttach('OnUserDamage','PvpHealthBar')
BridgeFunctionAttach('OnMonsterDie','KilBoss')


function KilBoss(aIndex, bIndex)
	-- ### Argument information: ###
	-- aIndex = Monster index (victim).
	-- bIndex = User index (killer).

	-- ### Bridge information: ###
	-- Called after a monster dies.
    
    local MonsterID = GetObjectClass(aIndex)

    for _, boss in pairs(CONFIG.Boss) do
        if MonsterID == boss.ID then
            Boss.BufferLife = 0
        end
    end

end


function BossOnMonsterDamage(player,monster,damage,skill,combo,flag)

    if CONFIG.Enable == 0 then return end

    
    PacketSend(player,monster,damage,skill,combo,flag, 0)

return 0

end


function PvpHealthBar(player,monster,damage,skill,combo,flag)

    if CONFIG.Enable == 0 then return end

    PacketSend(player,monster,damage,skill,combo,flag, 1)

return 0

end

function PacketSend(player,monster,damage,skill,combo,flag, AttackType)

    local PlayerName = GetObjectName(player)

    local MonsterID = GetObjectClass(monster)

    local MonsterName
    local MonsterNameLen

    local MonsterHP = GetObjectLife(monster)
    local MonsterMaxHP = GetObjectMaxLife(monster)+GetObjectAddLife(monster)
    local HPRate = math.floor((MonsterHP / MonsterMaxHP) * 100)
    
    local packetInformation = string.format("%s-%s", PlayerName, CONFIG.PACKET)


    if AttackType == 0 then

 

        for _, boss in pairs(CONFIG.Boss) do
            if MonsterID == boss.ID then


                if  (Boss.BufferLife/100) > 50 then
                    Boss.BufferLife = 50*100
                end

                Boss.BufferLife = Boss.BufferLife + 1

                if boss.Debuff == 1 then
                    EffectAdd(player,0,76,10,math.floor(Boss.BufferLife/100),math.floor(Boss.BufferLife/100),math.floor(Boss.BufferLife/100),math.floor(Boss.BufferLife/100))
                    EffectAdd(player,0,77,10,math.floor(Boss.BufferLife/100),math.floor(Boss.BufferLife/100),math.floor(Boss.BufferLife/100),math.floor(Boss.BufferLife/100))
                end
                
                MonsterName = boss.FullName
                MonsterNameLen = MonsterName:len()

                CreatePacket(packetInformation, CONFIG.PACKET)
                SetBytePacket(packetInformation, MonsterNameLen)
                SetCharPacketLength(packetInformation, MonsterName, MonsterNameLen)
        	    SetDwordPacket(packetInformation, MonsterHP)
                SetDwordPacket(packetInformation, MonsterMaxHP)
                SetBytePacket(packetInformation, HPRate)
                SetDwordPacket(packetInformation, damage)
                SendPacket(packetInformation,player)
        	    ClearPacket(packetInformation)
            end    
        end

    else
        MonsterName = GetObjectName(monster)
        MonsterNameLen = MonsterName:len()

        CreatePacket(packetInformation, CONFIG.PACKET)
        SetBytePacket(packetInformation, MonsterNameLen)
        SetCharPacketLength(packetInformation, MonsterName, MonsterNameLen)
    	SetDwordPacket(packetInformation, MonsterHP)
        SetDwordPacket(packetInformation, MonsterMaxHP)
        SetBytePacket(packetInformation, HPRate)
        SetDwordPacket(packetInformation, damage)
        SendPacket(packetInformation,player)
    	ClearPacket(packetInformation)
    end

end
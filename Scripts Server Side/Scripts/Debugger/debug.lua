local CONFIG = require("Scripts\\Debugger\\Config")



debug = {}


function debug.Check()
    if CONFIG.Enable ~= 1 then return end

    for i = GetMinUserIndex(), GetMaxUserIndex() do
        if GetObjectConnected(i) == 3 then
            local AccountID = GetObjectAccount(i)
            local Get = GetExpRate(i)
            LogColor(4, 'Index: ' .. i .. ' Exp Final = '.. GetExpRate(i))
        end
    end
end


Timer.Interval(5, debug.Check)
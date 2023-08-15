local util = {}

function util.timeNow()
    local millisecondsPart = math.floor((os.clock() - math.floor(os.clock())) * 1000)
    local now = os.time() * 1000 + millisecondsPart
    
    return now
end

function util.tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function util.removeByKey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

function util.isColliding(a, b, _a, _b) 
    return a:getUserData() == _a and b:getUserData() == _b or a:getUserData() == _b and b:getUserData() == _a
end

return util
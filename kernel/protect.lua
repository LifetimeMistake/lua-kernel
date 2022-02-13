local protect = {}

-- Creates an unprivileged Lua environment
-- Inherits functions from a given parent context
protect.createUnprivilegedContext = function(parent_env)
    local env = {
        assert = parent_env.assert,
        error = parent_env.error,
        ipairs = parent_env.ipairs,
        next = parent_env.next,
        pairs = parent_env.pairs,
        select = parent_env.select,
        xpcall = parent_env.xpcall,
        pcall = parent_env.pcall,
        tonumber = parent_env.tonumber,
        tostring = parent_env.tostring,
        type = parent_env.type,
        unpack = parent_env.unpack,
        getmetatable = parent_env.getmetatable,
        setmetatable = parent_env.setmetatable,
        string = { byte = parent_env.string.byte, char = parent_env.string.char, find = parent_env.string.find, 
            format = parent_env.string.format, gmatch = parent_env.string.gmatch, gsub = parent_env.string.gsub, 
            len = parent_env.string.len, lower = parent_env.string.lower, match = parent_env.string.match, 
            rep = parent_env.string.rep, reverse = parent_env.string.reverse, sub = parent_env.string.sub, 
            upper = parent_env.string.upper },
        table = { insert = parent_env.table.insert, maxn = parent_env.table.maxn, remove = parent_env.table.remove, 
            sort = parent_env.table.sort },
        math = { abs = parent_env.math.abs, acos = parent_env.math.acos, asin = parent_env.math.asin, 
            atan = parent_env.math.atan, atan2 = parent_env.math.atan2, ceil = parent_env.math.ceil, cos = parent_env.math.cos, 
            cosh = parent_env.math.cosh, deg = parent_env.math.deg, exp = parent_env.math.exp, floor = parent_env.math.floor, 
            fmod = parent_env.math.fmod, frexp = parent_env.math.frexp, huge = parent_env.math.huge, 
            ldexp = parent_env.math.ldexp, log = parent_env.math.log, log10 = parent_env.math.log10, max = parent_env.math.max, 
            min = parent_env.math.min, modf = parent_env.math.modf, pi = parent_env.math.pi, pow = parent_env.math.pow, 
            rad = parent_env.math.rad, random = parent_env.math.random, sin = parent_env.math.sin, sinh = parent_env.math.sinh, 
            sqrt = parent_env.math.sqrt, tan = parent_env.math.tan, tanh = parent_env.math.tanh }
    }

    return env
end

-- Creates a privileged Lua environment
-- Inherits functions from a given parent context
-- The child context can be only as privileged as the parent context
protect.createPrivilegedContext = function(parent_env)
    local env = protect.createUnprivilegedContext(parent_env)
    env.rawget = parent_env.rawget
    env.rawset = parent_env.rawset
    env.rawequal = parent_env.rawequal
    env.getfenv = parent_env.getfenv
    env.setfenv = parent_env.setfenv
    env.load = parent_env.load
    env.loadstring = parent_env.loadstring
    return env
end

-- Executes a given function within the specified context
-- Note: This function can only be ran from a privileged context
-- Returns a success boolean + target return values/error handler return values
protect.executeSandbox = function(func, context, ...)
    if type(func) ~= "function" or type(context) ~= "table" then
        error("Invalid arguments")
    end

    if type(setfenv) ~= "function" or type(pcall) ~= "function" then
        error("The current execution context had insufficient privileges")
    end

    setfenv(func, context)
    local result = {pcall(func, ...)}
    return table.unpack(result)
end

-- Executes a given string within the specified context
-- Note: This funtion can only be ran from a privileged context
-- Returns a success boolean + target return values/error handler return values
protect.loadstringSandbox = function(string, context)
    if type(string) ~= "string" or type(context) ~= "table" then
        error("Invalid arguments")
    end

    if type(loadstring) ~= "function" or type(assert) ~= "function" then
        error("The current execution context had insufficient privileges")
    end

    local func = assert(loadstring(string), "Failed to compile string")
    return protect.executeSandbox(func, context)
end

-- Protect tables from unprivilagd edition
protect.setreadonly = function(table)
    if type(table) ~= "table" then
        error("Invalid arguments")
    end

    if type(setmetatable) ~= "function" then
        error("The current execution context had insufficient privileges")
    end

    local _table = {}
    local mt = {
        __index = function(t,k)
            return table[k]
        end,
        __newindex = function(t,k,v)
            error("Cannot write to a protected table")
        end,
        __metatable = "protected"
    }

    setmetatable(_table, mt)
    return _table
end

return protect
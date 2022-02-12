local fslib = {}
local kernel = nil
local separtor = "/"
-- for tests, if final version fslib will be implemented into vfs.
local function readFile(file)
        local file = fs.open(file, "r")
        local string = file.readAll()
        file.close()
        return string
    end
    
    local function loadKernelAPI(file)
        local string = readFile(file)
        return assert(loadstring(string))()
    end

kernel.assert = loadKernelAPI("kernel/assert.lua")
-- end


-- fuck regex, rework later
local function split (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
    end

fslib.intake = function (path)
        if string.sub(path, 1,1 ) ~= separtor then
                return false
        end

        split(path,separtor)
end

--that was for rework purposes
--[[
local function printt(table)
        for k,v in ipairs(table) do
                print(k,v)
        end 
end

local input = tostring(io.read())

local split_table = split(input, "/")
]]
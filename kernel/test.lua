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

local protect = loadKernelAPI("kernel/protect.lua")
local assert = loadKernelAPI("kernel/assert.lua")
local modulemanager = loadKernelAPI("kernel/modules/modulemanager.lua")
local devicemanager = loadKernelAPI("kernel/devices/devicemanager.lua")
local moduleString = readFile("kernel/modules/char/dummy.lua")

local function printLoadedModules()
    for k,v in pairs(modulemanager.getLoadedModuleNames()) do
        print(k,v)
    end
end
--[[
print("Protect namespace:")
for k,v in pairs(protect) do
    print(k,v)
end

print("Module Manager namespace:")
for k,v in pairs(modulemanager) do
    print(k,v)
end
]]--

-- Global kernel struct
local kernel = {
    protect = protect,
    assert = assert,
    modulemanager = modulemanager,
    devicemanager = devicemanager
}
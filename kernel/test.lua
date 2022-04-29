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
--local moduleString = readFile("kernel/modules/char/dummy.lua")
local vfs = loadKernelAPI("kernel/vfs.lua")
local pathlib = loadKernelAPI("kernel/pathlib.lua")


--[[
local function printLoadedModules()
    for k, v in pairs(modulemanager.getLoadedModuleNames()) do print(k, v) end
end

--
print("Protect namespace:")
for k,v in pairs(protect) do
    print(k,v)
end
--
print("Module vfs namespace:")
for k,v in pairs(vfs) do
    print(k,v)
end
print("Module pathlib namespace:")
for k,v in pairs(pathlib) do
    print(k,v)
end
--]]
-- Global kernel struct

local kernel = {
    protect = protect,
    assert = assert,
    modulemanager = modulemanager,
    devicemanager = devicemanager,
    vfs = vfs,
    pathlib = pathlib
}

-- bootstrap basicaly

vfs.create(kernel)
devicemanager.create(kernel)
modulemanager.create(kernel)

-- test space
local lol = nil
lol = pathlib.subractPath("/dev/sdb/a","/dev/sdb")

print(lol)
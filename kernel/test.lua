local function readFile(file)
---@diagnostic disable-next-line: undefined-global
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
local vfs = loadKernelAPI("kernel/vfs.lua")
local pathlib = loadKernelAPI("kernel/pathlib.lua")


local moduleDummy1 = loadKernelAPI("kernel/modules/char/dummy1.lua")
local moduleDummy2 = loadKernelAPI("kernel/modules/char/dummy2.lua")


local function printLoadedModules()
    print("Loaded modules:")
    for k, v in pairs(modulemanager.getLoadedModuleNames()) do print(k, v) end
end

--[[
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
]]

-- Global kernel struct

local kernel = {
    protect = protect,
    assert = assert,
    modulemanager = modulemanager,
    devicemanager = devicemanager,
    vfs = vfs,
    pathlib = pathlib
}

-- bootstrap basicaly.
local bootstrap = function()
    vfs.create(kernel)
    devicemanager.create(kernel)
    modulemanager.create(kernel)
end
-- bootstrap, literally.
bootstrap()

-- test space

local privilaged = protect.createPrivilegedContext(_G)
local unprivilaged = protect.createUnprivilegedContext(_G)

modulemanager.loadModule(moduleDummy1, unprivilaged)
modulemanager.loadModule(moduleDummy2, privilaged)

print("dummy test:", modulemanager.getModule("dummy1"))
print("dummy test:", modulemanager.getModule("dummy2"))

printLoadedModules()

local dummy2 = modulemanager.getModule("dummy2")
local dummy1 = modulemanager.getModule("dummy1")

print(dummy2.descriptor.name)
print(dummy1.descriptor.name)

local lol = pathlib.subractPath("/dev/sdb/a", "/dev")
print("\n", lol)
print("\n mounttest: \n")
local i = 0
while i < 5 do
    local s_mountpoint = "/root/" .. tostring(i)
    vfs.createMountpoint(s_mountpoint, "someNode")
    local mountpoint = vfs.getMountpointFromMountPath(s_mountpoint)
    --print("Mountpoint:", mountpoint)
    local s_string = "/dev/sdb/" .. tostring(i)
    --print("string:",s_string)
    vfs.createFileDescriptor(s_string, 0, false, s_mountpoint) 
    print(vfs.fileDescriptorInUse(s_string), s_string, s_mountpoint, mountpoint.path, mountpoint.deviceNode)
    i = i + 1
end
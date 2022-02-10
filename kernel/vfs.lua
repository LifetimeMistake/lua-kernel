local kernel = nil
local vfs = {}
vfs.nodes = {}
vfs.mountpoints = {}

vfs.getNode = function(path)
    
end

vfs.getPathInfo = function(path)

end

vfs.createNode = function(path, mode, device_majorNumber, device_minorNumber)
    kernel.assert.type(path, "string", "Invalid arguments")
    kernel.assert.type(mode, "number", "Invalid arguments")
    kernel.assert.type(device_majorNumber, "number", "Invalid arguments")
    kernel.assert.type(device_minorNumber, "number", "Invalid arguments")

    
end

vfs.deleteNode = function(path)

end

vfs.create = function(kernel_ref)
    if type(kernel_ref) ~= "table" then
        error("Bad kernel root reference")
    end

    if type(kernel_ref.devicemanager) ~= "table" then
        error("Dependencies not met, missing devicemanager")
    end
end
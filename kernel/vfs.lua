local kernel = nil
local vfs = {}
vfs.nodes = {}           -- path
vfs.fileDescriptors = {} -- id
vfs.mountpoints = {}     -- for later 
vfs.fileModes = {
    READONLY = 0,
    WRITEONLY = 1,
    READWRITE = 2
}
vfs.nodeTypes = {
    CHARACTER = 0,
    FILESYSTEM  = 1
}

vfs.getNode = function(path)
    kernel.assert.type(path, "string", "Invalid arguments")
    if vfs.nodes[path] ~= nil then
        return vfs.nodes[path]
    end
    error("Node not found")
end

vfs.isFileInUse = function (path)
    for _,v in pairs(vfs.fileDescriptors) do
        if v.path == path then
            return true
        end
    end

    return false
end

-- Expect to hate me cause this thing is pain
vfs.isFileLocked = function (path)
    for _,v in pairs(vfs.fileDescriptors) do
        if path == v.path then 
            if v.exclusive then
                return true
            end
        end
    end

    return false
end

--[[ 
rember to add later.
vfs.getPathInfo = function(path)

end
]]

-- path = file |
-- mode = vfs.fileModes |
-- exclusive = bool
vfs.createFileDescriptor = function (path, mode, exclusive)
    kernel.assert.type(path, "string", "Invalid arguments")
    kernel.assert.type(mode, "number", "Invalid arguments")
    kernel.assert.type(exclusive, "boolean", "Invalid arguments")

    -- checking if acces mode exists, remember, check everything!
    local mode_exists = false
    for _,v in pairs(vfs.fileModes) do
        if mode == v then
            mode_exists = true
            break
        end
    end
    if not mode_exists then
        error("Invalid file descriptor mode")
    end
    
    -- if needed, make some type of algorithm to find free spaces, problems my occur for larger amounts of open files.
    local id = 0
    local loop = true
    while loop do
        id = id + 1
        if vfs.fileDescriptors[id] == nil then 
            loop = false
        end
    end

    local fileDescriptor = {
        id = id,
        path = path,
        mode = mode,
        exclusive = exclusive
    }

    vfs.fileDescriptors[id] = fileDescriptor
end

-- type c - character | type fs - filesystem | Path - String | DMJN, DMIN - int
vfs.createNode = function(path, type, device_majorNumber, device_minorNumber)
    kernel.assert.type(path, "string", "Invalid arguments")
    kernel.assert.type(type, "number", "Invalid arguments")
    kernel.assert.type(device_majorNumber, "number", "Invalid arguments")
    kernel.assert.type(device_minorNumber, "number", "Invalid arguments")

    local node_type_exists = false
    for _,v in pairs(vfs.nodeTypes) do
        if type == v then
            node_type_exists = true
            break
        end
    end
    if not node_type_exists then
        error("Invalid node type")
    end

    if vfs.fileExists(path) then
        error("File already exists")
    end

    local node = {
        path = path,
        type = type,
        majorNumber = device_majorNumber,
        minorNumber = device_minorNumber
    }

    vfs.nodes[path] = node
end

-- If file exists and is not in use we dispose of it by changing it to nil.
vfs.deleteNode = function(path)
    kernel.assert.type(path, "string", "Invalid arguments")

    if not vfs.fileExists(path) then 
        error("File does not exist")
    end

    -- need to check descriptor in case of open file !

    if vfs.isFileInUse(path) then
        error("File is currently in use")
    end

    vfs.nodes[path] = nil

end

vfs.deleteDescriptor = function (id)
    kernel.assert.type(id, "number", "Invalid arguments")
    vfs.fileDescriptors[id] = nil
end

vfs.fileExists = function(path)
    kernel.assert.type(path, "string", "Invalid arguments")

    return vfs.nodes[path] ~= nil
end

vfs.create = function(kernel_ref)
    if type(kernel_ref) ~= "table" then
        error("Bad kernel root reference")
    end

    if type(kernel_ref.devicemanager) ~= "table" then
        error("Dependencies not met, missing devicemanager")
    end

    if type(kernel_ref.assert) ~= "table" then
        error("Dependencies not met, missing assert")
    end

    kernel = kernel_ref
end

return vfs
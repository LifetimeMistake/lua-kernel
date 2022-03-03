local kernel = nil
local pathlib = nil

local vfs = {}
vfs.nodes = {}           -- path
vfs.fileDescriptors = {} -- id
vfs.mountpoints = {}
vfs.openModes = {
    READONLY = 0,
    WRITEONLY = 1,
    READWRITE = 2
}
vfs.nodeTypes = {
    FILE = 0,
    DIRECTORY = 1,
    CHARACTER_DEVICE = 2,
    FILESYSTEM_DEVICE  = 3
}
vfs.deviceTypes = {
    CHARACTER_DEVICE = vfs.nodeTypes.CHARACTER_DEVICE,
    FILESYSTEM_DEVICE = vfs.nodeTypes.FILESYSTEM_DEVICE
}
vfs.fsEntryTypes = {
    FILE = vfs.nodeTypes.FILE,
    DIRECTORY = vfs.nodeTypes.DIRECTORY
}

-- High level functions

vfs.open = function(path, mode, exclusive)

end

vfs.read = function(fd, count, offset)

end

vfs.write = function(fd, data, count, offset)

end

vfs.flush = function(fd)

end

vfs.release = function(fd)

end

vfs.getEntryInfo = function(path)

end

vfs.delete = function(path)

end

-- Middle level functions

-- File descriptor functionality

vfs.getNextFreeDescriptorId = function()
    local free_fd = 0
    while vfs.fileDescriptors[free_fd] ~= nil do
        free_fd = free_fd + 1
    end

    return free_fd
end

vfs.createFileDescriptor = function(path, mode, exclusive, mountpoint)
    if not vfs.openModeValid(mode) then
        error("Invalid file descriptor mode")
    end

    if exclusive then
        if vfs.fileDescriptorInUse(path) then
            error("Cannot obtain exclusive lock, file is being held open by another descriptor")
        end
    end

    if vfs.fileDescriptorExclusiveExists(path) then
        error("File is already in use")
    end

    local freeDescriptorId = vfs.getNextFreeDescriptorId()
    local fileDescriptor = {
        id = freeDescriptorId,
        path = path,
        mode = mode,
        exclusive = exclusive,
        mountpoint = mountpoint
    }

    fileDescriptor = kernel.protect.setreadonly(fileDescriptor)
    vfs.fileDescriptors[freeDescriptorId] = fileDescriptor
    return freeDescriptorId
end

vfs.destroyFileDescriptor = function(fd)
    vfs.fileDescriptors[fd] = nil
end

vfs.fileDescriptorInUse = function(path)
    for _,v in pairs(vfs.fileDescriptors) do
        if v.path == path then
            return true
        end
    end

    return false
end

vfs.fileDescriptorExclusiveExists = function(path)
    for _,v in pairs(vfs.fileDescriptors) do
        if v.path == path and v.exclusive then
            return true
        end
    end

    return false
end

vfs.getOpenPathDescriptors = function(path)
    local descriptors = {}
    for _,v in pairs(vfs.fileDescriptors) do
        if v.path == path then
            table.insert(descriptors, v)
        end
    end

    return descriptors
end

-- Device node functionality
vfs.createDeviceNode = function(path, mountpoint, type, device_majorNumber, device_minorNumber)
    if not vfs.deviceNodeTypeValid(type) then
        error("Invalid device type")
    end

    local node = {
        path = path,
        type = type,
        majorNumber = device_majorNumber,
        minorNumber = device_minorNumber,
        mountpoint = mountpoint
    }

    vfs.nodes[path] = node
    return node
end

vfs.getDeviceNode = function(path)
    return vfs.nodes[path]
end

vfs.destroyDeviceNode = function(path)
    vfs.nodes[path] = nil
end

-- Mountpoint functionality
vfs.createMountpoint = function(mountPath, deviceNode, deviceDescriptor, mountPathDescriptor)
    if vfs.mountpoints[mountPath] then
        error("Mountpoint at this location already exists")
    end

    local mountpoint = {
        path = mountPath,
        deviceNode = deviceNode,
        deviceDescriptor = deviceDescriptor, -- Prevents the device node from being modified
        mountPathDescriptor = mountPathDescriptor -- Prevents the parent mountpoint from being removed
    }

    vfs.mountpoints[mountPath] = mountpoint
end

vfs.getMountpointFromMountPath = function(path)
    if not vfs.mountpoints[path] then
        error("Mountpoint does not exist")
    end

    return vfs.mountpoints[path]
end

vfs.getMountpointFromPath = function(path)
    local possibleMountpoints = {}

    for k,v in pairs(vfs.mountpoints) do
        if pathlib.isParentOfPath(k, path) then
            table.insert(possibleMountpoints, v)
        end
    end

    if #possibleMountpoints == 0 then
        error("Path has no known mountpoint")
    end

    -- Sort the mountpoints by their depth
    table.sort(possibleMountpoints, function(mp1, mp2)
        return pathlib.countPathSegments(mp1.path) > pathlib.countPathSegments(mp2.path)
    end)

    return possibleMountpoints[1]
end

vfs.getMountpointByDevice = function(deviceNode)
    for _,v in pairs(vfs.mountpoints) do
        if v.deviceNode == deviceNode then
            return v
        end
    end

    error("Mountpoint does not exist")
end

vfs.mountpointIsInUse = function(mountpoint)
    for k,v in pairs(vfs.fileDescriptors) do
        if v.mountpoint == mountpoint then
            return true
        end
    end

    -- Not sure if we should be checking this or not
    -- This will for example prevent a mountpoint from being removed
    -- as long as ANY node exists on top of it (even when not in use)
    for k,v in pairs(vfs.nodes) do
        if v.mountpoint == mountpoint then
            return true
        end
    end

    return false
end

vfs.destroyMountpoint = function(path)
    local mountpoint = vfs.getMountpointFromMountPath(path)
    if vfs.mountpointIsInUse(mountpoint) then
        error("Mountpoint is in use")
    end

    vfs.release(mountpoint.deviceDescriptor)
    vfs.release(mountpoint.mountPathDescriptor)
    vfs.mountpoints[mountpoint.path] = nil
end

vfs.mountpointExistsByPath = function(path)
    return vfs.mountpoints[path] ~= nil
end

vfs.mountpointExistsByDevice = function(deviceNode)
    for _,v in pairs(vfs.mountpoints) do
        if v.deviceNode == deviceNode then
            return true
        end
    end

    return false
end

-- Filesystem node functionality

vfs.getPhysicalDeviceFromPath = function(path)
    local mountpoint = vfs.getMountpointFromPath(path)
    local deviceNode = mountpoint.deviceNode
    return kernel.devicemanager.getDevice(deviceNode.majorNumber, deviceNode.minorNumber)
end

vfs.createFsEntry = function(path, type)

end

vfs.destroyFsEntry = function(path)

end

-- Utility functions

vfs.openModeValid = function(mode)
    for _,v in pairs(vfs.openModes) do
        if mode == v then
            return true
        end
    end

    return false
end

vfs.deviceNodeTypeValid = function(type)
    for _,v in pairs(vfs.deviceTypes) do
        if type == v then
            return true
        end
    end

    return false
end

vfs.fsEntryNodeTypeValid = function(type)
    for _,v in pairs(vfs.fsEntryTypes) do
        if type == v then
            return true
        end
    end

    return false
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

    if type(kernel_ref.protect) ~= "table" then
        error("Dependencies not met, missing protect")
    end

    if type(kernel_ref.pathlib) ~= "table" then
        error("Dependencies not met, missing pathlib")
    end

    kernel = kernel_ref
    pathlib = kernel_ref.pathlib
end

return vfs
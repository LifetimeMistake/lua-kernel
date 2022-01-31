local kernel = nil
local dm = {}
dm.devices = {}

dm.createDeviceDescriptor = function()
    local device = {
        majorNumber = nil,
        minorNumber = nil,
        name = nil,
        charOperations = nil -- left for visual studio to index
    }

    return device
end

dm.isDeviceRegistered = function(majorNumber, minorNumber)
    kernel.assert.type(majorNumber, "number", "Invalid arguments")
    kernel.assert.type(minorNumber, "number", "Invalid arguments")

    local deviceClass = dm.devices[majorNumber]
    if not deviceClass then
        return false
    end

    if not deviceClass[minorNumber] then
        return false
    end

    return true
end

dm.createDevice = function(deviceStruct)
    kernel.assert.type(deviceStruct, "table", "Invalid arguments")

    kernel.assert.type(deviceStruct.majorNumber, "number", "Bad device struct")
    kernel.assert.type(deviceStruct.minorNumber, "number", "Bad device struct")
    kernel.assert.type(deviceStruct.name, "string", "Bad device struct")

    if #deviceStruct.name == 0 then
        error("Bad device struct")
    end

    if dm.isDeviceRegistered(deviceStruct.majorNumber, deviceStruct.minorNumber) then
        error("Device is already registered")
    end

    local deviceClass = dm.devices[deviceStruct.majorNumber]
    if not deviceClass then
        dm.devices[deviceStruct.majorNumber] = {}
    end

    deviceClass[deviceStruct.minorNumber] = deviceStruct
end

dm.getDevice = function(majorNumber, minorNumber)
    kernel.assert.type(majorNumber, "number", "Invalid arguments")
    kernel.assert.type(minorNumber, "number", "Invalid arguments")

    if not dm.isDeviceRegistered(majorNumber, minorNumber) then
        error("Device is not registered")
    end

    return dm.devices[majorNumber][minorNumber]
end

dm.createCharDevice = function(majorNumber, minorNumber, name)
    local charDevice = dm.createDeviceDescriptor()
    charDevice.majorNumber = majorNumber
    charDevice.minorNumber = minorNumber
    charDevice.name = name

    dm.createDevice(charDevice)

    local charOperations = {
        open = nil,
        read = nil,
        write = nil,
        flush = nil,
        release = nil,
        ioctl = nil
    }

    return charOperations
end

dm.initCharDevice = function(majorNumber, minorNumber, charOperations)
    kernel.assert.type(majorNumber, "number", "Invalid arguments")
    kernel.assert.type(minorNumber, "number", "Invalid arguments")
    kernel.assert.type(charOperations, "table", "Invalid arguments")

    for k,v in pairs(charOperations) do
        kernel.assert.type(v, "function", "Bad char operations table")
    end

    -- A device must implement at least open and release system calls
    kernel.assert.type(charOperations.open, "function", "Bad char operations table")
    kernel.assert.type(charOperations.release, "function", "Bad char operations table")

    local device = dm.getDevice(majorNumber, minorNumber)
    local protect = kernel.protect
    local charOpsProtected = protect.setreadonly(charOperations)
    device.charOperations = charOpsProtected
end

dm.deleteDevice = function(majorNumber, minorNumber)
    kernel.assert.type(majorNumber, "number", "Invalid arguments")
    kernel.assert.type(minorNumber, "number", "Invalid arguments")

    if not dm.getDevice(majorNumber, minorNumber) then
        error("Device is not registered")
    end

    dm.devices[majorNumber][minorNumber] = nil
end

dm.create = function(kernel_ref)
    if type(kernel_ref) ~= "table" then
        error("Bad kernel root reference")
    end

    if type(kernel_ref.protect) ~= "table" then
        error("Dependencies not met, missing protect")
    end

    if type(kernel_ref.assert) ~= "table" then
        error("Dependencies not met, missing assert")
    end

    kernel = kernel_ref
end

return dm
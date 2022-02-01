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

dm.createDevice = function(majorNumber, minorNumber, name)
    kernel.assert.type(majorNumber, "number", "Invalid arguments")
    kernel.assert.type(minorNumber, "number", "Invalid arguments")
    kernel.assert.type(name, "string", "Invalid arguments")

    if #name == 0 then
        error("Invalid arguments")
    end

    if dm.isDeviceRegistered(majorNumber, minorNumber) then
        error("Device is already registered")
    end

    if not dm.devices[majorNumber] then
        dm.devices[majorNumber] = {}
    end

    local deviceStruct = dm.createDeviceDescriptor()
    deviceStruct.majorNumber = majorNumber
    deviceStruct.minorNumber = minorNumber
    deviceStruct.name = name

    dm.devices[majorNumber][minorNumber] = deviceStruct
end

dm.getDevice = function(majorNumber, minorNumber)
    kernel.assert.type(majorNumber, "number", "Invalid arguments")
    kernel.assert.type(minorNumber, "number", "Invalid arguments")

    if not dm.isDeviceRegistered(majorNumber, minorNumber) then
        error("Device is not registered")
    end

    return dm.devices[majorNumber][minorNumber]
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
    device.charOperations = protect.setreadonly(charOperations)
    dm.devices[majorNumber][minorNumber] = protect.setreadonly(device)
end

dm.deleteDevice = function(majorNumber, minorNumber)
    kernel.assert.type(majorNumber, "number", "Invalid arguments")
    kernel.assert.type(minorNumber, "number", "Invalid arguments")

    if not dm.getDevice(majorNumber, minorNumber) then
        error("Device is not registered")
    end

    dm.devices[majorNumber][minorNumber] = nil
end

dm.getDevices = function()
    return dm.devices
end

dm.getDevicesByClass = function(majorNumber)
    kernel.assert.type(majorNumber, "number", "Invalid arguments")
    return dm.devices[majorNumber]
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
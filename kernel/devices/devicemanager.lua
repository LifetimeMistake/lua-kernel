local kernel = nil
local dm = {}
dm.devices = {}

dm.createGenericDeviceStruct = function()
    local device = {
        majorNumber = nil,
        minorNumber = nil,
        name = nil
    }

    return device
end

dm.createCharDeviceStruct = function()
    local charDevice = {
        open = nil,
        read = nil,
        write = nil,
        flush = nil,
        release = nil,
        ioctl = nil
    }

    local device = dm.createGenericDeviceStruct()
    device.charOperations = charDevice

    return device
end

dm.isDeviceRegistered = function(majorNumber, minorNumber)
    if type(majorNumber) ~= "number" or type(minorNumber) ~= "number" then
        error("Invalid arguments")
    end

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
    if type(deviceStruct) ~= "table" then
        error("Invalid arguments")
    end

    if type(deviceStruct.majorNumber) ~= "number" or type(deviceStruct.minorNumber) ~= "number"
    or type(deviceStruct.name) ~= "string" or #deviceStruct.name == 0 then
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

dm.createCharDevice = function(majorNumber, minorNumber, name)
    local charDevice = dm.createCharDeviceStruct()
    charDevice.majorNumber = majorNumber
    charDevice.minorNumber = minorNumber
    charDevice.name = name

    dm.createDevice(charDevice)

    return charDevice.charOperations
end

dm.create = function(kernel_ref)
    if type(kernel_ref) ~= "table" then
        error("Bad kernel root reference")
    end

    kernel = kernel_ref
end

return dm
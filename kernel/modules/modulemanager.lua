local kernel = nil
local mm = {}
mm.loadedModules = {}

mm.createModuleDescriptor = function()
    local descriptor = {
        name = nil,
        description = nil,
        author = nil,
        license = nil,
        init_module = nil,
        destroy_module = nil
    }

    local module = {
        descriptor = descriptor,
        context = nil
    }
    return module
end

mm.loadModule = function(moduleLoader, loaderContext)
    kernel.assert.type(moduleLoader, "table", "Invalid arguments")
    kernel.assert.type(moduleLoader.create, "function", "Bad module loader object")

    if loaderContext then
        kernel.assert.type(loaderContext, "table", "Bad loader context")
    end

    local moduleObject = mm.createModuleDescriptor()
    local protect = kernel.protect
    local context = loaderContext or protect.createUnprivilegedContext(_G)
    local success, errorMessage = protect.executeSandbox(moduleLoader.create, context, moduleObject.descriptor)
    if not success then
        error("Bad kernel module: " .. errorMessage)
    end

    -- Protect the descriptor from tampering
    moduleObject.descriptor = protect.setreadonly(moduleObject.descriptor)

    kernel.assert.type(moduleObject.descriptor.init_module, "function", "Loader specified a bad entry point")
    kernel.assert.type(moduleObject.descriptor.destroy_module, "function", "Loader specified a bad end point")
    kernel.assert.type(moduleObject.descriptor.name, "string", "Loader specified an invalid module name")
    if #moduleObject.descriptor.name == 0 then error("Loader specified an invalid module name") end

    if mm.loadedModules[moduleObject.descriptor.name] then
        error("Module with this name is already loaded")
    end

    -- Proceed to load module
    moduleObject.context = context
    success, errorMessage = protect.executeSandbox(moduleObject.descriptor.init_module, moduleObject.context)
    if not success then
        error("Failed to load module: " .. errorMessage)
    end

    mm.loadedModules[moduleObject.descriptor.name] = moduleObject
    return moduleObject
end

mm.loadstringModule = function(moduleString, moduleContext)
    kernel.assert.type(moduleString, "string", "Invalid arguments")

    if moduleContext then
        kernel.assert.type(moduleContext, "table", "Bad module context")
    end

    local protect = kernel.protect
    local context = moduleContext or protect.createUnprivilegedContext(_G)
    local success, result = protect.loadstringSandbox(moduleString, context)
    if not success then
        error("Failed to extract module loader: " .. result)
    end

    return mm.loadModule(result, context)
end

mm.unloadModule = function(moduleName, force)
    kernel.assert.type(moduleName, "string", "Invalid arguments")
    if #moduleName == 0 then
        error("Invalid arguments")
    end

    if force ~= nil then
        kernel.assert.type(force, "boolean", "Invalid arguments")
    end

    local forceUnload = force or false

    if not mm.loadedModules[moduleName] then
        error("Module is not loaded")
    end
    
    local moduleObject = mm.loadedModules[moduleName]
    local protect = kernel.protect

    local success, errorMessage = protect.executeSandbox(moduleObject.descriptor.destroy_module, moduleObject.context)
    if not success and not forceUnload then
        error("Failed to unload module: " .. errorMessage)
    end

    mm.loadedModules[moduleName] = nil
end

-- Returns module if loaded
mm.getModule = function(moduleName)
    kernel.assert.type(moduleName, "string", "Invalid arguments")
    
    if not mm.loadedModules[moduleName] then
        error("Module is not loaded")
    end

    return mm.loadedModules[moduleName]
end
-- Returns module names in table
mm.getLoadedModuleNames = function()
    local moduleNames = {}
    for k,v in pairs(mm.loadedModules) do
        table.insert(moduleNames, k)
    end

    return moduleNames
end

-- Returns loaded modules
mm.getLoadedModules = function()
    return mm.loadedModules
end

mm.create = function(kernel_ref)
    if type(kernel_ref) ~= "table" then
        error("Bad kernel root reference")
    end

    if type(kernel_ref.protect) ~= "table" then
        error("Dependencies not met, missing protect module")
    end

    if type(kernel_ref.assert) ~= "table" then
        error("Dependencies not met, missing assert")
    end

    kernel = kernel_ref
end

return mm
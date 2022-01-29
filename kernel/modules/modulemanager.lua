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
    if type(moduleLoader) ~= "table" then
        error("Invalid arguments")
    end

    if type(kernel) ~= "table" then
        error("Bad kernel root reference")
    end

    if type(moduleLoader.create) ~= "function" then
        error("Bad module loader object")
    end

    if loaderContext then
        if type(loaderContext) ~= "table" then
            error("Bad loader context")
        end
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

    if type(moduleObject.descriptor.init_module) ~= "function" or type(moduleObject.descriptor.destroy_module) ~= "function" then
        error("Loader specified a bad entry point")
    end

    if type(moduleObject.descriptor.name) ~= "string" or #moduleObject.descriptor.name == 0 then
        error("Loader specified an invalid module name")
    end

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
    if type(moduleString) ~= "string" then
        error("Invalid arguments")
    end

    if type(kernel) ~= "table" then
        error("Bad kernel root reference")
    end

    if moduleContext then
        if type(moduleContext) ~= "table" then
            error("Bad module context")
        end
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
    if type(moduleName) ~= "string" or #moduleName == 0 then
        error("Invalid arguments")
    end

    if force ~= nil then
        if type(force) ~= "boolean" then
            error("Invalid arguments")
        end
    end

    local forceUnload = force or false

    if type(kernel) ~= "table" then
        error("Bad kernel root reference")
    end

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

mm.getLoadedModuleNames = function()
    local moduleNames = {}
    for k,v in pairs(mm.loadedModules) do
        table.insert(moduleNames, k)
    end

    return moduleNames
end

mm.create = function(kernel_ref)
    if type(kernel_ref) ~= "table" then
        error("Bad kernel root reference")
    end

    if type(kernel_ref.protect) ~= "table" then
        error("Dependencies not met, missing protect module")
    end

    kernel = kernel_ref
end

return mm
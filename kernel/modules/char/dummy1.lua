-- Function called on module load
local function init_module()
    
end

-- Function called on module unload
local function destroy_module()
    
end

-- Table containing the module's description
local loader = {}
loader.create = function(descriptor)
    descriptor.name = "dummy1"
    descriptor.description = "Kernel prints on load and unload"
    descriptor.init_module = init_module
    descriptor.destroy_module = destroy_module
    descriptor.math = function(x, y)
        
    end
end

return loader
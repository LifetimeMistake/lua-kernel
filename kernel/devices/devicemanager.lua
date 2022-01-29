local kernel = nil
local dm = {}
dm.devices = {}

dm.create = function(kernel_ref)
    if type(kernel_ref) ~= "table" then
        error("Bad kernel root reference")
    end

    if type(kernel_ref.protect) ~= "table" then
        error("Dependencies not met, missing protect module")
    end

    kernel = kernel_ref
end

return dm
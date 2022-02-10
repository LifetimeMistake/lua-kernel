local assert = {}

assert.type = function(object, objectType, errorMessage)
    if type(errorMessage) ~= "string" then
        error("Invalid arguments")
    end
    
    if type(object) ~= objectType then
        error(errorMessage)
    end

    return type(object)
end

assert.dependency = function(object, dependency)
    if type(object) ~= "table" or type(dependency) ~= "string" then
        error("Invalid arguments")
    end

    local res = object[dependency]
    if not res then
        error("Dependencies not met, missing " .. dependency)
    end

    return res
end

return assert
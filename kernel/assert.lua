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

return assert
local pathlib = {}

pathlib.hasDirectoryEnd = function(path)
    return (string.find(path, "[\\/]$")) ~= nil
end

pathlib.removeDirectoryEnd = function(path)
    return (string.gsub(path, "[\\/]+$", ""))
end

pathlib.ensureDirectoryEnd = function(path)
    return pathlib.removeDirectoryEnd(path) .. "/"
end

pathlib.splitLastPathSegment = function(path)
    return string.match(path, "^(.-)[\\/]?([^\\/]*)$")
end

pathlib.splitPath = function(path)
    local segments = {}
    for segment in string.gmatch(path, "([^\\/]+)") do
        table.insert(segments, segment)
    end

    return segments
end

pathlib.isParentOfPath = function(parent, path)
    return string.sub(path, 1, string.len(parent)) == parent
end

pathlib.countPathSegments = function(path)
    return #pathlib.splitPath(path)
end

pathlib.hasRoot = function(path)
    return string.sub(path, 1, 1) == "/"
end

pathlib.getBaseName = function(path)
    local s1, s2 = pathlib.splitLastPathSegment(path)
    return s2
end

pathlib.getParentDirectoryName = function(path)
    return (pathlib.splitLastPathSegment(path))
end

return pathlib
local pathlib = {}

-- self-explanatory
pathlib.hasDirectoryEnd = function(path)
    return (string.find(path, "[\\/]$")) ~= nil
end

-- self-explanatory
pathlib.removeDirectoryEnd = function(path)
    return (string.gsub(path, "[\\/]+$", ""))
end

-- self-explanatory
pathlib.ensureDirectoryEnd = function(path)
    return pathlib.removeDirectoryEnd(path) .. "/"
end

pathlib.splitLastPathSegment = function(path)
    return string.match(path, "^(.-)[\\/]?([^\\/]*)$")
end

-- Splits path using "regex", returns table with no "/"
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

-- self-explanatory, returns number
pathlib.countPathSegments = function(path)
    return #pathlib.splitPath(path)
end

-- Subtracts sub_path form base_path by replacing base_path with nothing.
pathlib.subractPath = function(base_path, sub_path)
    sub_path = pathlib.removeDirectoryEnd(sub_path)
    return string.gsub(base_path, sub_path, "")
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
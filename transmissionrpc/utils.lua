-- @module transmissionrpc.utils
local utils = {}

function utils.nice_bytes(bytes)
    if (bytes > 1024*1024) then
        return string.format("%.2fM", bytes/(1024*1024))
    elseif (bytes > 1024) then
        return string.format("%.1fk", bytes/1024)
    else 
        return string.format("%d", bytes)
    end
end

function utils.nice_speed(bps)
    return string.format("%sB/s", nice_bytes(bps))
end

return utils

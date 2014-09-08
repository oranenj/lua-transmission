local http = require 'socket.http'
local json = require 'json'
local ltn12 = require 'ltn12'

HOST="transmission"
PROTOCOL="http"
PORT=9091
URL=string.format("%s://%s:%s/transmission/rpc", PROTOCOL, HOST, PORT)

RPC_VERSION=1

CSRF_HEADER = 'X-Transmission-Session-Id'

DEBUG=1

function try_request(jsonbody, tries, csrf_header)
    csrf_header = csrf_header or "Invalid"
    local result = {}
    if (tries == 0) then
        error("Try count exceeded")
    end
	local body, code, headers, status = http.request {
        method = 'POST',
        url = URL,
        source = ltn12.source.string(jsonbody),
        sink = ltn12.sink.table(result),
        headers = { [CSRF_HEADER] = csrf_header,
                    ['Accept'] = '*/*',
                    ['Accept-Encoding'] = '',
                    ['Content-Length'] = string.len(jsonbody)
        }
    }
    if (code == 409) then -- wrong session id
        csrf_header = headers[CSRF_HEADER:lower()]
        return try_request(jsonbody, tries-1, csrf_header)
    elseif (code == 200) then
        return table.concat(result)
    else
        error(string.format("Unknown error: %s", status))
    end
end

    



function rpccall(method, arguments, tag)
    local jsonobj = {
        method = method,
        arguments = arguments or {},
        tag = tag,
    }
    local body = json.encode(jsonobj)
    return try_request(body, 3, "")
end

function main()
    local stats = rpccall("session-stats")
    local o = json.decode(stats)
    local a = o.arguments
    print("Active / Paused / Total")
    print(string.format("%6s   %6s   %5s", a.activeTorrentCount, a.pausedTorrentCount, a.torrentCount))
end

function nice_bytes(bytes)
    if (bytes > 1024*1024) then
        return string.format("%.2fM", bytes/(1024*1024))
    elseif (bytes > 1024) then
        return string.format("%.1fk", bytes/1024)
    else 
        return string.format("%d", bytes)
    end
end

function print_speed(bps)
    print(string.format("%sB/s", nice_bytes(bps))) 
end
 
main()

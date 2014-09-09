--- Transmission RPC client
-- @module transmissionrpc.client
local client = {}
local http = require 'socket.http'
local json = require 'json'
local ltn12 = require 'ltn12'

-- class table
local RPCClient = {}

client.RPC_VERSION=1
client.CSRF_HEADER = 'X-Transmission-Session-Id'

-- @local
function client.try_request(c, jsonbody, tries)
    local result = {}
    if (tries == 0) then
        error("Try count exceeded")
    end
	local body, code, headers, status = http.request {
        method = 'POST',
        url = c.URL,
        source = ltn12.source.string(jsonbody),
        sink = ltn12.sink.table(result),
        headers = { [client.CSRF_HEADER] = c.CSRF,
                    ['Accept'] = '*/*',
                    ['Accept-Encoding'] = '',
                    ['Content-Length'] = string.len(jsonbody)
        }
    }
    if (code == 409) then -- wrong session id
        c.CSRF = headers[client.CSRF_HEADER:lower()]
        return client.try_request(c, jsonbody, tries-1)
    elseif (code == 200) then
        return table.concat(result)
    else
        error(string.format("Unknown error: %s", status))
    end
end

--- RPCClient constructor
-- @param host RPC endpoint host
-- @param port RPC endpoint port    
function client.new(host, port)
    local self = {}
    self.URL = string.format("%s://%s:%s/transmission/rpc", "http", host, port)
    self.CSRF = ""
    setmetatable(self, { __index = RPCClient})
    return self
end 

--- Perform an RPC call using the client
-- @param method RPC method, as a string eg. "torrent-get"
-- @param arguments optional table of arguments, isomorphic to the JSON request
-- @param tag optional integer tag. Will be returned as is in the response
-- @return a table isomorphic to the JSON response of the RPC call
function RPCClient:rpccall(method, arguments, tag)
    local jsonobj = {
        method = method,
        arguments = arguments or {},
        tag = tag,
    }
    local body = json.encode(jsonobj)
    res = client.try_request(self, body, 3)
    return json.decode(res)
end

return client

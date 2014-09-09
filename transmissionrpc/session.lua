-- @module transmissionrpc.session
local session = {}
local Session = {}

function session.new(client)
    local self = {}
    setmetatable(self, { __index = Session })
    self.client = client
    self.torrents = {}
    self.change_notifications = {
        status = {}
    }
    return self
end

function Session:register_notification(name, func)
    table.insert(self.change_notifications[name], func)
end

function Session:update_stats()
    local stats = self.client:rpccall("session-stats")
    self.stats = stats.arguments
end

function Session:update_torrent_status(ids)
    local res = self.client:rpccall("torrent-get", {ids = ids, fields = {"status", "isFinished"}})
    local ti = res.arguments.torrents
    for id, torrent in pairs(self.torrents) do
        if ti[id] == nil then
            self.torrents[id] = nil
        elseif ti[id].status ~= torrent.status then
            Session:notify_change("torrent-status", torrent, ti)
            self.torrents.id.status = ti.status
        end
    end
    for id, torrent in pairs(ti) do
        if self.torrents[id] == nil then
            -- new torrent
            self.torrents[id] = torrent
        end
    end
end

function Session:notify_change(attribute, old, new)
    for f in self.change_notifications[attribute] do
        f(old, new)
    end
end

return session

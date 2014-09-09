--- Transmission RPC module
-- @module transmissionrpc

local client = require 'transmissionrpc.client'
local session = require 'transmissionrpc.session'
local utils = require 'transmissionrpc.utils'

local transmissionrpc = {}

transmissionrpc.client = client
transmissionrpc.utils = utils
transmissionrpc.session = session

return transmissionrpc

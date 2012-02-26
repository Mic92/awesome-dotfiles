--[[
My first try of the BSD License
Copyright 2012 Jörg Thalheim <jthalheim@gmail.com>.
All rights reserved

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE FREEBSD PROJECT ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE FREEBSD PROJECT OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

iwlist.lua: parse iwlist scan results into a table
--------------------------------------------------
Usage:
local device   = "wlan0"
-- wlan0 is the default, if device is empty
local networks = iwlist.scan_networks(device)
-- accesspoints a table of all found access points
-- an example of an access point entry
a_network = {
    essid      = "My Network"        -- the ESSID of the networks
    address    = "00:DE:AD:BE:EF:42" -- the MAC of the network card
    chan       = "2"                 -- the used channel
    quality    = 99.9999             -- the quality in percent
    encryption = true                -- flag, if encryption is used
    wpa        = true                -- flag, if WPA is supported
    wpa2       = true                -- flag, if WPA2 is supported
}
-- to retrieve a human readable string
-- of the used encryption:
encryption = iwlist.get_encryption(ap)

I only test my setup, so it could be not working for yours.
The known encryption are fare from complete...
If something is missing just send me a pull request or a mail
--]]

local io = { popen = io.popen }
module("iwlist")

local function parse_line(line, ap)
    local res, res2
    res = line:match('^%s+ESSID:"([^"]+)"')
    if res then
      ap.essid = res
      return
    end
    res, res2 = line:match('^%s+Quality=(%d+)/(%d+)')
    if res then
      ap.quality = (res / res2) * 100
      return
    end
    res = line:match("^%s+Channel:(%d+)")
    if res then
      ap.chan = res
      return
    end
    res = line:match("^%s+Encryption key:on")
    if res then
      ap.encryption = true
      return
    end
    res = line:find("WPA Version 1")
    if res then
      ap.wpa = true
      return
    end
    res = line:find("WPA2 Version 1")
    if res then
      ap.wpa2 = true
      return
    end
end

function scan_networks(device)
    local device = device or "wlan0"
    local f = io.popen("iwlist '"..device.."' scan")
    local networks = {}
    local ap = {}
    local count = 0
    for l in f:lines() do
        local cell = l:match("^%s+Cell")
        if cell then
            count = count + 1
            networks[count] = ap
            -- init for next ap
            ap = {}
            ap.address = l:match("Address: ([0-9A-F:]+)")
        else
            parse_line(l, ap)
        end
    end
    f:close()

    if count > 0 then
        -- the first field is empty always,
        -- so put the last unsaved network here
        networks[1] = ap
    end

    return networks
end

function get_encryption(ap)
  if not ap.encryption then
    return "open"
  elseif ap.wpa and ap.wpa2 then
    return "WPA*"
  elseif ap.wpa then
    return "WPA"
  elseif ap.wpa2 then
    return "WPA2"
  else
    return "N/A"
  end
end


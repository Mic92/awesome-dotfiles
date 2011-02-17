-- useful markup functions for awesome
-- found somewhere (wiki maybe?) modularized and current:
-- by bioe007 perrydothargraveatgmaildotcom
local beautiful = require("beautiful")
local tonumber = tonumber
local string_format = string.format
-- Markup helper functions
module("markup")

function bg(color, text)
    if color ~= nil then
        return '<span bgcolor="'..color..'" >'..(text or "")..'</span>'
    else
        return text
    end
end
 
function fg(color, text)
    if color ~= nil then
        return '<span color="'..color..'">'..(text or "")..'</span>'
    else
        return text
    end
end
 
function font(font, text)
    if color ~= nil then
        return '<span font_desc="'..font..'">'..(text or "")..'</span>'
    else
        return text 
    end
end
 
function normal(t)
    return bg(beautiful.bg_normal, fg(beautiful.fg_normal, t))
end
 
function focus(t)
    return bg(beautiful.bg_focus, fg(beautiful.fg_focus, t))
end
 
function urgent(t)
    return bg(beautiful.bg_urgent, fg(beautiful.fg_urgent, t))
end
 
function bold(text)
    return '<b>'..(text or "")..'</b>'
end

function underline(text)
    return '<u>'..(text or "")..'</u>'
end

function italic(text)
    return '<i>'..(text or "")..'</i>'
end
 
function heading(text)
    return fg(beautiful.fg_focus, bold(text))
end

function gradient(color, to_color, min, max, value)
    local function color2dec(c)
        return tonumber(c:sub(2,3),16), tonumber(c:sub(4,5),16), tonumber(c:sub(6,7),16)
    end

    local factor = 0
    if (value >= max ) then 
        factor = 1  
    elseif (value > min ) then 
        factor = (value - min) / (max - min)
    end 

    local red, green, blue = color2dec(color) 
    local to_red, to_green, to_blue = color2dec(to_color) 

    red   = red   + (factor * (to_red   - red))
    green = green + (factor * (to_green - green))
    blue  = blue  + (factor * (to_blue  - blue))

    -- dec2color
    return string_format("#%02x%02x%02x", red, green, blue)
end
 
-- vim:set filetype=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --

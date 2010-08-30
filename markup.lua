-- useful markup functions for awesome
-- found somewhere (wiki maybe?) modularized and current:
-- by bioe007 perrydothargraveatgmaildotcom
local beautiful = require("beautiful")
 
-- Markup helper functions
module("markup")
 
function bg(color, text)
    if text ~= nil then
        return '<span bgcolor="'..color..'" >'..text..'</span>'
    else
        return ""
    end
end
 
function fg(color, text)
    if text ~= nil then
        return '<span color="'..color..'">'..text..'</span>'
    else
        return ""
    end
end
 
function font(font, text)
    if text ~= nil then
        return '<span font_desc="'..font..'">'..text..'</span>'
    else
        return ""
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
    return '<b>'..text or ""..'</b>'
end

function underline(text)
    return '<u>'..text or ""..'</u>'
end

function italic(text)
    return '<i>'..text or ""..'<i>'
end
 
function heading(text)
    return fg(beautiful.fg_focus, bold(text))
end
 
-- vim:set filetype=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --

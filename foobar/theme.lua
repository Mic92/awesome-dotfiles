--[[
foobar is derived from foo, a high contrast awesome3 theme, by rob
changeset compared to the origin:
    - default sans font
    - archlinux blue and a decent white as focus colors
    - wider menu (just my personal preference)
--]]

--{{{ Main
local awful = require("awful")

theme = {}

themedir = debug.getinfo(1).source
themedir = themedir:sub(2,#themedir - #("/theme.lua"))
local awesome_dir = "/usr/share/awesome"
-- compatibility with nixos
if awful.util.file_readable("/run/current-system/sw/bin/awesome") then
    awesome_dir = awful.util.pread([[echo -n $(dirname "$(readlink -f /run/current-system/sw/bin/awesome)")/../share/awesome/]])
end
--}}}

theme.font    = "Inconsolata Nerd Font Mono 14"

theme.bg_normal     = "#333333"
theme.bg_focus      = "#1793d1"
theme.bg_urgent     = "#00ff00"
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#999999"
theme.fg_focus      = "#fafafa"
theme.fg_urgent     = "#111111"
theme.fg_minimize   = "#ffffff"

theme.border_width  = 2
theme.border_normal = "#333333"
theme.border_focus  = "#1793d1"
theme.border_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
theme.taglist_squares_sel         = themedir .. "/taglist_sel.png"
theme.taglist_squares_unsel       = themedir .. "/taglist_unsel.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = "share/awesome/themes/default/submenu.png"
theme.menu_height = 15
theme.menu_width  = 130

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = awesome_dir .. "themes/default/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = awesome_dir .. "themes/default/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = awesome_dir .. "themes/default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = awesome_dir .. "themes/default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active   = awesome_dir .. "themes/default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active    = awesome_dir .. "themes/default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = awesome_dir .. "themes/default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = awesome_dir .. "themes/default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active   = awesome_dir .. "themes/default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active    = awesome_dir .. "themes/default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = awesome_dir .. "themes/default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = awesome_dir .. "themes/default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active   = awesome_dir .. "themes/default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active    = awesome_dir .. "themes/default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = awesome_dir .. "themes/default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = awesome_dir .. "themes/default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active   = awesome_dir .. "themes/default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active    = awesome_dir .. "themes/default/titlebar/maximized_focus_active.png"

theme.wallpaper = themedir .. "/background.png"

-- You can use your own layout icons like this:
theme.layout_fairh      = awesome_dir .. "themes/default/layouts/fairhw.png"
theme.layout_fairv      = awesome_dir .. "themes/default/layouts/fairvw.png"
theme.layout_floating   = awesome_dir .. "themes/default/layouts/floatingw.png"
theme.layout_magnifier  = awesome_dir .. "themes/default/layouts/magnifierw.png"
theme.layout_max        = awesome_dir .. "themes/default/layouts/maxw.png"
theme.layout_fullscreen = awesome_dir .. "themes/default/layouts/fullscreenw.png"
theme.layout_tilebottom = awesome_dir .. "themes/default/layouts/tilebottomw.png"
theme.layout_tileleft   = awesome_dir .. "themes/default/layouts/tileleftw.png"
theme.layout_tile       = awesome_dir .. "themes/default/layouts/tilew.png"
theme.layout_tiletop    = awesome_dir .. "themes/default/layouts/tiletopw.png"
theme.layout_spiral     = awesome_dir .. "themes/default/layouts/spiralw.png"
theme.layout_dwindle    = awesome_dir .. "themes/default/layouts/dwindlew.png"

theme.awesome_icon      = awesome_dir .. "icons/awesome16.png"

-- Define the icon theme for application icons. If not set then the icons
-- from share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80

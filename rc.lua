--[[
awesome.lua - main config of my window manager
awesome v3.5.4 (Brown Paper Bag)
os: archlinux x86_64
cpu: Intel(R) Core(TM) i5-4200U CPU @ 1.60GHz
grapic:  Intel Graphics 4400
screen: 1920 x 1080
--]]

-- {{{ Awesome Library
print("[awesome] Entered awesome.lua: "..os.date())

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local tyrannical = require("tyrannical")
-- widget library
local vicious = require("vicious")
vicious.contrib = require("vicious.contrib")
--local lognotify = require("lognotify")
-- calendar widget
local cal    = require("utils.cal")
-- wrapper for pango markup
local markup = require("utils.markup")
-- scan for wlan accesspoints using iwlist
local iwlist = require("utils.iwlist")
-- MPD widget based on mpd.lua
local wimpd  = require("utils.wimpd")
local mpc = wimpd.new()

-- enable luajit
pcall(function() jit.on() end)
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
--local theme_path = "/usr/share/awesome/themes/default/theme.lua"
--local theme_path = "/usr/share/awesome/themes/sky/theme.lua"
local theme_path = awful.util.getdir("config").."/foobar/theme.lua"

beautiful.init(theme_path)

-- Use normal colors instead of focus colors for tooltips
beautiful.tooltip_bg_color = beautiful.bg_normal
beautiful.tooltip_fg_color = beautiful.fg_normal

-- This is used later as the default terminal and editor to run.
local spawn_with_systemd = function(app)
  return "systemd-run --user --unit '"..app.."' '"..app.."'"
end
local terminal   = os.getenv("TERMINAL") or "urxvt"
local editor     = os.getenv("EDITOR") or "vim"
local browser    = os.getenv("BROWSER") or "chromium"
local mail       = "thunderbird"
local editor_cmd = terminal.." -e "..editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey    = "Mod4"
local modkey2   = "Mod1"
local icon_path = awful.util.getdir("config").."/icons/"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  awful.layout.suit.tile,               -- 1
  awful.layout.suit.tile.left,          -- 2
  awful.layout.suit.tile.bottom,        -- 3
  awful.layout.suit.tile.top,           -- 4
  --awful.layout.suit.fair,
  --awful.layout.suit.fair.horizontal,
  --awful.layout.suit.spiral,
  --awful.layout.suit.spiral.dwindle,
  awful.layout.suit.floating,           -- 5
  awful.layout.suit.max,                -- 7
  awful.layout.suit.max.fullscreen,     -- 8
  --awful.layout.suit.magnifier,
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Shifty configuration
-- tag settings
-- the exclusive in each definition seems to be overhead, but it prevent new on-the-fly tags to be exclusive
-- the follow function make it easier to swap tags

tyrannical.tags = {
  {
    name = "1:web",
    position = 1,
    init = true,
    exclusive = true,
    screen = 1,
    layout = awful.layout.suit.tile,
    exec_once = { "systemctl --user start "..browser },
    class = { "Firefox", "Opera", "Chromium", "Aurora", "birdie",
      "Thunderbird", "evolution" },
  },
  {
    name = "2:dev",
    position = 2,
    exclusive = true,
    init = true,
    screen = 1,
    layout = awful.layout.suit.tile,
    exec_once = { spawn_with_systemd(terminal) },
    class       = {
      "xterm" , "urxvt" , "aterm", "URxvt", "XTerm"
    },
    match       = {
      "konsole"
    }
  },
  {
    name = "3:im",
    position = 3,
    exclusive = true,
    mwfact = 0.25,
    init = true,
    layout = awful.layout.suit.tile,
    exec_once = { spawn_with_systemd("pidgin") },
    class = { "Kopete", "Pidgin", "gajim" }
  },
  {
    name = "4:doc",
    position = 4,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.max,
    class = { "Evince", "GVim", "keepassx", "libreoffice" }
  },
  {
    name = "5:java",
    position = 5,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.tile,
    class = { "Eclipse", "NetBeans IDE", "jetbrains%-idea%-ce" }
  },
  {
    name = "d:own",
    position = 6,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.tile,
    class = { "gpodder", "JDownloader", "Transmission" }
  },
  {
    name = "s:kype",
    position = 7,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.tile,
    exec_once = { spawn_with_systemd("pcmanfm") },
    class = { "skype" }
  },
  {
    name = "p:cfm",
    position = 7,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.tile,
    exec_once = { spawn_with_systemd("pcmanfm") },
    class = { "pcmanfm", "dolphin", "nautilus", "thunar" }
  },
  {
    name = "e:macs",
    position = 8,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.tile,
    exec_once = { spawn_with_systemd("emacs") },
    class = { "emacs" }
  },
  {
    name = "a:rio",
    position = 9,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.max,
    class = { "sonata", "Goggles Music"},
    match = { "ncmpcpp" }
  },
  {
    name = "v:ideo",
    position = 10,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.max                          ,
    class = { "MPlayer", "VLC", "Smplayer" }
  },
  {
    name = "w:ine",
    position = 11,
    exclusive = true,
    init = false,
    layout = awful.layout.suit.tile,
    class = { "Wine" }
  },
}

tyrannical.properties.intrusive = {
  "gmrun", "qalculate", "gnome-calculator", "Komprimieren", "Wicd", "Valauncher"
}

tyrannical.properties.ontop = {
  "gmrun", "qalculate", "gnome-calculator", "Komprimieren", "Wicd", "Valauncher", "MPlayer", "pinentry"
}

tyrannical.properties.floating = {
  "MPlayer", "pinentry"
}

full_screen_apps = {"Firefox", "Opera", "Chromium", "Aurora", "Thunderbird", "evolution"}

tyrannical.properties.maximized_horizontal = full_screen_apps
tyrannical.properties.maximized_vertical = full_screen_apps

tyrannical.properties.size_hints_honor = {
  xterm = false, URxvt = false, aterm = false
}

--}}}

-- {{{ Menu
-- Create a laucher widget and a main menu
local myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/awesome.lua" },
   { "powersafe off", "xset s off" },
   { "xrandr", "xrandr --auto" },
   { "arandr", "arandr" },
   { "restart", awesome.restart },
   { "quit",  awesome.quit }
}

local mymainmenu = awful.menu({ items = {
  { "awesome", myawesomemenu, beautiful.awesome_icon },
  { "open terminal", terminal },
  { "Firefox", spawn_with_systemd("firefox") },
  { "Bildschirmsperre", "slimlock" },
  { "Schlaf", "systemctl suspend" },
  { "Ruhezustand", "systemctl hibernate" },
  { "Neustarten", "systemctl reboot", icon_path.."restart.png" },
  { "Herunterfahren", "systemctl poweroff", icon_path.."poweroff.png" },
}})

local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
menu = mymainmenu })
-- }}}

-- {{{ Naughty log notify
print("[awesome] Enable naughty log notify")
--ilog = lognotify{
--   logs = {
--      mpd = { file = os.getenv("HOME").."/.mpd/log", ignore = {"player_thread: played"} },
--      pacman = { file = "/var/log/pacman.log", },
--      kernel = { file = "/var/log/kernel.log", ignore = {"Mark"} },
--      awesome = { file = awful.util.getdir("config").."/log", ignore = {"[awesome]"} },
--   },
--   interval = 1,
--   naughty_timeout = 15
--}
--ilog:start()
-- }}}

-- Transparent notifications
naughty.config.presets.normal.opacity = 0.8
naughty.config.presets.low.opacity = 0.8
naughty.config.presets.critical.opacity = 0.8

-- {{{ Vicious and MPD
print("[awesome] initialize vicious")

-- {{{ Date and time
-- Create a textclock widget
local mytextclock = awful.widget.textclock()
local clockicon = wibox.widget.imagebox()
clockicon:set_image(icon_path.."clock.png")
-- Register calendar tooltip
-- To use fg_focus, you have to set a different tooltip_fg_color since the
-- default is already beautiful.fg_focus.
-- (beautiful.bg_normal in my case)
cal.register(clockicon, markup.fg(beautiful.fg_focus,"<b>%s</b>"))
local uptimetooltip = awful.tooltip({})
uptimetooltip:add_to_object(mytextclock)
mytextclock:connect_signal("mouse::enter",  function()
  local args = vicious.widgets.uptime()
  local text = (" <b>Uptime</b> %dd %dh %dmin "):format(args[1], args[2], args[3])
  uptimetooltip:set_markup(text)
end)
-- }}}

local testwidget = wibox.widget.textbox()

-- {{{ Battery
local batwidget = wibox.widget.textbox()
local baticon   = wibox.widget.imagebox()
baticon:set_image(icon_path.."bat.png")
local batbar    = awful.widget.progressbar()
local batbox    = wibox.layout.margin(batbar, 2, 2, 4, 4)

-- Progressbar properties
batbar:set_width(8)
batbar:set_height(10)
batbar:set_ticks(true)
batbar:set_height(1)
batbar:set_ticks_size(2)
batbar:set_vertical(true)
batbar:set_background_color(beautiful.fg_off_widget)
batbar:set_color(beautiful.fg_widget)
batbar:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 30 },
     stops = { { 0, "#AECF96" }, { 1, "#FF5656" } } })

vicious.cache(vicious.widgets.bat)
vicious.register(batbar, vicious.widgets.bat, "$2", 7, "BAT1")
vicious.register(batwidget, vicious.widgets.bat, "$1$2% $3h", 7, "BAT1")
-- }}}

--{{{ Pulseaudio
local pulseicon = wibox.widget.imagebox()
pulseicon:set_image(icon_path.."volume.png")
-- Initialize widgets
local pulsewidget = wibox.widget.textbox()
local pulsebar    = awful.widget.progressbar()
local pulsebox    = wibox.layout.margin(pulsebar, 2, 2, 4, 4)

-- Progressbar properties
pulsebar:set_width(8)
pulsebar:set_height(10)
pulsebar:set_ticks(true)
pulsebar:set_ticks_size(2)
pulsebar:set_vertical(true)
pulsebar:set_background_color(beautiful.fg_off_widget)
pulsebar:set_color(beautiful.fg_widget)
-- Bar from green to red
pulsebar:set_color({ type = "linear", from = { 0, 0 }, to = { 0, 30 },
     stops = { { 0, "#AECF96" }, { 1, "#FF5656" } } })

-- Enable caching
vicious.cache(vicious.contrib.pulse)

local function pulse_volume(delta)
  vicious.contrib.pulse.add(delta, "alsa_output.pci-0000_00_1b.0.analog-stereo")
vicious.force({ pulsewidget, pulsebar})
end

local function pulse_toggle()
vicious.contrib.pulse.toggle("alsa_output.pci-0000_00_1b.0.analog-stereo")
vicious.force({ pulsewidget, pulsebar})
end

vicious.register(pulsebar, vicious.contrib.pulse, "$1",  7)
vicious.register(pulsewidget, vicious.contrib.pulse,
function (widget, args)
 return string.format("%.f%%", args[1])
end, 7)

pulsewidget:buttons(awful.util.table.join(
awful.button({ }, 1, function () awful.util.spawn("pavucontrol") end), --left click
awful.button({ }, 2,
function () pulse_toggle() end),
awful.button({ }, 4, -- scroll up
 function () pulse_volume(5)  end),
awful.button({ }, 5, -- scroll down
 function () pulse_volume(-5) end)))
pulsebar:buttons( pulsewidget:buttons() )
pulseicon:buttons( pulsewidget:buttons() )
--}}}

-- {{{ CPU usage
local cpuwidget = wibox.widget.textbox()
local cpuicon = wibox.widget.imagebox()
cpuicon:set_image(icon_path.."cpu.png")
-- Initialize widgets
vicious.register(cpuwidget, vicious.widgets.cpu,
function (widget, args)
local text
-- list all cpu cores
for i=1,#args do
  -- alerts, if system is stressed
  --args[i] = markup.fg(markup.gradient(1,100,args[i]),args[i])
  if args[i] > 90 then
    args[i] = markup.fg("#FF5656", args[i]) -- light red
  elseif args[i] > 70 then
    args[i] = markup.fg("#AECF96", args[i]) -- light green
  end

  -- append to list
  if i > 2 then text = text.."/"..args[i].."%"
  else text = args[i].."%" end
end
return text
end, 7)
-- Register buttons
cpuwidget:buttons( awful.button({ }, 1, function () awful.util.spawn(terminal .. " -e htop") end) )
cpuicon:buttons( cpuwidget:buttons() )

-- }}}

-- {{{ CPU temperature
local thermalwidget = wibox.widget.textbox()
local thermalicon = wibox.widget.imagebox()
thermalicon:set_image(icon_path.."temp.png")
vicious.register(thermalwidget, vicious.widgets.thermal, "$1°C", 7, {"thermal_zone0", "sys"})
-- }}}

-- {{{ Memory usage
-- Initialize widget
local memwidget = wibox.widget.textbox()
local memicon = wibox.widget.imagebox()
memicon:set_image(icon_path.."mem.png")
vicious.register(memwidget, vicious.widgets.mem, "$2MB/$3MB ", 7)
-- Register buttons
memwidget:buttons( cpuwidget:buttons() )
memicon:buttons( cpuwidget:buttons() )
-- }}}

-- {{{ Net usage
local netwidget = wibox.widget.textbox()
local neticon  = wibox.widget.imagebox()
neticon:set_image(icon_path.."netio.png")
vicious.register(netwidget, vicious.widgets.net,
function (widget, args)
 local down, up
 if args["{enp0s25 down_kb}"] ~= "0.0" or args["{enp0s25 up_kb}"] ~= "0.0" then
    down, up = args["{enp0s25 down_kb}"], args["{enp0s25 up_kb}"]
 elseif args["{wlp3s0 down_kb}"] ~= "0.0" or args["{wlp3s0 up_kb}"] ~= "0.0" then
    down, up = args["{wlp3s0 down_kb}"], args["{wlp3s0 up_kb}"]
 else
   neticon.visible = false
   return ""
 end
 neticon.visible = true
 return string.format("%skb/%skb", up, down)
end, 7)
-- Register buttons
netwidget:buttons( awful.button({ }, 1, function () awful.util.spawn(terminal .. " -e sudo nethogs -d 2 -p wlp3s0") end) )
neticon:buttons( netwidget:buttons() )
-- }}}

-- {{{ Disk I/O
local ioicon = wibox.widget.imagebox()
ioicon:set_image(icon_path.."disk.png")
ioicon.visible = true
local iowidget = wibox.widget.textbox()
vicious.register(iowidget, vicious.widgets.dio, "SSD ${sda read_mb}/${sda write_mb}MB", 7)
-- Register buttons
iowidget:buttons( awful.button({ }, 1, function () awful.util.spawn(terminal .. " -e sudo iotop") end) )
-- }}}

--{{{ Pacman
local pkgwidget = wibox.widget.textbox()
local pkgicon = wibox.widget.imagebox()
pkgicon:set_image(icon_path.."pacman.png")
-- Don't show icon by default
pkgicon.visible = false

-- Use a cronjob to update the packagelist http://bbs.archlinux.org/viewtopic.php?id=84115
vicious.register(pkgwidget, vicious.widgets.pkg,
function(widget, args)
 -- Check wheter pacman db is locked. Don't use aweful.util.file_readable,
 -- because the db.lck isn't readable at all.
 local db_locked = os.execute("[[ -f /var/lib/pacman/db.lck ]] && exit 1 || exit 0")
 -- Don't disturb me, unless enough updates are collect and pacman doesn't run
 if args[1] < 8 or db_locked ~= 0 then
    -- If you use powerpill, it is important to check wheter it runs!
    pkgicon.visible = false
    return ""
 else
    pkgicon.visible = true
    return markup.urgent("<b>Updates</b> "..args[1]).." "
 end
end, 180, "Arch")

pkgwidget:buttons( awful.button({ }, 1,
function ()
 pkgwidget.visible, pkgicon.visible = false, false
 -- URxvt specific
 awful.util.spawn(terminal.." -title 'Yaourt Upgrade' -e zsh -c 'yaourt -Syu --aur'")
end))
pkgicon:buttons( pkgwidget:buttons() )
--}}}

-- {{{ MPD
local wimpc = wibox.widget.textbox()
local mpcicon = wibox.widget.imagebox()
mpcicon:set_image(icon_path.."music.png")
mpc.attach(wimpc)

-- Register Buttons in both widget
mpcicon:buttons( wimpc:buttons(awful.util.table.join(
awful.button({ }, 1, function () mpc:toggle_play() mpc:update()      end), -- left click
awful.button({ }, 2, function () awful.util.spawn("sonata")          end), -- middle click
awful.button({ }, 3, function () awful.util.spawn("urxvt -e ncmpcpp")end), -- right click
awful.button({ }, 4, function () mpc:seek(5) mpc:update()            end), -- scroll up
awful.button({ }, 5, function () mpc:seek(-5) mpc:update()           end)  -- scroll down
)))
-- }}}

--{{{ Wifi
local wifiwidget = wibox.widget.textbox()
local wifiicon   = wibox.widget.imagebox()
local wifitooltip= awful.tooltip({})
wifitooltip:add_to_object(wifiwidget)
wifiicon:set_image(icon_path.."wifi.png")
vicious.register(wifiwidget, vicious.widgets.wifi, function(widget, args)
local tooltip = ("<b>mode</b> %s <b>chan</b> %s <b>rate</b> %s Mb/s"):format(
                args["{mode}"], args["{chan}"], args["{rate}"])
local quality = 0
if args["{linp}"] > 0 then
  quality = args["{link}"] / args["{linp}"] * 100
end
wifitooltip:set_text(tooltip)
return ("%s: %.1f%%"):format(args["{ssid}"], quality)
end, 5, "wlp3s0")
wifiicon:buttons( wifiwidget:buttons(awful.util.table.join(
awful.button({}, 1, function()
local networks = iwlist.scan_networks("wlp3s0")
if #networks > 0 then
  local msg = {}
  for i, ap in ipairs(networks) do
    local line = "<b>ESSID:</b> %s <b>MAC:</b> %s <b>Qual.:</b> %.2f%% <b>%s</b>"
    local enc = iwlist.get_encryption(ap)
    msg[i] = line:format(ap.essid, ap.address, ap.quality, enc)
  end
  naughty.notify({text = table.concat(msg, "\n")})
else
end
end),
awful.button({ "Shift" }, 1, function ()
-- restart-auto-wireless is just a script of mine,
-- which just restart netcfg
local wpa_cmd = "sudo restart-auto-wireless && notify-send 'wpa_actiond' 'restarted' || notify-send 'wpa_actiond' 'error on restart'"
awful.util.spawn_with_shell(wpa_cmd)
end), -- left click
awful.button({ }, 3, function ()  vicious.force{wifiwidget} end) -- right click
)))
--}}}
-- }}}

-- {{{ Wibox
print("[awesome] initialize wibox")

-- Create a wibox for each screen and add it
local mywibox = {}
local mystatusbox = {}
local mypromptbox = {}
local mylayoutbox = {}
local mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
local mytasklist = {}
mytasklist.buttons = awful.util.table.join(
   awful.button({ }, 1,
     function (c)
       if c == client.focus then
         c.minimized = true
       else
         -- Without this, the following
         -- :isvisible() makes no sense
         c.minimized = false
         if not c:isvisible() then
           awful.tag.viewonly(c:tags()[1])
         end
         -- This will also un-minimize
         -- the client, if needed
         client.focus = c
         c:raise()
       end
     end),
   awful.button({ }, 3,
     function ()
       if instance then
         instance:hide()
         instance = nil
       else
         instance = awful.menu.clients({ width=250 })
       end
     end),
   awful.button({ }, 4,
     function ()
       awful.client.focus.byidx(1)
       if client.focus then client.focus:raise() end
     end),
   awful.button({ }, 5,
     function ()
       awful.client.focus.byidx(-1)
       if client.focus then client.focus:raise() end
     end))

for s = 1, screen.count() do
  -- Create a promptbox for each screen
  mypromptbox[s] = awful.widget.prompt()
  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
       awful.button({ }, 1, function () awful.layout.inc(1) end),
       awful.button({ }, 3, function () awful.layout.inc(-1) end),
       awful.button({ }, 4, function () awful.layout.inc(1) end),
       awful.button({ }, 5, function () awful.layout.inc(-1) end)))
  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
  -- Create the wibox
  mywibox[s] = awful.wibox({ position = "top", screen = s })

  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(mylauncher)
  left_layout:add(mytaglist[s])
  left_layout:add(mypromptbox[s])

  local right_layout = wibox.layout.fixed.horizontal()
  if s == 1 then right_layout:add(wibox.widget.systray()) end
  right_layout:add(wifiicon)
  right_layout:add(wifiwidget)
  right_layout:add(baticon)
  right_layout:add(batwidget)
  right_layout:add(batbox)
  right_layout:add(pulseicon)
  right_layout:add(pulsewidget)
  right_layout:add(pulsebox)
  right_layout:add(clockicon)
  right_layout:add(mytextclock)
  right_layout:add(mylayoutbox[s])

  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(mytasklist[s])
  layout:set_right(right_layout)

  mywibox[s]:set_widget(layout)

  mystatusbox[s] = awful.wibox({ position = "bottom", screen = s })
  local left_layout2 = wibox.layout.fixed.horizontal()

  left_layout2:add(testwidget)

  left_layout2:add(cpuicon)
  left_layout2:add(cpuwidget)
  left_layout2:add(thermalicon)
  left_layout2:add(thermalwidget)
  left_layout2:add(memicon)
  left_layout2:add(memwidget)
  left_layout2:add(ioicon)
  left_layout2:add(iowidget)
  left_layout2:add(neticon)
  left_layout2:add(netwidget)

  local right_layout2 = wibox.layout.fixed.horizontal()
  right_layout2:add(mpcicon)
  right_layout2:add(wimpc)
  right_layout2:add(pkgicon)
  right_layout2:add(pkgwidget)

  local layout2 = wibox.layout.align.horizontal()
  layout2:set_left(left_layout2)
  layout2:set_right(right_layout2)

  mystatusbox[s]:set_widget(layout2)


end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

local function random_string(len)
  local res = {}
  for i=1, len do
    -- from range a-z
    res[i] = string.char(math.random(97, 122))
  end
  return table.concat(res)
end

-- {{{ Key bindings
local globalkeys = awful.util.table.join(
  awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
  awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
  awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

  awful.key({ modkey,           }, "j",
      function ()
         awful.client.focus.byidx( 1)
         if client.focus then client.focus:raise() end
      end),
  awful.key({ modkey,           }, "k",
      function ()
         awful.client.focus.byidx(-1)
         if client.focus then client.focus:raise() end
      end),
  -- awful.key({ modkey,           }, "w",       function() mymainmenu:show()        end),

  -- Layout manipulation
  awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
  awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
  awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
  awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
  awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
  awful.key({ modkey,           }, "Tab",
     function ()
       awful.client.focus.history.previous()
       if client.focus then
         client.focus:raise()
       end
     end),

  -- move float clients without a mouse
  awful.key({ modkey, modkey2 }, "h", function () awful.client.moveresize(-20, 0, 0, 0) end),
  awful.key({ modkey, modkey2 }, "j", function () awful.client.moveresize(0, 20, 0, 0)  end),
  awful.key({ modkey, modkey2 }, "k", function () awful.client.moveresize(0, -20, 0, 0) end),
  awful.key({ modkey, modkey2 }, "l", function () awful.client.moveresize(20, 0, 0, 0)  end),

  -- Standard program
  awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
  awful.key({ modkey, "Control" }, "r", awesome.restart),
  awful.key({ modkey, "Shift"   }, "q", awesome.quit),
  -- lockscreen
  awful.key({ modkey, "Shift"   }, "s", function () awful.util.spawn("slimlock") end),

  awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
  awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
  awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
  awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
  awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
  awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
  awful.key({ modkey,           }, "space", function () awful.layout.inc(1) end),
  awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1) end),
  awful.key({ modkey, "Control" }, "n", awful.client.restore),
  --}}

  -- {{{ Custom Bindings
  -- mpd control
  awful.key({ "Shift" }, "space", function () mpc:toggle_play() mpc:update() end),
  -- Smplayer/Gnome mplayer control
  awful.key({ modkey2 }, "space", function ()
    local result = os.execute("smplayer -send-action play_or_pause") -- return 0 on succes
    if result ~= 0 then
      awful.util.spawn("dbus-send / com.gnome.mplayer.Play") -- if state is play it pause
    end
  end),
  awful.key({ }, "XF86AudioPlay", function () mpc:toggle_play() mpc:update() end),
  awful.key({ }, "XF86AudioNext", function () mpc:next()        mpc:update() end),
  awful.key({ }, "XF86AudioPrev", function () mpc:previous()    mpc:update() end),

  -- use a systemd.path to automatically upload this image to my server and copy
  -- the public link to clipboard
  awful.key({modkey }, "Print", function ()
    awful.util.spawn("scrot '%Y-%m-%d."..random_string(5)..".png' --exec 'eog \"$f\"; mv \"$f\" /home/joerg/Bilder'")
  end),
  awful.key({modkey, "Shift" }, "Print", false, function ()
    awful.util.spawn("scrot '%Y-%m-%d."..random_string(5)..".png' --select --exec 'eog \"$f\"; mv \"$f\" /home/joerg/Bilder'")
  end),

  awful.key({ }, "XF86Display", function()
    -- switch between external and internal display
    -- source: https://wiki.archlinux.org/index.php/Xrandr#Scripts
    os.execute('bash -c \'xrandr --output eDP1 --mode "1400x1050"; sleep 1; xrandr --output eDP1 --mode "1920x1080"\'')
  end),

  -- Volume keyboard control
  awful.key({ }, "XF86AudioRaiseVolume", function () pulse_volume(5) end),
  awful.key({ }, "XF86AudioLowerVolume", function () pulse_volume(-5)end),
  awful.key({ }, "XF86AudioMute",        function () pulse_toggle()  end),

  -- Calculator
  awful.key({ modkey }, "c", function () awful.util.spawn("gnome-calculator") end),
  awful.key({ modkey, "Control" }, "c", function () awful.util.spawn("qalculate-gtk") end),
  -- }}}

  -- Prompt
  --awful.key({ modkey }, "r",     function () mypromptbox[mouse.screen]:run() end),
  awful.key({ modkey }, "r", function () awful.util.spawn("valauncher") end),
  --  awful.key({ modkey }, "s", function () menubar.show() end),
  awful.key({ modkey }, "x",
    function ()
      awful.prompt.run({ prompt = "Run Lua code: " },
      mypromptbox[mouse.screen].widget,
      awful.util.eval, nil,
      awful.util.getdir("cache") .. "/history_eval")
    end)
  -- Menubar
  --awful.key({ modkey }, "p", function() menubar.show() end)
  )

local clientkeys = awful.util.table.join(
   awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
   awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
   awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
   awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
   awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
   awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
   awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
   awful.key({ modkey,           }, "n",
     function (c)
       -- The client currently has the input focus so it cannot be
       -- minimized, since minimizec clients can't have the focus.
       c.minimized = true
     end),
   awful.key({ modkey,           }, "m",
     function (c)
       c.maximized_horizontal = not c.maximized_horizontal
       c.maximized_vertical   = not c.maximized_vertical
     end))


-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                    if client.focus then
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if tag then
                        awful.client.movetotag(tag)
                      end
                    end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                    if client.focus then
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if tag then
                        awful.client.toggletag(tag)
                      end
                    end
                  end))
end


clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule       = { class = "Gajim.py" },
       callback   = awful.client.setslave },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    if not awesome.startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

-- Enable sloppy focus
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Timer
-- }}}

-- {{{ Welcome Message
print("[awesome] Send welcome message")

naughty.notify{
  title = "Awesome "..awesome.version.." started!",
  text  = string.format("Welcome %s. Your host is %s.\nIt is %s",
  os.getenv("USER"), awful.util.pread("hostname"):match("[^\n]*"), os.date()),
  timeout = 7 }
-- }}}

-- Java helper
awful.util.spawn("wmname LG3D")
--vicious.suspend()
--vicious.activate(batwidget)
--vicious.activate(batbar)
--vicious.activate(wifiwidget)

-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=2:tabstop=2:softtabstop=2:textwidth=80

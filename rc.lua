--[[
awesome.lua - main config of my window manager
awesome v3.4.10 (Exploder)
 • Build: Jun 11 2011 11:14:53 for i686 by gcc version 4.6.0 (arch@m50vn)
 • D-Bus support: ✔
os: archlinux i686
cpu: Intel Pentium Dual CPU E2180 2.00GHz
grapic: Mesa DRI Intel G33 GEM
screen: [1] 1900x1080
--]]

-- {{{ Awesome Library
print("[awesome] Entered awesome.lua: "..os.date())

require("awful")
require("awful.autofocus")
--require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- dynamic tagging library
require("shifty")
-- widget library
require("vicious")
require("cal")
require("lognotify")
-- required for run once
require("lfs")
-- little helper
require("markup")
-- MPD library
require("mpd"); mpc = mpd.new()
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")
--beautiful.init("/usr/share/awesome/themes/sky/theme.lua")
--beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

-- Use normal colors instead of focus colors for tooltips
beautiful.tooltip_bg_color = beautiful.bg_normal
beautiful.tooltip_fg_color = beautiful.fg_normal

-- This is used later as the default terminal and editor to run.
local terminal   = os.getenv("TERMINAL") or "xterm"
local editor     = os.getenv("EDITOR") or "nano"
local browser    = os.getenv("BROWSER") or "firefox"
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
local layouts =
{
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

-- {{{ Run programm once - the fast way
local function processwalker()
   local function yieldprocess()
      for dir in lfs.dir("/proc") do
	-- All directories in /proc containing a number, represent a process
	if tonumber(dir) ~= nil then
	  local f, err = io.open("/proc/"..dir.."/cmdline")
	  if f then
	    local cmdline = f:read("*all")
	    f:close()
	    if cmdline ~= "" then
	      coroutine.yield(cmdline)
	    end
	  end
	end
      end
    end
    return coroutine.wrap(yieldprocess)
end

local function run_once(process, cmd)
   assert(type(process) == "string")
   local escaped_chars = {
      ["+"]  = "%+", ["-"] = "%-",
      ["*"]  = "%*", ["?"]  = "%?" }

   for p in processwalker() do
      if p:find(process:gsub("[-+?*]", escaped_chars)) then
	 return
      end
   end
   return awful.util.spawn(cmd or process)
end
-- }}}

-- {{{ Shifty configuration
-- tag settings
-- the exclusive in each definition seems to be overhead, but it prevent new on-the-fly tags to be exclusive
-- the follow function make it easier to swap tags

shifty.config.tags = {
   ["1:web"]     = { position = 1, exclusive = true, init = true, nopopup = true,
		     run = function () run_once(browser) end },
   ["2:dev"]     = { position = 2, exclusive = true, spawn = terminal },
   ["3:im"]      = { position = 3, exclusive = true, nopopup = true, spawn = "gajim", mwfact = 0.8, layout = awful.layout.suit.tile.right},
   ["4:doc"]     = { position = 4, exclusive = true },
   ["5:java"]    = { position = 5, exclusive = true },
   ["d:own"]     = { position = 6, exclusive = true },
   ["p:cfm"]     = { position = 7, exclusive = true, spawn = "pcmanfm" },
   ["e:macs"]    = { position = 8, exclusive = true, spawn = "emacs" },
   ["a:rio"]     = { position = 9, exclusive = true, spawn = "sonata" },
   ["s:mplayer"] = { position = 10,exclusive = true, spawn = "smplayer" },
   ["w:ine"]     = { position = 11,exclusive = true},
   ["g:imp"]     = { position = 12,exclusive = true, spawn = "gimp-2.7" },
   ["brasero"]   = { position = 13,exclusive = true},
}

-- client settings
-- order here matters, early rules will be applied first
shifty.config.apps = {
  { match = { "Firefox", "Opera", "chromium", "Aurora",
  "Developer Tools" },                                      tag = "1:web" },
  { match = { "xterm", "urxvt" },                           tag = "2:dev", slave = true, honorsizehints = false },
  { match = { "buddy_list" },                               no_urgent = true},
  { match = { "kopete", "Pidgin", "skype", "gajim" },       tag = "3:im" },
  { match = { "evince", "gvim", "keepassx", "libreoffice" },tag = "4:doc" },
  { match = { "ncmpcpp", "Goggles Music", "sonata" },       tag = "a:rio" },
  { match = { "gpodder", "JDownloader", "Transmission" },   tag = "d:own" },
  { match = { "*mplayer*", "MPlayer" },                     tag = "s:mplayer" },
  { match = { "gimp" },                                     tag = "g:imp" },
  { match = { "pcmanfm", "dolphin", "nautilus" },           tag = "p:cfm", slave = true, nopopup = true, no_urgent = true},
  { match = { "emacs" },                                    tag = "e:macs"},
  { match = { "Wine" },                                     tag = "w:ine" },
  -- For android only ;)
  { match = { "Eclipse", "NetBeans IDE" },                  tag = "5:java" },
  { match = { "gmrun", "qalculate", "gcalctool", "Komprimieren","Wicd*" },
    intrusive = true, ontop = true, above = true, dockable = true },
  -- buttons to resize/move clients
  { match = { "" }, buttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, function (c)
      client.focus = c
      c:raise()
      awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, awful.mouse.client.resize )),
    size_hints_honor = false
  }
}

-- tag defaults
shifty.config.defaults = {
   layout = awful.layout.suit.tile.left,
   ncol = 1,
   mwfact = 0.60,
   floatBars      = true,
   guess_name     = true,
   guess_position = true,
   dockable       = true,
}

shifty.modkey = modkey
shifty.config.sloppy = true
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
local myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/awesome.lua" },
   { "powersafe off", "xset s off" },
   { "xrandr", "xrandr --auto" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

-- reboot/shutdown as user using Consolkit and shutdown/hibernate using upower
-- Make sure you using ck-launch-session to start awesome and you are in the power group.
local upower = [[dbus-send --print-reply \
--system \
--dest=org.freedesktop.UPower \
/org/freedesktop/UPower \
org.freedesktop.UPower.]]
local consolkit = [[dbus-send --print-reply \
--system \
--dest="org.freedesktop.ConsoleKit" \
/org/freedesktop/ConsoleKit/Manager \
org.freedesktop.ConsoleKit.Manager.]]

local mymainmenu = awful.menu({ items = {
				   { "awesome", myawesomemenu, beautiful.awesome_icon },
				   { "open terminal", terminal },
				   { "Firefox", "firefox" },
				   { "gnome-control", "gnome-control-center" },
				   { "Bildschirmsperre", "slimlock" },
				   { "Schlaf", upower.."Suspend" },
				   { "Ruhezustand", upower.."Hibernate" },
				   { "Neustarten", consolkit.."Restart", icon_path.."restart.png" },
				   { "Herunterfahren", consolkit.."Stop", icon_path.."poweroff.png" },
			     }})

local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
					   menu = mymainmenu })
-- }}}

-- {{{ Naughty log notify
print("[awesome] Enable naughty log notify")
ilog = lognotify{
   logs = {
      mpd = { file = os.getenv("HOME").."/.mpd/log", ignore = {"player_thread: played"} },
      pacman = { file = "/var/log/pacman.log", },
      kernel = { file = "/var/log/kernel.log", ignore = {"Mark"} },
      awesome = { file = awful.util.getdir("config").."/log", ignore = {"[awesome]"} },
   },
   interval = 1,
   naughty_timeout = 15
}
ilog:start()
-- }}}

-- {{{ Vicious and MPD
print("[awesome] initialize vicious")

-- {{{ Date and time
-- Create a textclock widget
local mytextclock = awful.widget.textclock({ align = "right" })
local clockicon = widget({ type = "imagebox" })
clockicon.image = image(icon_path.."clock.png")
-- Register calendar tooltip
-- To use fg_focus, you have to set a different tooltip_fg_color since the
-- default is already beautiful.fg_focus.
-- (beautiful.bg_normal in my case)
cal.register(clockicon, markup.fg(beautiful.fg_focus,"<b>%s</b>"))
local uptimetooltip = awful.tooltip({})
uptimetooltip:add_to_object(mytextclock)
mytextclock:add_signal("mouse::enter",  function()
  local args = vicious.widgets.uptime()
  local text = (" <b>Uptime</b> %dd %dh %dmin "):format(args[1], args[2], args[3])
  uptimetooltip:set_text(text)
end)
-- }}}

-- {{{ Battery
local batwidget = widget({ type = "textbox" })
local baticon   = widget({ type = "imagebox"})
baticon.image   = image(icon_path.."bat.png")
local batbar    = awful.widget.progressbar()

-- Progressbar properties
batbar:set_width(8)
batbar:set_height(14)
batbar:set_vertical(true)
batbar:set_background_color(beautiful.fg_off_widget)
batbar:set_color(beautiful.fg_widget)
batbar:set_gradient_colors({ '#FF5656', '#88A175', '#AECF96'})
awful.widget.layout.margins[batbar.widget] = { top = 2, bottom = 2, left = 1, right = 2 }

vicious.cache(vicious.widgets.bat)
vicious.register(batbar, vicious.widgets.bat, "$2",  11, "BAT1")
vicious.register(batwidget, vicious.widgets.bat, "$1$2% $3h", 11, "BAT1")
-- }}}

--{{{ Pulseaudio
local pulseicon = widget({ type = "imagebox" }); pulseicon.image = image(icon_path.."volume.png")
-- Initialize widgets
local pulsewidget = widget({ type = "textbox" })
local pulsebar    = awful.widget.progressbar()

-- Progressbar properties
pulsebar:set_width(8)
pulsebar:set_height(14)
pulsebar:set_vertical(true)
pulsebar:set_background_color(beautiful.fg_off_widget)
pulsebar:set_color(beautiful.fg_widget)
-- Bar from green to red
pulsebar:set_gradient_colors({ '#AECF96', '#88A175', '#FF5656' })
awful.widget.layout.margins[pulsebar.widget] = { top = 2, bottom = 2, left = 2 }
-- Enable caching
vicious.cache(vicious.contrib.pulse)

pulsewidget:add_signal("update", function ()
  vicious.force({ pulsewidget, pulsebar})
end)

local function pulse_volume(delta)
  vicious.contrib.pulse.add(delta)
  pulsewidget:emit_signal("update")
end

local function pulse_toggle()
  vicious.contrib.pulse.toggle(delta)
  pulsewidget:emit_signal("update")
end

vicious.register(pulsebar, vicious.contrib.pulse, "$1",  5)
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
pulsebar.widget:buttons( pulsewidget:buttons() )
pulseicon:buttons( pulsewidget:buttons() )

--}}}

-- {{{ CPU usage and temperature
local cpuwidget = widget({ type = "textbox" })
local cpuicon = widget({ type = "imagebox" }); cpuicon.image = image(icon_path.."cpu.png")
-- Initialize widgets
vicious.register(cpuwidget, vicious.widgets.cpu,
function (widget, args)
   if args[1] > 0 then
      cpuicon.visible = true
      local t
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
	 if i > 2 then t = t.."/"..args[i].."%"
	 else t = args[i].."%" end
      end
      return t
   else
      cpuicon.visible = false
   end
end)
-- Register buttons
cpuwidget:buttons( awful.button({ }, 1, function () awful.util.spawn(terminal .. " -e htop") end) )
cpuicon:buttons( cpuwidget:buttons() )
-- }}}

-- {{{ Memory usage
-- Initialize widget
local memwidget = widget({ type = "textbox" })
local memicon = widget({ type = "imagebox" }); memicon.image = image(icon_path.."mem.png")
vicious.register(memwidget, vicious.widgets.mem, "$2MB/$3MB ", 5)
-- Register buttons
memwidget:buttons( cpuwidget:buttons() )
memicon:buttons( cpuwidget:buttons() )
-- }}}

-- {{{ Net usage
local netwidget = widget({ type = "textbox" })
local neticon  = widget({ type = "imagebox" }); neticon.image = image(icon_path.."netio.png")
vicious.register(netwidget, vicious.widgets.net,
function (widget, args)
   local down, up, text = args["{eth0 down_kb}"], args["{eth0 up_kb}"]
   if down ~= "0.0" or up ~= "0.0" then
      text = ("%skb/%skb"):format(args["{eth0 down_kb}"], args["{eth0 up_kb}"])
   end
   neticon.visible = (text ~= nil)
   return text
end, 5)
-- Register buttons
netwidget:buttons( awful.button({ }, 1, function () awful.util.spawn(terminal .. " -e sudo nethogs -d 2") end) )
neticon:buttons( netwidget:buttons() )
-- }}}

-- {{{ Disk I/O
local ioicon = widget({ type = "imagebox" })
ioicon.image = image(icon_path.."disk.png") ioicon.visible = true
local iowidget = widget({ type = "textbox" })
vicious.register(iowidget, vicious.widgets.dio,
function (widget, args)
   local text = ""
   -- display hdd only, if significant operations take place
   if args["{sda total_mb}"] ~= "0.0" then
      text = ("60GB %s/%sMB "):format(args["{sda read_mb}"], args["{sda write_mb}"])
   end
   if args["{sdb total_mb}"] ~= "0.0" then
      text = text..("140GB %s/%sMB"):format(args["{sdb read_mb}"], args["{sdb write_mb}"])
   end
   ioicon.visible = (text ~= "")
   return text
end, 3)
-- Register buttons
iowidget:buttons( awful.button({ }, 1, function () awful.util.spawn(terminal .. " -e iotop") end) )
-- }}}

--{{{ Pacman
local pkgwidget = widget({ type = "textbox" })
local pkgicon = widget({ type = "imagebox" })
pkgicon.image = image(icon_path.."pacman.png")
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

-- {{{ News: Display new podcasts
local newswidget = widget({ type = "textbox" })
local newsicon = widget({ type = "imagebox" }); newsicon.image = image(icon_path.."feed.png")
-- don't show icon by default
newsicon.visible = false
local lib = os.getenv("HOME").."/music/podcasts/"
vicious.register(newswidget, vicious.contrib.countfiles,
function(widget, args)
   local text = ""
   for key, value in pairs(args) do
      if value > 0 then
	 if value == 1 then
	    text = text..key.." "
	 else
	    text = text..string.format("%s: %d ", key, value)
	 end
      end
   end
   -- toggle icon
   newsicon.visible = (text ~= "")
   return text
end, 180,
{ pattern = ".*.(mp[34]|ogg|m4a)$",
  paths = { Tagess = lib.."Tagesschau",
	    mobileMacs = lib.."mobileMacs",
	    RadioTux = lib.."RadioTux Talk",
	    RadioTux = lib.."RadioTux Binärgewitter",
	    Spasspkt = lib.."WDR 2 Zugabe Spaßpaket",
	    NFSW = lib.."Not Safe For Work",
	    Alternativlos = lib.."Alternativlos"}})

-- Register Buttons in all widget
newswidget:buttons(
   awful.util.table.join(
      awful.button({ }, 1, -- left click -> open podcast client
		   function () awful.util.spawn("gpodder") end),
      awful.button({ }, 3, function () vicious.force({newswidget}) end) -- right click -> update
))
-- }}}

-- {{{ MPD
require("mpc")
local mpc = mpc()
local wimpc = widget({ type = "textbox" })
local mpcicon = widget({ type = "imagebox" })
mpcicon.image = image(icon_path.."music.png")

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

-- }}}

-- {{{ Wibox
-- Create a systray
local mysystray = widget({ type = "systray" })

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
   awful.button({ }, 4, awful.tag.viewnext),
   awful.button({ }, 5, awful.tag.viewprev)
)
local mytasklist = {}
mytasklist.buttons = awful.util.table.join(
   awful.button({ }, 1,
		function (c)
       -- Don't want to minimize with the mouse
		   --if c == client.focus then
		   --   c.minimized = true
		   --else
      if c ~= client.focus then
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
  mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
			 awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
			 awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
			 awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
			 awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(function(c)
					   return awful.widget.tasklist.label.currenttags(c, s)
					end, mytasklist.buttons)

  -- Create the wibox
  mywibox[s] = awful.wibox({ position = "top", screen = s })
  mystatusbox[s] = awful.wibox({ position = "bottom", screen = s })

  -- Add widgets to the wibox - order matters
  mywibox[s].widgets =
     {
    mylauncher,
    mytaglist[s],
    mypromptbox[s],
    {
      mylayoutbox[s],
      mytextclock, clockicon,
      pulsebar.widget, pulsewidget, pulseicon,
      batbar.widget, batwidget, baticon,
      s == 1 and mysystray or nil,
      layout = awful.widget.layout.horizontal.rightleft
    },
    mytasklist[s],
    layout = awful.widget.layout.horizontal.leftright,
    height = mywibox[s].height
  }

  mystatusbox[s].widgets = {
    cpuicon, cpuwidget,
    memicon, memwidget,
    ioicon, iowidget,
    neticon, netwidget,
    {
      pkgwidget, pkgicon,
      wimpc, mpcicon,
      newswidget, newsicon,
      layout = awful.widget.layout.horizontal.rightleft,
    },
    layout = awful.widget.layout.horizontal.leftright,
    height = mystatusbox[s].height
  }

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
		awful.button({ }, 3, function () mymainmenu:toggle() end),
		awful.button({ }, 4, awful.tag.viewnext),
		awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

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
  -- awful.key({ modkey,           }, "w",       function() mymainmenu:show({keygrabber=true})        end),
  awful.key({ modkey, "Shift"   }, "n",       shifty.send_prev),                              -- move client to prev tag
  awful.key({ modkey            }, "n",       shifty.send_next),                              -- move client to next tag
  -- awful.key({ modkey            }, "w",       shifty.del),                                    -- delete a tag
  -- awful.key({ modkey            }, "t",       shifty.add),                                    -- creat a new tag
  -- awful.key({ modkey, "Shift"   }, "t",       function() shifty.add({ nopopup = true }) end), -- nopopup new tag

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
  awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
  awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),


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

  -- Easy way to share Screenshots over dropbox: The following code make a
  -- Screenshot open it with Eye of Gnome, copy it to dropbox and put the
  -- public link into the X-clipboard
  awful.key({ }, "Print", function ()
    awful.util.spawn("scrot -e 'eog $f; mv $f Dropbox/Public;dropbox puburl Dropbox/Public/$f | xclip'")
  end),

  -- Volume keyboard control
  awful.key({ }, "XF86AudioRaiseVolume", function () pulse_volume(5) end),
  awful.key({ }, "XF86AudioLowerVolume", function () pulse_volume(-5)end),
  awful.key({ }, "XF86AudioMute",        function () pulse_toggle()  end),

  -- Calculator
  awful.key({ modkey }, "c", function () awful.util.spawn("gcalctool") end),
  awful.key({ modkey, "Control" }, "c", function () awful.util.spawn("qalculate-gtk") end),
  -- }}}

  -- Prompt
  --awful.key({ modkey }, "r",     function () mypromptbox[mouse.screen]:run() end),
  awful.key({ modkey }, "r",     function () awful.util.spawn("gmrun") end),

  awful.key({ modkey }, "x",
  function ()
    awful.prompt.run({ prompt = "Run Lua code: " },
    mypromptbox[mouse.screen].widget,
    awful.util.eval, nil,
    awful.util.getdir("cache") .. "/history_eval")
  end))


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
local keystore = {
   1, --> web
   2, --> dev
   3, --> im
   4, --> doc
   5, --> java
   "d",  --> down
   "p",  --> pcmanfm
   "e",  --> emacs
   "a",  --> ario
   "s",  --> smplayer
   "w",  --> wine
   "g",  --> gimp
}
for i = 1, #keystore do
   globalkeys = awful.util.table.join(globalkeys,
   awful.key({ modkey }, keystore[i],
	     function ()
		local t = awful.tag.viewonly(shifty.getpos(i))
	     end),

   awful.key({ modkey, "Control" }, keystore[i],
	     function ()
		t = shifty.getpos(i)
		t.selected = not t.selected
	     end),

      awful.key({ modkey, "Shift" }, keystore[i],
	     function ()
		if client.focus then
		   local t = shifty.getpos(i)
		   awful.client.movetotag(t)
		   awfu.tag.viewonly(t)
		end
	     end),

   awful.key({ modkey, "Control", "Shift" }, keystore[i],
	     function()
		if client.focus then
		   awful.client.toggletag(shifty.getpos(i))
		end
	     end))
end

-- Set keys
root.keys(globalkeys)
shifty.config.globalkey = globalkeys
shifty.config.clientkeys = clientkeys

shifty.taglist = mytaglist
shifty.init()
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
  -- Add a titlebar
  -- awful.titlebar.add(c, { modkey = modkey })

  -- Pidgins Buddy List is always urgent on startup
  if c.role == "buddy_list"  then
    awful.client.urgent.delete(c)
  end

  -- Enable sloppy focus
  c:add_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
      and awful.client.focus.filter(c) then
      client.focus = c
    end
  end)

  -- usefull for debugging

  if not startup then
     -- Set the windows at the slave,
     -- i.e. put it at the end of others instead of setting it master.
     awful.client.setslave(c)

     -- Put windows in a smart way, only if they does not set an initial position.
     if not c.size_hints.user_position and not c.size_hints.program_position then
	awful.placement.no_overlap(c)
	awful.placement.no_offscreen(c)
     end
  end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
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
-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=2:tabstop=2:softtabstop=2:textwidth=80

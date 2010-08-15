--------------------------------------------
-- awesome.lua - main config of my window manager
-- version: v3.4.6 (Hooch)
-- D-Bus support: x
-- os: archlinux i686
-- cpu: Intel Pentium Dual CPU E2180 2.00GHz
-- grapic: Mesa DRI Intel G33 GEM
-- screen: 1900x1080
--------------------------------------------
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
require("calendar")
-- little helper
require("markup")
-- MPD library
require("mpd"); mpc = mpd.new()
-- For sending to sockets
socket = require("socket")

-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")
-- beautiful.init("/usr/share/awesome/themes/sky/theme.lua")
-- beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

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
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.floating,           -- 5
    awful.layout.suit.max,                -- 7
    awful.layout.suit.max.fullscreen,     -- 8
    -- awful.layout.suit.magnifier,
}
-- }}}

-- {{{ Run programm once
local function run_once(cmd, options)
    assert(type(cmd) == "string")
    return os.execute(
       string.format("pgrep -u $USER -x %s>/dev/null || (%s %s&)",
		     cmd, cmd, options or "")
    )
end
-- }}}

-- {{{ MPD functions
function mpc.get_stat(self)
  -- {{{ Trim
  local function trim(text, maxlen)
    if not text then return "NA"
    elseif maxlen and text:len() > maxlen then
      text = text:sub(1, maxlen - 3).."..."
    end
    return awful.util.escape(text)
  end
  -- }}}

  -- {{{ Timeformat
  local function timeformat(t)
    t = tonumber(t)
    if t >= 3600 then -- more than one hour!
      return os.date("%X", t-3600)
    else
      return os.date("%M:%S", t)
    end
  end
  -- }}}
 
  -- {{{ Basename
  local function basename(s)
    -- Remove all slashes, if any.
    local basename = s:match(".*/([^/]*)") or s
    -- Remove file extension too.
    -- Hint: MPD ignores files without a supported file extension.
    return basename:match("(.*)%.[^.]+")
  end
  -- }}}

  -- {{{ Naughty notify
   local function naughty_notify(radio_on)
      local t
      if radio_on then
        t = string.format("%s: %s",
        markup.bold("Radio"),  trim(self.current.name))
      else
        t = string.format("%s: %s\n%s:  %s\n%s: %s",
        markup.bold("Artist"), trim(self.current.artist),
        markup.bold("Album"),  trim(self.current.album),
        markup.bold("Title"),  trim(self.current.title or
          basename(self.current.file, 25)))
      end
      naughty.notify ({
        icon    = "/usr/share/pixmaps/sonata.png",
        icon_size = 45,
        opacity = 0.9,
        timeout = 3,
        text    = t,
        margin  = 10, })
      end
   -- }}}

   -- {{{ Main
   self.stats = self:send("status")

   if self.stats.errormsg then return "No Connection."
   elseif self.stats.state == "stop" then return
   else
     -- Fetch infos about current songs
     self.current = self:send("currentsong")

     -- Basic information set
     local radio_on = (self.current.name ~= nil), now_playing

     -- Additional information depending on mode
     if radio_on then
       local station = trim(self.current.name, 20)
       -- Radio stations often put the name of artist and song
       -- in the title, so it gets longer as usual.
       local title   = trim(self.current.title, 35)

       now_playing = string.format("%s: %s ", station, title)
     else
       local artist = trim(self.current.artist, 20)
       local title  = trim(self.current.title or
			   -- Basename regex is derived from luarocks
         basename(self.current.file), 25)
       local total_time   = timeformat(self.stats.time:match(":(%d+)"))
       local current_time = timeformat(self.stats.time:match("(%d+):"))

       now_playing = string.format("%s: %s | %s/%s ", artist, title, current_time, total_time)
     end

     -- Title has changed?
     if (self.last_songid ~= self.stats.songid) and self.last_songid then
       naughty_notify(radio_on)
     end
     self.last_songid = self.stats.songid

     if self.stats.state == "pause" then
       -- Use inconspicuous color to push it to the background, depend on the theme.
       now_playing = "<span color='#505050'>"..now_playing.."</span>"
     end

     return now_playing
   end
   -- }}}
end
-- }}}

-- {{{ Shifty configuration
-- tag settings
-- the exclusive in each definition seems to be overhead, but it prevent new on-the-fly tags to be exclusive
-- the follow function make it easier to swap tags

shifty.config.tags = {
  ["1:web"]     = { position = 1, exclusive = true, init = true, nopopup = true,
		    layout = "max", run = function () run_once(browser) end },
  ["2:dev"]     = { position = 2, exclusive = true, spawn = terminal },
  ["3:im"]      = { position = 3, exclusive = true, nopopup = true, spawn = "pidgin" },
  ["4:doc"]     = { position = 4, exclusive = true },
  ["d:own"]     = { position = 5, exclusive = true },
  ["p:cfm"]     = { position = 6, exclusive = true, icon = "/usr/share/pixmaps/pcmanfm.png", spawn = "pcmanfm" },
  ["e:macs"]    = { position = 7, exclusive = true, spawn = "emacs" },
  ["a:rio"]     = { position = 8, exclusive = true, spawn = "sonata" },
  ["s:mplayer"] = { position = 9, exclusive = true, spawn = "smplayer" },
  ["w:ine"]     = { position = 10,exclusive = true },
  ["g:imp"]     = { position = 11,exclusive = true, spawn = "gimp-2.7" }
}

-- client settings
-- order here matters, early rules will be applied first
shifty.config.apps = {
  { match = { "Firefox", "Opera", "chromium",
      "Developer Tools" },                                  tag = "1:web" },
  { match = { "xterm", "urxvt" },                           tag = "2:dev", slave = true, honorsizehints = false },
  { match = { "Pidgin" },                                   tag = "3:im" },
  { match = { "evince", "gvim", "keepassx", "OpenOffice" }, tag = "4:doc" },
  { match = { "gpodder", "JDownloader", "Nachricht" },      tag = "d:own" },
  { match = { "*mplayer*", "MPlayer" },                     tag = "s:mplayer" },
  { match = { "pcmanfm", "nautilus" },                      tag = "p:cfm", slave = true },
  { match = { "ncmpcpp", "Goggles Music", "sonata" },       tag = "a:rio" },
  { match = { "emacs@" },                                   tag = "e:macs" },
  { match = { "Wine" },                                     tag = "w:ine" },
  { match = { "gimp" },                                     tag = "g:imp" },
  { match = { "gmrun", "gcalctool", "Komprimieren","Wicd*" },
  intrusive = true, ontop = true, above = true, dockable = true },
  -- buttons to resize/move clients
  { match = { "" }, buttons = awful.util.table.join(
  awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move ),
  awful.button({ modkey }, 3, awful.mouse.client.resize )
  )
}
}

-- tag defaults
shifty.config.defaults = {
   layout = awful.layout.suit.tile.left,
   ncol = 1,
   mwfact = 0.60,
   floatBars = true,
   dockable = true,
}

shifty.modkey = modkey
shifty.config.sloppy = true
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
local myawesomemenu = {
  { "manual", terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/awesome.lua" },
  { "restart", awesome.restart },
  { "quit", awesome.quit }
}

-- reboot/shutdown as user using HAL. Make sure you using
-- ck-launch-session to start awesome and you are in the power group.
local request_template  = "dbus-send --system --print-reply \
		                      --dest=\"org.freedesktop.Hal\" \
                          /org/freedesktop/Hal/devices/computer\
                          org.freedesktop.Hal.Device.SystemPowerManagement."

local mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
				    { "open terminal", terminal },
				    { "Firefox", "firefox" },
				    { "gnome-control", "gnome-control-center" },
				    { "Neustarten", request_template.."Reboot" },
				    { "Herunterfahren", request_template.."Shutdown", icon_path.."power.png" }
				  }
				 })

local mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
				     menu = mymainmenu })
-- }}}

-- {{{ Vicious and MPD

print("[awesome] initialize vicious")

-- {{{ Date and time
-- Create a textclock widget
local mytextclock = awful.widget.textclock({ align = "right" })
local clockicon = widget({ type = "imagebox" }); clockicon.image = image(icon_path.."time.png")
-- Register calendar tooltip
local clockicon_tooltip = awful.tooltip({
  objects = { clockicon },
  timer_function = function()
    local month, year = os.date('%m'), os.date('%Y')
    return calendar.display(month, year)
  end,
})
-- }}}

-- {{{ Uptime
local uptimewidget = widget({ type = "textbox" })
vicious.register(uptimewidget, vicious.widgets.uptime,
function (widget, args)
   local t = string.format("/ %sd %sh %smin", args[1], args[2], args[3])
   if tonumber(args[4]) > 0.10 then
     t = t..string.format(" <b>Load</b> %s ", args[4])
   end
   return t
end, 61)
-- }}}

-- {{{ Volume level
local volumeicon = widget({ type = "imagebox" }); volumeicon.image = image(icon_path.."vol.png")
-- Initialize widgets
local volumewidget = widget({ type = "textbox" })
local volumebar    = awful.widget.progressbar()

-- Progressbar properties
volumebar:set_width(8)
volumebar:set_height(14)
volumebar:set_vertical(true)
volumebar:set_background_color(beautiful.fg_off_widget)
volumebar:set_color(beautiful.fg_widget)
-- Bar from green to red
volumebar:set_gradient_colors({ '#AECF96', '#88A175', '#FF5656' })
awful.widget.layout.margins[volumebar.widget] = { top = 2, bottom = 2 }
-- Enable caching
vicious.cache(vicious.widgets.volume)

-- Set device name
local chan = "Master"

-- Register volume widgets
vicious.register(volumebar,    vicious.widgets.volume, "$1",  5, chan)
vicious.register(volumewidget, vicious.widgets.volume,
function (widget, args)
  if args[2] == "♩" then
    volumebar:set_value(0)
    return "Mute"
  else return args[1].."%" end
end, 5, chan)
-- Add signal
volumewidget:add_signal("update", function ()
  vicious.force({ volumewidget, volumebar })
end)

-- Register buttons and Signals
volumebar.widget:buttons( awful.util.table.join(
awful.button({ }, 1, function () awful.util.spawn("pavucontrol") end), -- left click

awful.button({ }, 2,
function ()
  awful.util.spawn("amixer -q sset "..chan.." toggle")    -- middle click
  volumewidget:emit_signal("update")
end),

awful.button({ }, 4,
function ()
  awful.util.spawn("amixer -q sset "..chan.." 5%+")       -- scroll up
  volumewidget:emit_signal("update")
end),

awful.button({ }, 5,
function ()
  awful.util.spawn("amixer -q sset "..chan.." 5%-")       -- scroll down
  volumewidget:emit_signal("update")
end)
))
volumewidget:buttons( volumebar.widget:buttons() )
volumeicon:buttons( volumebar.widget:buttons() )
-- }}}

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
    for i=2,#args do
      -- alerts, if system is stressed
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
end )
-- Register buttons
cpuwidget:buttons( awful.button({ }, 1, function () awful.util.spawn(terminal .. " -e htop") end) )
cpuicon:buttons( cpuwidget:buttons() )
-- }}}

-- {{{ Memory usage
local memwidget = widget({ type = "textbox" })
local memicon = widget({ type = "imagebox" }); memicon.image = image(icon_path.."mem.png")
vicious.register(memwidget, vicious.widgets.mem, "$2MB/$3MB ", 5)
-- Register buttons
memwidget:buttons( cpuwidget:buttons() )
memicon:buttons( cpuwidget:buttons() )
-- }}}

-- {{{ Net usage
local netwidget = widget({ type = "textbox" })
local downicon  = widget({ type = "imagebox" }); downicon.image = image(icon_path.."down.png")
local upicon    = widget({ type = "imagebox" }); upicon.image = image(icon_path.."up.png")
vicious.register(netwidget, vicious.widgets.net,
function (widget, args)
  if args["{eth0 down_kb}"] ~= "0.0" or args["{eth0 up_kb}"] ~= "0.0" then
    downicon.visible, upicon.visible = true, true
    return string.format("%skb/%skb", args["{eth0 down_kb}"], args["{eth0 up_kb}"])
  else
    downicon.visible, upicon.visible = false, false
  end
end, 5)
-- Register buttons
netwidget:buttons( awful.button({ }, 1, function () awful.util.spawn(terminal .. " -e sudo nethogs -d 2") end) )
upicon:buttons( netwidget:buttons() )
downicon:buttons( netwidget:buttons() )
-- }}}

-- {{{ Disk R/W
local iotextwidget = widget({ type = "textbox" })
local iowidget1 = widget({ type = "textbox" })
local iowidget2 = widget({ type = "textbox" })
iotextwidget.text = markup.bold("Disk R/W ")
-- Hide widget, if no disk operation
vicious.register(iowidget1, vicious.widgets.dio,
function(widget, args)
  if args["{read_mb}"] ~= "0.0" or args["{write_mb}"] ~= "0.0" then
    iotextwidget.visible = true
    return string.format("60GB: %s/%sMB ", args["{read_mb}"], args["{write_mb}"])
  elseif not iowidget2.text then
    iotextwidget.visible = false
  end
end, 3, "sda" )
vicious.register(iowidget2, vicious.widgets.dio,
function(widget, args)
  if args["{read_mb}"] ~= "0.0" or args["{write_mb}"] ~= "0.0" then
    iotextwidget.visible = true
    return string.format("140GB: %s/%sMB ", args["{read_mb}"], args["{write_mb}"])
  elseif not iowidget1.text then
    iotextwidget.visible = false
  end
end, 3, "sdb" )
-- Register buttons
iowidget1:buttons( awful.button({ }, 1, function () awful.util.spawn(terminal .. " -e iotop") end) )
iowidget2:buttons( iowidget1:buttons() )
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
		    else
		       pkgicon.visible = true
		       return markup.urgent("<b>Updates</b> "..args[1]).." "
		    end
		  end, 180, "Arch" )

pkgwidget:buttons( awful.button({ }, 1,
function ()
  awful.util.spawn(terminal.." -title 'Yaourt Upgrade' \
				 -e zsh -c 'yaourt -Su; \
				 echo Finish. Press ENTER!; \
				 read && exit'")
  pkgwidget.visible, pkgicon.visible = false, false
end) )
pkgicon:buttons( pkgwidget:buttons() )
--}}}

-- {{{ News: Display new podcasts
local newswidget = widget({ type = "textbox" })
local newsicon = widget({ type = "imagebox" }); newsicon.image = image(icon_path.."rss.png")
-- don't show icon by default
newsicon.visible = false
local lib = os.getenv("HOME").."/music/podcasts/"
vicious.register(newswidget, vicious.widgets.sumup,
function(widget, args)
  local text = ""
  for key, value in pairs(args) do
    if value > 0 then
      text = text..string.format("%s: %d ", key, value)
    end
  end
  -- toggle icon
  newsicon.visible = (text ~= "")
  return text
end, 180,
{ pattern = ".*.(mp[34]|ogg|m4a)$",
  paths = { Tagess = lib.."Tagesschau \(512x288\)",
			      mobileMacs = lib.."mobileMacs",
			      HoRads = lib.."RadioTux GNU_Linux » HoRadS",
			      Spasspkt = lib.."WDR 2 Zugabe Spaßpaket",
            NFSW = lib.."The Lunatic Fringe",
	    }}
)

-- Register Buttons in all widget
newswidget:buttons( awful.util.table.join(
   awful.button({ }, 1, function ()                                  -- left click -> play news
     vicious.force({ newswidget })
     if newswidget.text then 
       local cmd = string.format('smplayer "%s/Tagesschau \(512x288\)"', lib)
       awful.util.spawn(cmd)
     end
   end),
   awful.button({ }, 3, function () awful.util.spawn("gpodder") end) -- right click
))
-- }}}

-- {{{ MPD
local wimpc = widget({ type = "textbox" })
local mpcicon = widget({ type = "imagebox" }) mpcicon.image = image(icon_path.."music.png")
--mpcicon.visible = false

-- Register Buttons in both widget
mpcicon:buttons( wimpc:buttons(awful.util.table.join(
   awful.button({ }, 1, function () mpc:toggle_play() wimpc:emit_signal("update") end), -- left click
   awful.button({ }, 2, function () awful.util.spawn("sonata")                    end), -- middle click
   awful.button({ }, 3, function () awful.util.spawn("urxvt -e ncmpcpp")          end), -- right click
   awful.button({ }, 4, function () mpc:seek(5) wimpc:emit_signal("update")       end), -- scroll up
   awful.button({ }, 5, function () mpc:seek(-5) wimpc:emit_signal("update")      end)  -- scroll down
)))
-- Add signal
wimpc:add_signal("update",
function ()
   wimpc.text = mpc:get_stat()
end)
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
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
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
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        uptimewidget, mytextclock, clockicon,
        volumewidget, volumebar.widget, volumeicon,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }

    mystatusbox[s].widgets = {
      {
        cpuicon, cpuwidget,
        memicon, memwidget,
        iotextwidget, iowidget1, iowidget2,
        downicon, netwidget, upicon,
        layout = awful.widget.layout.horizontal.leftright
      },
      pkgwidget, pkgicon,
      wimpc, mpcicon,
      newswidget, newsicon,
      s == 1 or nil,
      layout = awful.widget.layout.horizontal.rightleft
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

    awful.key({ modkey, }, "b", function ()
       if mystatusbox[mouse.screen].screen == nil then
         mystatusbox[mouse.screen].screen = mouse.screen
       else
         mystatusbox[mouse.screen].screen = nil
       end
     end),


    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

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
    awful.key({ "Shift" }, "space", function () mpc:toggle_play() wimpc:emit_signal("update") end),
    -- Smplayer/Gnome control
    awful.key({ modkey2 }, "space", function ()
      local result = os.execute("smplayer -send-action play_or_pause") -- return 0 on succes
      if result ~= 0 then
        awful.util.spawn("dbus-send / com.gnome.mplayer.Play") -- if state is play it pause
      end
    end),

    -- easy way to share Screenshots over dropbox: The following code make a
    -- Screenshot open it with Eye of Gnome, copy it to dropbox and put the
    -- public link into the X-clipboard
    awful.key({ }, "Print", function ()
      awful.util.spawn("scrot -e 'eog $f; mv $f Dropbox/Public;dropbox puburl Dropbox/Public/$f | xclip'")
    end),

    -- {{{ Volume keyboard control
    awful.key({ modkey }, "Prior",
    function ()
      awful.util.spawn('amixer set Master 5%+')
      volumewidget:emit_signal("update")
    end),
    awful.key({ modkey }, "Next",
    function ()
      awful.util.spawn('amixer set Master 5%-')
      volumewidget:emit_signal("update")
    end),
    -- }}}

    -- }}}

    -- Prompt
    --awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey },            "r",     function ()
      awful.util.spawn("dmenu_run -i ".. 
      " -nb '"  .. "#222222"  .. 
      "' -nf '" .. "#888888" .. 
      "' -sb '" .. "#285577" .. 
      "' -fn '"  .. "sans-14" ..
      "' -sf '" .. "#ffffff" .. "'") 
    end),

    awful.key({ modkey }, "x",
              function ()
                awful.prompt.run({ prompt = "Run Lua code: " },
                mypromptbox[mouse.screen].widget,
                awful.util.eval, nil,
                awful.util.getdir("cache") .. "/history_eval")
              end)
)

local clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 10
local keystore = { 1, 2, 3, 4,
"d",  --> down
"p",  --> pcmanfm
"e",  --> emacs
"a",  --> ario
"s",  --> smplayer
"w",  --> wine
"g" } --> gimp

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

  awful.key({ modkey, "Control", "Shift" }, keystore[i],
  function()
    if client.focus then
      awful.client.toggletag(shifty.getpos(i))
    end
  end),

  awful.key({ modkey, "Shift" }, keystore[i],
  function ()
    if client.focus then
      local t = shifty.getpos(i)
      awful.client.movetotag(t)
      awfu.tag.viewonly(t)
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

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
      if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
      end
    end)

		-- usefull for debugging
	  -- naughty.notify( { title = 'Fenster', text = c.name, timeout = 5 } )

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
-- update every 3 seconds mpcwidget via timer
mytimer = timer { timeout = 3 }
mytimer:add_signal("timeout", function()
  wimpc:emit_signal("update")
end)
mytimer:start()
-- }}}

-- {{{ Random Wallpaper - The new wallpaper of awesome is cooler
awful.util.spawn("habak -ms -hi /usr/share/awesome/themes/default/background.png")
-- }}}

-- {{{ Reload xcompmgr
-- to avoid problems with the panels.
os.execute("killall xcompmgr 2> /dev/null; xcompmgr -r 6 -o 0.75 -l -15 -t -15 -I 0.028 -O 0.03 -D 10 -C -F -n -s &")
-- }}}

-- {{{ Welcome Message
print("[awesome] Send welcome message")

naughty.notify( { title = "Awesome "..awesome.version.." started!",
		  text  = string.format("Welcome %s. Your host is %s.\nIt is %s",
	      os.getenv("USER"), awful.util.pread("hostname"):match("(.*)\n$"), os.date()),
      timeout = 7 } )
-- }}}
-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=2:tabstop=2:softtabstop=2:encoding=utf-8:textwidth=80

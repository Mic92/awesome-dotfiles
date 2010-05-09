-- stolen from http://www.markurashi.de/dotfiles/awesome/rc.lua

-- failsafe mode
-- if the current config fail, load the default rc.lua
-- main configuration is in awesome.lua

require("awful")
require("naughty")

confdir = awful.util.getdir("config")
local rc, err = loadfile(confdir .. "/awesome.lua");
if rc then
	rc, err = pcall(rc);
	if rc then
		return
	else
		dofile("/etc/xdg/awesome/rc.lua");

		-- usefull for debugging
		naughty.notify {
			text = string.format("Awesome crashed during startup on %s:\n\n%s", os.date(), 
			awful.util.escape(err)), timeout = 0 }
	end
end


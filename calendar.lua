local os = os
local string = string
local math = math
local print = print
local tostring = tostring
local markup = require("markup")

module("calendar")

function display(month,year,weekStart)
	local t,wkSt=os.time{year=year, month=month+1, day=0},weekStart or 1
	local d=os.date("*t",t)
	local mthDays,stDay=d.day,(d.wday-d.day-wkSt+1)%7

	print(mthDays .."\n" .. stDay)
	local lines = "    "

	for x=0,6 do
		lines = lines .. os.date("%a ",os.time{year=2006,month=1,day=x+wkSt})
	end

	lines = lines .. "\n" .. os.date(" %V",os.time{year=year,month=month,day=1})

	local writeLine = 1
	while writeLine < (stDay + 1) do
		lines = lines .. "    "
		writeLine = writeLine + 1
	end

	for d=1,mthDays do
		local x = d
		local t = os.time{year=year,month=month,day=d}
		if writeLine == 8 then
			writeLine = 1
			lines = lines .. "\n" .. os.date(" %V",t)
		end
		if os.date("%Y-%m-%d") == os.date("%Y-%m-%d", t) then
			x = markup.underline(d)
		end
		if (#(tostring(d)) == 1) then
			x = " " .. x
		end
		lines = lines .. "  " .. x
		writeLine = writeLine + 1
	end
	local header = os.date("%B %Y\n",os.time{year=year,month=month,day=1})

   return markup.font("monospace", header .. "\n" .. lines)
end

-- vim:set filetype=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --

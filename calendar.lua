local os = {date = os.date, time = os.time}
local markup = require("markup")
local string = {format = string.format, rep = string.rep}
local print = print
local math = {floor = math.floor}

module("calendar")

function display(month, year)

    local function fill_line(width)
        return string.rep(" ", width)
    end

    local function center(string, width)
        width = width - #string

        local before = math.floor(width/2)
        local behind = width - before

        before = fill_line(before)
        behind = fill_line(behind)

        return before..string..behind
    end

	local date = os.date("*t", os.time{year=year,month=month+1,day=0})
    local time = os.time{year=year,month=month,day=1}

    local week = "    "
    for i=2, 8 do
	local weekday = os.date("%a ", os.time{year=2006,month=1,day=i})
		week = week..weekday
    end

    local max_width = #week

    -- month + year in the header
    local header = os.date(" %B %Y", time)
    header = center(header, max_width)

    -- indention of the first line
    local first_weekday = (date.wday - date.day - 1)%7
	local body = os.date(" %V", time)..fill_line(first_weekday*4)
    local position = first_weekday + 1

    -- the rest day of the month
    for day=1, date.day do
	local x = day
	local t = os.time{year=year,month=month,day=day}

	if position == 8 then
	    body = body.." \n"
	    -- week of the year
	    body = body..os.date(" %V",t)
	    position = 1
	end

	if os.date("%Y%m%d") == os.date("%Y%m%d", t) then
	    -- highline current day
	    x = markup.heading(day)
	end

	if day < 10 then -- <= single character
	    x = " "..x
	end

	body = ("%s  %s"):format(body, x)
	position = position + 1
    end

    body = body..fill_line(max_width - position*4 + 1)

    return markup.normal(markup.font("monospace", ("%s\n%s\n%s"):format(header, week, body)))
end

-- vim:set filetype=lua fdm=marker tabstop=4 shiftwidth=4 expandtab smarttab autoindent smartindent: --

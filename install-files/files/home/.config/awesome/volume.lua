local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local timer = require("gears.timer")
local gtable = require("gears.table")
local awful = require("awful")

--brettinternet from stackexchange 's command works better
local getVol = "pacmd list-sinks|grep -A 15 \'* index\'| awk \'/volume: front/{ print $5 }\' | sed \'s/[%|,]//g\'"

--Commands need to run in order to prevent a mismatch information and reality,so it's easiest to run them into the shell in order
local commands = {
get= getVol
,raise = "pactl set-sink-mute @DEFAULT_SINK@ false ; pactl set-sink-volume @DEFAULT_SINK@ +1%"..";"..getVol
,lower = "pactl set-sink-mute @DEFAULT_SINK@ false ; pactl set-sink-volume @DEFAULT_SINK@ -1%"..";"..getVol
}

local vol = {}

-- Force  vol to update now.
function vol:force_update()
    self._timer:emit_signal("timeout")
end

--de-duplicate code, passing in w and command name, then runs this command and updates w(w is our textbox)
local function runCommand(w,command)
    awful.spawn.easy_async_with_shell(commands[command], function(out)
     	w:set_markup(('[vol:'..string.sub(out,0,-2)..']'))-- sets the markup for the widget to the output of our command. Sub to remove newline
    end) 

end


-- function
local function new() -- format
    local w = textbox()
    w:buttons(
        awful.util.table.join(
            awful.button({},4,function()
                --on up(outward) scroll, raise volume
                runCommand(w,"raise")
            end),
            awful.button({},5,function()
                --on down(inward) scroll, lower volume
                runCommand(w,"lower")
            end),
            awful.button({},1,function()
                --on left click, raise volume
                runCommand(w,"raise")
            end),
            awful.button({},3,function()
                --on right click lower volume
                runCommand(w,"lower")
            end)
        )
    )
    
    gtable.crush(w, vol, true)--makes the first table's elements into the elements of the second table.
    
    
    function w._private.vol_update_cb()
        runCommand(w,"get")
        w._timer:again()
        return true -- Continue the timer
    end
    

    w._timer = timer.weak_start_new(30, w._private.vol_update_cb)-- starts timer
    w:force_update()-- run now so we don't have to wait 30 seconds for the first update
    return w
end

function vol:__call(...)
    return new(...)
end

return setmetatable(vol, vol)

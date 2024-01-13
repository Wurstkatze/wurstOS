-- API to log with timestamp, tag and color

local function timestamp()
    local hours, minutes = string.match(textutils.formatTime(os.time(), true), "(%d+):(%d+)")
    return string.format("[%d/%s:%s]", os.day(), string.format("%02d", tonumber(hours)), string.format("%02d", tonumber(minutes)))
end


local function decode(...)
    local args = {...}
    for _, arg in ipairs(args) do
        if type(arg) == "table" then
            print(textutils.serialize(arg))
            lastIsNotTable = false
        else
            write(tostring(arg) .. " ")
            lastIsNotTable = true
        end
    end
    if lastIsNotTable then
        print()
    end
end

local function logWithTag(tag, color)
    oldColor = term.getTextColor()
    term.setTextColor(color)
    write(timestamp())
    write("["..tag.."] ")
    term.setTextColor(oldColor)
end

debugEnabled = true
function debug(...)
    if debugEnabled then
        logWithTag("DEBUG", colors.magenta)
        decode(...)
    end
end

function log(...)
    logWithTag("LOG", colors.cyan)
    decode(...)
end

function warn(...)
    logWithTag("WARN", colors.orange)
    decode(...)
end

function error(...)
    logWithTag("ERROR", colors.red)
    decode(...)
end

function status(...)
    logWithTag("STATUS", colors.lime)
    decode(...)
end

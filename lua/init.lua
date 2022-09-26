local M = { work_duration = 25 * 60, break_duration = 5 * 60, counter = nil, timer = nil, state = nil, previous_state = nil }

local STATE_WORKING = 0
local STATE_PAUSED = 1
local STATE_BREAK = 2

local STATE_MESSAGE_MAPPING = {
    [STATE_WORKING] = "Working",
    [STATE_PAUSED] = "Paused",
    [STATE_BREAK] = "Break",
}

local function format_seconds(seconds)
    local hh = string.format("%02.f", math.floor(seconds / 3600))
    local mm = string.format("%02.f", math.floor(seconds / 60 - (hh * 60)))
    local ss = string.format("%02.f", math.floor(seconds - hh * 3600 - mm * 60))
    return hh .. ":" .. mm .. ":" .. ss
end

function M.start_timer(callback)
    M.timer = vim.loop.new_timer()
    M.timer:start(
        0,
        1000,
        vim.schedule_wrap(function()
            callback()
        end)
    )
end

function M.stop_timer()
    if M.timer ~= nil then
        M.timer:close()
        M.timer = nil
    end
end

function M.start()
    if M.previous_state ~= nil then
        M.state = M.previous_state
    else
        M.state = STATE_WORKING
    end
    M.start_timer(M.event_loop)
end

function M.pause()
    M.previous_state = M.state
    M.state = STATE_PAUSED
end

function M.skip()
    if M.state == STATE_WORKING then
        M.state = STATE_BREAK
        M.counter = M.break_duration
    elseif M.state == STATE_BREAK then
        M.state = STATE_WORKING
        M.counter = M.work_duration
    end
end

function M.render_popup_content()
    return {
        " Status: " .. STATE_MESSAGE_MAPPING[M.state],
        " " .. format_seconds(M.counter) .. " seconds remain",
    }
end

function M.event_loop()
    local content = M.render_popup_content()

    M.window.update(content)

    if M.state == STATE_PAUSED then
        M.stop_timer()
    else
        M.counter = M.counter - 1
    end

    if M.counter < 0 then
        if M.state == STATE_WORKING then
            M.state = STATE_BREAK
            M.counter = M.break_duration
        elseif M.state == STATE_BREAK then
            M.state = STATE_WORKING
            M.counter = M.work_duration
        end
    end
end

function M.init()
    M.window = require("pomodoro.window")

    M.window.title = "pomodoro.nvim"
    M.window.subtitle = "[q]uit [s]tart [p]ause s[k]ip"

    M.window.mappings = {
        ["q"] = M.window.close_window,
        ["s"] = M.start,
        ["p"] = M.pause,
        ["k"] = M.skip,
    }

    M.window.open_window()

    M.state = STATE_WORKING
    M.counter = M.work_duration
end

M.init()

-- return M

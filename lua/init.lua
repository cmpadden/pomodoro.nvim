-- PomdoroStart
-- PomodoroStop

local M = { work_duration = 3, break_duration = 2, counter = nil, timer = nil }

local STATE_PAUSED = 0
local STATE_WORKING = 1
local STATE_BREAK = 2


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
    -- TODO - determine the previous state; un-pausing should resume where things left
    -- off
    M.state = STATE_WORKING
    M.start_timer(M.event_loop)
end

function M.pause()
    M.state = STATE_PAUSED
end

function M.render_popup_content()
    local msg = ""
    if M.state == STATE_WORKING then
        msg = "Keep up the good work! There are " .. tostring(M.counter) .. " seconds remaining in this interval."
    elseif M.state == STATE_BREAK then
        msg = "There are " .. tostring(M.counter) .. " seconds remaining in your break."
    elseif M.state == STATE_PAUSED then
        msg = "Paused..."
    end
    return {
        msg,
        "Counter " .. tostring(M.counter) .. " seconds",
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
    M.window.subtitle = "[q]uit [s]tart [p]ause"

    M.window.mappings = {
        ['q'] = M.window.close_window,
        ['s'] = M.start,
        ['p'] = M.pause
    }

    M.window.open_window()

    M.state = STATE_WORKING
    M.counter = M.work_duration
end

M.init()

-- return M

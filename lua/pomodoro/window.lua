local M = { _buf = nil, _win = nil, title = nil, subtitle = nil, win_height = 0.20, win_width = 0.40, mappings = {} }

local function center_text(text)
    local width = vim.api.nvim_win_get_width(0)
    local shift = math.floor(width / 2) - math.floor(string.len(text) / 2)
    return string.rep(" ", shift) .. text
end

function M.set_buffer_keymappings()
    assert(M._buf ~= nil, "Buffer must be instantiated before assigning keymappings")
    for k, v in pairs(M.mappings) do
        vim.keymap.set("n", k, v, {
            buffer = M._buf,
            nowait = true,
            silent = true,
        })
    end
end

function M.open_window()
    M._buf = vim.api.nvim_create_buf(false, true)

    M.set_buffer_keymappings()

    local border_buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_option(M._buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(M._buf, "filetype", "whid")

    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")

    local win_height = math.ceil(height * M.win_height - 4)
    local win_width = math.ceil(width * M.win_width)
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)

    local border_opts = {
        style = "minimal",
        relative = "editor",
        width = win_width + 2,
        height = win_height + 2,
        row = row - 1,
        col = col - 1,
    }

    local opts = {
        style = "minimal",
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
    }

    -- https://en.wikipedia.org/wiki/Box-drawing_character

    local border_lines = { "┏" .. string.rep("━", win_width) .. "┓" }
    local middle_line = "┃" .. string.rep(" ", win_width) .. "┃"
    for _ = 1, win_height do
        table.insert(border_lines, middle_line)
    end
    table.insert(border_lines, "┗" .. string.rep("━", win_width) .. "┛")

    vim.api.nvim_buf_set_lines(border_buf, 0, -1, false, border_lines)

    vim.api.nvim_open_win(border_buf, true, border_opts)
    M._win = vim.api.nvim_open_win(M._buf, true, opts)

    vim.api.nvim_command('au BufWipeout <buffer> exe "silent bwipeout! "' .. border_buf)

    vim.api.nvim_win_set_option(M._win, "cursorline", true)

    if M.title ~= nil then
        vim.api.nvim_buf_set_lines(M._buf, 0, -1, false, { center_text(M.title), "", "" })
        vim.api.nvim_buf_add_highlight(M._buf, -1, "Number", 0, 0, -1)
    end

    if M.subtitle ~= nil then
        vim.api.nvim_buf_set_lines(M._buf, 1, -1, false, { center_text(M.subtitle), "", "" })
    end

    if M.title ~= nil or M.subtitle ~= nil then
        vim.api.nvim_buf_set_lines(M._buf, 2, -1, false, { string.rep("━", win_width), "", "" })
    end

    vim.api.nvim_buf_set_option(M._buf, "modifiable", false)
end

function M.update(content)
    if M._win ~= nil and M._buf ~= nil then
        vim.api.nvim_buf_set_option(M._buf, "modifiable", true)
        vim.api.nvim_buf_set_lines(M._buf, 3, -1, false, content)
        vim.api.nvim_buf_set_option(M._buf, "modifiable", false)
    end
end

function M.close_window()
    vim.api.nvim_win_close(M._win, true)
    M._win = nil
    M._buf = nil
end

return M

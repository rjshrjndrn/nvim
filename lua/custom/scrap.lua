-- ~/.config/nvim/lua/custom/scrap.lua

local function scrap()
  -- Get the Neovim shared data directory
  local data_dir = vim.fn.stdpath("data")
  local buf_name = data_dir .. "/scrap.txt"
  local existing_window = nil
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_name(buf) == buf_name then
      existing_window = win
      break
    end
  end

  if existing_window then
    -- If buffer is already open, close the window containing it
    vim.api.nvim_win_close(existing_window, true)
  else
    -- If buffer is not open, open a vertical split
    vim.cmd("vsplit")
    local buf = vim.api.nvim_create_buf(false, true) -- create an unnamed buffer
    vim.api.nvim_buf_set_name(buf, buf_name)
    vim.api.nvim_win_set_buf(0, buf) -- set the buffer to the current window

    -- Resize the vertical split to 1/4 of the screen width
    local width = math.floor(vim.o.columns * 0.25)
    vim.cmd("vertical resize " .. width)

    -- Read the content of /tmp/scrap.txt and set it to the buffer
    local file = io.open(buf_name, "r")
    if file then
      local content = file:read("*a")
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(content, "\n"))
      file:close()
    end

    --
    -- Set buffer options
    vim.api.nvim_set_option_value("wrap", true, { scope = "local", win = 0 }) -- enable wrapping for the current window
    vim.api.nvim_set_option_value("number", false, { scope = "local", win = 0 }) -- enable wrapping for the current window
    vim.bo.bufhidden = "wipe" -- set bufhidden option
    vim.bo.filetype = "markdown" -- set filetype
    -- Move the cursor to the end of the last line and enter insert mode
    local last_line = vim.api.nvim_buf_line_count(buf)
    local last_col = #vim.api.nvim_buf_get_lines(buf, last_line - 1, last_line, false)[1]
    vim.api.nvim_win_set_cursor(0, { last_line, last_col })

    -- Start insert mode
    -- vim.api.nvim_feedkeys("i", "n", true)
    -- Schedule a function
    -- vim.schedule(function()
    --   vim.api.nvim_command("startinsert")
    -- end)

    -- Function to write buffer content to /tmp/scrap.txt
    local function write_to_file()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local content = table.concat(lines, "\n")
      local write_file = io.open(buf_name, "w")
      if write_file then
        write_file:write(content)
        write_file:close()
      end
    end

    -- Set autocommands to save the buffer back to /tmp/scrap.txt
    vim.api.nvim_create_autocmd({ "BufWriteCmd", "InsertLeave", "TextChanged" }, {
      buffer = buf,
      callback = write_to_file,
    })
  end
end

-- Create the command :Scrap to call the scrap function
vim.api.nvim_create_user_command("Scrap", scrap, {})

-- Set the keymap for normal mode to trigger the scrap function
-- vim.api.nvim_set_keymap("n", "<leader>;", ":Scrap<CR>", { noremap = true, silent = true })

return {
  scrap = scrap,
}

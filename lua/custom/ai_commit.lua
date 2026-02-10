-- AI Commit Message Generator using OpenCode Zen API
local M = {}

local api_url = "https://opencode.ai/zen/v1/chat/completions"
local model = "big-pickle"

local system_prompt = [[You are a Git commit message generator. Given a git diff, write a concise, conventional commit message.

Rules:
- Use conventional commit format: type(scope): description
- Types: feat, fix, refactor, docs, style, test, chore, perf
- Keep the first line under 72 characters
- Focus on WHY the change was made, not WHAT changed
- Be specific but concise
- No markdown formatting, just plain text
- Return ONLY the commit message, nothing else]]

local function get_api_key()
  local key = os.getenv("OPENCODE_API_KEY")
  if not key or key == "" then
    vim.notify("OPENCODE_API_KEY environment variable not set", vim.log.levels.ERROR)
    return nil
  end
  return key
end

local function get_staged_diff()
  local result = vim.fn.system("git diff --cached")
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to get staged diff. Are you in a git repo?", vim.log.levels.ERROR)
    return nil
  end
  if result == "" then
    vim.notify("No staged changes found. Stage changes with 'git add' first.", vim.log.levels.WARN)
    return nil
  end
  return result
end

local function create_floating_window(content)
  local buf = vim.api.nvim_create_buf(false, true)
  local lines = vim.split(content, "\n")

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("filetype", "gitcommit", { buf = buf })
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(#lines + 2, 20)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " AI Commit Message (q:close, <CR>:commit) ",
    title_pos = "center",
  })

  -- Keymaps for the floating window
  local opts = { buffer = buf, silent = true }

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, opts)

  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(win, true)
  end, opts)

  vim.keymap.set("n", "<CR>", function()
    local msg = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
    vim.api.nvim_win_close(win, true)
    -- Run git commit with the message
    local escaped_msg = msg:gsub("'", "'\\''")
    local commit_result = vim.fn.system("git commit -m '" .. escaped_msg .. "'")
    if vim.v.shell_error == 0 then
      vim.notify("Committed: " .. lines[1], vim.log.levels.INFO)
    else
      vim.notify("Commit failed: " .. commit_result, vim.log.levels.ERROR)
    end
  end, opts)

  return buf, win
end

function M.generate()
  local api_key = get_api_key()
  if not api_key then return end

  local diff = get_staged_diff()
  if not diff then return end

  -- Truncate diff if too large
  if #diff > 15000 then
    diff = diff:sub(1, 15000) .. "\n... (truncated)"
  end

  vim.notify("Generating commit message...", vim.log.levels.INFO)

  local payload = vim.fn.json_encode({
    model = model,
    messages = {
      { role = "system", content = system_prompt },
      { role = "user", content = "Generate a commit message for this diff:\n\n" .. diff },
    },
    max_tokens = 200,
    temperature = 0.3,
  })

  local tmpfile = vim.fn.tempname()
  local f = io.open(tmpfile, "w")
  if f then
    f:write(payload)
    f:close()
  end

  local cmd = {
    "curl", "-s", "-X", "POST", api_url,
    "-H", "Content-Type: application/json",
    "-H", "Authorization: Bearer " .. api_key,
    "-d", "@" .. tmpfile,
  }

  local stdout = {}
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stdout, line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      os.remove(tmpfile)
      vim.schedule(function()
        if exit_code ~= 0 then
          vim.notify("API request failed", vim.log.levels.ERROR)
          return
        end

        local response = table.concat(stdout, "")
        local ok, decoded = pcall(vim.fn.json_decode, response)
        if not ok then
          vim.notify("Failed to parse API response", vim.log.levels.ERROR)
          return
        end

        if decoded.error then
          vim.notify("API error: " .. (decoded.error.message or "unknown"), vim.log.levels.ERROR)
          return
        end

        local msg = decoded.choices
          and decoded.choices[1]
          and decoded.choices[1].message
          and decoded.choices[1].message.content

        if not msg then
          vim.notify("No response from API", vim.log.levels.ERROR)
          return
        end

        msg = vim.trim(msg)
        create_floating_window(msg)
      end)
    end,
  })
end

-- Setup keymap
vim.keymap.set("n", "<leader>ap", M.generate, { silent = true, desc = "AI generate commit message" })

return M

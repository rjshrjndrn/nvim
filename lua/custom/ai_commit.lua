-- AI Commit Message Generator using OpenCode Zen API
local M = {}

local api_url = "https://opencode.ai/zen/v1/chat/completions"
local model = "big-pickle"

local system_prompt = [[You are a Git commit message generator. Given a git diff, write a commit message.

Format:
type(scope): short description (under 50 chars)

- Bullet point explaining what was done
- Another bullet point if needed
- Focus on functionality changes, not code details

Rules:
- Types: feat, fix, refactor, docs, style, test, chore, perf
- Keep title under 50 characters
- Wrap body at 72 characters
- Use bullet points (- ) for the body
- No markdown formatting, plain text only
- Return ONLY the commit message, nothing else]]

local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local function start_spinner(msg)
  local buf = vim.api.nvim_create_buf(false, true)
  local width = #msg + 4
  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    width = width,
    height = 1,
    row = vim.o.lines - 3,
    col = vim.o.columns - width - 2,
    style = "minimal",
    border = "rounded",
    noautocmd = true,
  })
  vim.api.nvim_set_option_value("winblend", 0, { win = win })

  local idx = 0
  local timer = vim.uv.new_timer()
  timer:start(
    0,
    80,
    vim.schedule_wrap(function()
      if not vim.api.nvim_win_is_valid(win) then
        timer:stop()
        timer:close()
        return
      end
      idx = (idx % #spinner_frames) + 1
      local line = " " .. spinner_frames[idx] .. " " .. msg
      pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, { line })
    end)
  )

  return {
    stop = function()
      timer:stop()
      timer:close()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
  }
end

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
  if not api_key then
    return
  end

  local diff = get_staged_diff()
  if not diff then
    return
  end

  -- Truncate diff if too large
  if #diff > 15000 then
    diff = diff:sub(1, 15000) .. "\n... (truncated)"
  end

  local spinner = start_spinner("Generating commit message...")

  local payload = vim.fn.json_encode({
    model = model,
    messages = {
      { role = "system", content = system_prompt },
      { role = "user", content = "Generate a commit message for this diff:\n\n" .. diff },
    },
    max_tokens = 500,
    temperature = 0.3,
  })

  local tmpfile = vim.fn.tempname()
  local f, err = io.open(tmpfile, "w")
  if not f then
    spinner.stop()
    vim.notify("Failed to write temp file: " .. (err or "unknown"), vim.log.levels.ERROR)
    return
  end
  f:write(payload)
  f:close()

  local cmd = {
    "curl",
    "-s",
    "-X",
    "POST",
    api_url,
    "-H",
    "Content-Type: application/json",
    "-H",
    "Authorization: Bearer " .. api_key,
    "-d",
    "@" .. tmpfile,
  }

  local stdout = {}
  local stderr = {}
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stdout, line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            table.insert(stderr, line)
          end
        end
      end
    end,
    on_exit = function(_, exit_code)
      os.remove(tmpfile)
      vim.schedule(function()
        spinner.stop()
        local ok_outer, err_outer = pcall(function()
          if exit_code ~= 0 then
            local stderr_msg = table.concat(stderr, "\n")
            vim.notify(
              "API request failed (exit " .. exit_code .. "): " .. (stderr_msg ~= "" and stderr_msg or "unknown"),
              vim.log.levels.ERROR
            )
            return
          end

          local response = table.concat(stdout, "")
          if response == "" then
            vim.notify("API returned empty response", vim.log.levels.ERROR)
            return
          end

          local ok, decoded = pcall(vim.fn.json_decode, response)
          if not ok or decoded == vim.NIL or type(decoded) ~= "table" then
            vim.notify("Failed to parse API response: " .. response:sub(1, 200), vim.log.levels.ERROR)
            return
          end

          if decoded.error then
            vim.notify("API error: " .. (decoded.error.message or vim.inspect(decoded.error)), vim.log.levels.ERROR)
            return
          end

          local msg = decoded.choices
            and decoded.choices[1]
            and decoded.choices[1].message
            and decoded.choices[1].message.content

          if not msg then
            vim.notify("Unexpected API response structure: " .. response:sub(1, 200), vim.log.levels.ERROR)
            return
          end

          msg = vim.trim(msg)
          create_floating_window(msg)
        end)
        if not ok_outer then
          vim.notify("AI commit error: " .. tostring(err_outer), vim.log.levels.ERROR)
        end
      end)
    end,
  })
end

-- Setup keymap
vim.keymap.set("n", "<leader>ap", M.generate, { silent = true, desc = "AI generate commit message" })

return M

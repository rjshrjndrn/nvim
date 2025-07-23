-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap.set
-- Shorten function name
-- Silent keymap option
local opts = { silent = true }

-- Better paste
keymap("x", "p", '"_dP', opts)
-- keymap("n", "<leader>y", '"+y', opts)
keymap({ "n", "v" }, "<leader>y", '"+y', opts)
keymap("n", "<leader>Y", '"+y$', opts)
keymap("v", "Y", '"+y', opts)
keymap("n", "<leader>P", '"+P', opts)
keymap("n", "<leader>p", '"+p', opts)
keymap("n", "<C-Y>", 'magg0"+yG`a:delmarks a<CR>', opts)

-- Better tab
keymap("n", "<leader>tn", ":tabnext<CR>", opts)
keymap("n", "<leader>tp", ":tabprevious<CR>", opts)
keymap("n", "<leader>tl", ":tablast<CR>", opts)
keymap("n", "<leader>tf", ":tabfirst<CR>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Folds
keymap("n", ";z", "zM", opts)
keymap("n", ";a", "zA", opts)

-- quit/write
vim.keymap.del("n", "<c-/>")
vim.keymap.del("n", "<c-_>")
keymap("n", "<c-/>", ":q<CR>", opts)
keymap("n", "<c-'>", ":q!<CR>", opts)
keymap("n", "<c-;>", ":w<CR>", opts)

-- Plugins --

-- vim-tmux-navigator
if os.getenv("TMUX") then
  keymap("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>")
  keymap("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>")
  keymap("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>")
  keymap("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>")
end

-- Custom function to goto ansible roles
-- Define a custom function to search for roles
function Goto_role()
  -- Get the word under the cursor, considering non-alphanumeric characters
  local word = vim.fn.expand("<cWORD>") -- Use <cWORD> instead of <cword>

  -- Define the roles directory relative to the current file's directory
  local current_file_dir = vim.fn.expand("%:p:h")
  local roles_dir = vim.fn.finddir("roles", current_file_dir .. ";")

  -- If the roles directory is found
  if roles_dir and roles_dir ~= "" then
    require("telescope.builtin").find_files({
      search_dirs = { roles_dir }, -- Set the roles directory to search in
      prompt_title = "< Go to Role >",
      default_text = word, -- Use the word under the cursor as the default search term
    })
  else
    print("Roles directory not found.")
  end
end

-- Map the custom function to a keybinding
vim.api.nvim_set_keymap("n", "<leader>gr", ":lua Goto_role()<CR>", { noremap = true, silent = true })

if vim.g.neovide then
  -- Smart paste for GUI clients
  local function paster()
    -- Regular mapping doesn't seem to preserve indentation, so we use the API directly
    vim.api.nvim_paste(vim.fn.getreg("+"), true, -1) -- Use system clipboard
  end
  -- mac
  vim.keymap.set({ "i" }, "<D-v>", paster, { desc = "Neovide smart paste" })
  -- linux/windows
  vim.keymap.set({ "i" }, "<C-S-V>", paster, { desc = "Neovide smart paste" })
end

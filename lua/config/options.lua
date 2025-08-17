-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.maplocalleader = ","
vim.opt.timeoutlen = 1000
vim.opt.updatetime = 100 -- faster completion (4000ms default)
vim.opt.ttimeoutlen = 0
vim.opt.relativenumber = false
-- vim.opt.diffopt:append("vertical")
-- vim.o.shada = "!,'1000,<100,s50,h"
vim.diagnostic.config({ virtual_text = { current_line = true } })

-- Improved version:
-- Make diff mode more readable with vertical splits and better algorithms
vim.opt.diffopt:append({
  "vertical", -- Split diffs vertically
  "algorithm:patience", -- Use patience diff algorithm
  "iwhite", -- Ignore whitespace changes
  "hiddenoff", -- Don't diff hidden buffers
})

-- ShaDa (shared data) settings with explanatory breakdown
vim.o.shada = table.concat({
  "!", -- Save global variables
  "'1000", -- Save marks for 1000 files
  "<100", -- Save register items up to 100 lines each
  "s50", -- Limit size of items in KB
  "h", -- Disable 'hlsearch' when loading
  -- "%", -- Save and restore buffer list
}, ",")

vim.o.clipboard = ""
-- disable LSP log to avoid infinitely growing log file
vim.lsp.log.set_level("off")

-- vim folding
-- ref: https://www.reddit.com/r/neovim/comments/1gi7ush/treesitter_is_amazing/
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldlevelstart = 99

-- for now blink is not working well with codeium
-- ref: https://github.com/LnvimazyVim/LazyVim/discussions/5036#discussioncomment-11560995
-- vim.g.lazyvim_cmp = "nvim-cmp"

-- Animation
-- vim.g.snacks_animate = false
vim.g.snacks_animate_scroll = false
vim.treesitter.language.register("markdown", "vimwiki")

-- Set fold level for HTTP files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  callback = function()
    vim.opt_local.foldlevel = 1
  end,
})

-- CopilotChat
-- For best autocompletion experience, also add popup to your completeopt (even on Neovim 0.11.0+).
vim.opt.completeopt:append({ "noinsert", "popup" })

if vim.g.neovide then
  -- neovide options
  -- Ref: https://github.com/neovide/neovide/blob/a2de54f842bdf7c45f62e578780c12908f6f1e6c/website/docs/configuration.md?plain=1#L835
  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_cursor_trail_size = 0.05
  vim.opt.linespace = 5
  vim.g.neovide_scale_factor = 1.0
  local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  vim.keymap.set("n", "<C-=>", function()
    change_scale_factor(1.25)
  end)
  vim.keymap.set("n", "<C-->", function()
    change_scale_factor(1 / 1.25)
  end)
  -- Set transparency and background color (title bar color)
  vim.g.neovide_transparency = 0.8
  vim.g.neovide_window_blurred = true
  vim.g.neovide_fullscreen = true
  -- vim.o.guifont = "JetBrainsMono Nerd Font:h14" -- text below applies for VimScript
end
-- Set transparency and background color (title bar color)
vim.g.neovide_transparency = 0.8
vim.g.neovide_window_blurred = true
vim.o.guifont = "JetBrainsMono Nerd Font:h14" -- text below applies for VimScript

-- Better symbol support
vim.g.have_nerd_font = true
-- Status bar already have one
vim.o.showmode = false

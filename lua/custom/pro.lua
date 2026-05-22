-- References:
-- snacks.nvim picker : https://github.com/folke/snacks.nvim
-- project.nvim : https://github.com/DrKJeff16/project.nvim
-- reddit: https://www.reddit.com/r/neovim/comments/1i8yy4j/create_a_new_source_directories_for_snackspicker/

-- Function to get project list (lazy-loaded on keypress)
local function get_projects()
  local project_nvim = require("project")
  local snacks = require("snacks")
  snacks.picker.projects({
    projects = project_nvim.get_recent_projects(true),
    confirm = "picker_files",
  })
end
-- Keymap to invoke the custom project picker
vim.keymap.set("n", "<leader>fp", get_projects, { desc = "Show All Projects" })

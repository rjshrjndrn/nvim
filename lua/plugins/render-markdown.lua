return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
  ft = { "markdown", "norg", "rmd", "org", "codecompanion", "vimwiki" },
  opts = {
    checkbox = {
      enabled = true,
      render_modes = false,
      bullet = false,
      left_pad = 0,
      right_pad = 1,
      unchecked = {
        icon = "󰄱 ",
        highlight = "RenderMarkdownUnchecked",
        scope_highlight = nil,
      },
      checked = {
        icon = "󰱒 ",
        highlight = "RenderMarkdownChecked",
        scope_highlight = nil,
      },
      custom = {
        todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo", scope_highlight = nil },
      },
      scope_priority = nil,
    },
  },
  keys = {
    {
      "<leader>tc",
      function()
        -- Cycle through checkbox states: [ ] -> [-] -> [x] -> [ ]
        -- Handles both "- [ ]" and "-[ ]" formats
        local line = vim.api.nvim_get_current_line()
        local new_line = line:match("^%s*-%s*%[ %]") and line:gsub("^(%s*-%s*)%[ %]", "%1[-]")
          or line:match("^%s*-%s*%[-%]") and line:gsub("^(%s*-%s*)%[-%]", "%1[x]")
          or line:match("^%s*-%s*%[x%]") and line:gsub("^(%s*-%s*)%[x%]", "%1[ ]")
          or line:match("^%s*-%s*%[X%]") and line:gsub("^(%s*-%s*)%[X%]", "%1[ ]")
        if new_line then
          vim.api.nvim_set_current_line(new_line)
        end
      end,
      desc = "Toggle markdown checkbox",
      ft = { "markdown", "norg", "rmd", "org", "codecompanion", "vimwiki" },
    },
  },
}

return {
  -- { "towolf/vim-helm", lazy = true, ft = "yaml" },
  {
    "tummetott/unimpaired.nvim",
    event = "VeryLazy",
    opts = {
      -- add options here if you wish to override the default settings
    },
  },
  {
    "junegunn/vim-easy-align",
  },
  {
    "rjshrjndrn/friendly-snippets",
    branch = "patch-1",
  },
  {
    "aymericbeaumet/vim-symlink",
    dependencies = { "moll/vim-bbye" }, -- optional, for better buffer management
    event = "BufReadPre", -- Load just before reading a buffer
    cond = function() -- load only if the current file is a symlink
      -- Check if current file is a symlink
      local stats = vim.uv.fs_lstat(vim.fn.expand("%:p"))
      return stats and stats.type == "link"
    end,
  },
}

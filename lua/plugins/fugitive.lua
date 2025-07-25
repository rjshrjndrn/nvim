local M = {
  {
    "tpope/vim-fugitive",
    lazy = true,
    keys = {
      { "gw", "<cmd>Gwrite<CR>", desc = "Git write" },
      { "<leader>gc", "<cmd>Git commit --sign<CR>", desc = "Git commit signed" },
      { "gs", "<cmd>Git<CR>", desc = "Git status" },
    },
    cmd = { "Git", "Gwrite", "Gdiffsplit", "Gread", "Ggrep", "Glog", "Gclog" },
  },
}

return M

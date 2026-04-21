local M = {
  {
    "vimwiki/vimwiki",
    cmd = "VimwikiIndex",
    event = "BufEnter *.md",
    keys = {
      { "<leader>ww", "<cmd>VimwikiIndex<cr>", desc = "Open VimWiki index" },
      { "<leader>wi", "<cmd>VimwikiDiaryIndex<cr>", desc = "Open VimWiki diary index" },
      { "<leader>w<leader>w", "<cmd>VimwikiMakeDiaryNote<cr>", desc = "Open VimWiki diary entry for today." },
    },
    init = function()
      vim.g.vimwiki_markdown_link_ext = 1
      vim.g.taskwiki_markup_syntax = "markdown"
      vim.g.markdown_folding = 1

      vim.g.vimwiki_list = {
        { path = "~/vimwiki/", syntax = "markdown", ext = ".md" },
        { path = "~/vimwiki_personal/", syntax = "markdown", ext = ".md" },
      }
      vim.g.vimwiki_ext2syntax =
        { [".md"] = "markdown", [".mkd"] = "markdown", [".wiki"] = "media", [".rajesh"] = "markdown" }
      vim.g.vimwiki_folding = ""
      vim.g.vimwiki_listsyms = " ○◐●✓"
    end,
  },
}

return M

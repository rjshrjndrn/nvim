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
      vim.g.vimwiki_folding = "custom"
      vim.g.vimwiki_listsyms = " ○◐●✓"
    end,
    config = function()
      -- Custom folding: headings + <details> blocks
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "vimwiki",
        callback = function()
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.VimwikiFold(v:lnum)"
          vim.wo.foldlevel = 99 -- start unfolded
          vim.wo.foldtext = "v:lua.VimwikiFoldText()"
        end,
      })

      function _G.VimwikiFoldText()
        local fstart = vim.v.foldstart
        local line = vim.fn.getline(fstart)

        -- If fold starts with <details>, look for <summary> on next lines
        if line:match("<details") then
          for i = fstart + 1, math.min(fstart + 3, vim.v.foldend) do
            local next_line = vim.fn.getline(i)
            local summary = next_line:match("<summary>(.-)</summary>")
            if summary then
              local lines = vim.v.foldend - fstart + 1
              return "▶ " .. summary .. " (" .. lines .. " lines)"
            end
          end
          local lines = vim.v.foldend - fstart + 1
          return "▶ <details> (" .. lines .. " lines)"
        end

        -- Default: show first line
        local lines = vim.v.foldend - fstart + 1
        return line .. " (" .. lines .. " lines)"
      end

      function _G.VimwikiFold(lnum)
        local line = vim.fn.getline(lnum)

        -- <details> opens a fold
        if line:match("^%s*<details>") or line:match("^%s*<details%s") then
          return "a1"
        end
        -- </details> closes a fold
        if line:match("^%s*</details>") then
          return "s1"
        end

        -- Markdown headings
        local hashes = line:match("^(#+)%s")
        if hashes then
          return ">" .. #hashes
        end

        return "="
      end
    end,
  },
}

return M

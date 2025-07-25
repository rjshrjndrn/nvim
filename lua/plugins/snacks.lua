return {
  "folke/snacks.nvim",
  opts = function(_, opts)
    opts.dashboard = { enabled = false }
    opts.scratch = {
      ft = "markdown",
      cmd = "Scratch",
      name = "Scratch",
    }
    local t_picker = {}
    local preview_window_opts = {
      input = {
        keys = {
          ["gb"] = {
            "git_browse",
            mode = { "n" },
          },
          ["yc"] = {
            "yank_commit",
            mode = { "n" },
          },
        },
      },
    }
    if LazyVim.has("trouble.nvim") then
      t_picker = {
        actions = {
          trouble_open = function(...)
            return require("trouble.sources.snacks").actions.trouble_open.action(...)
          end,
        },
        keys = {
          ["<a-t>"] = {
            "trouble_open",
            mode = { "n", "i" },
          },
        },
      }
    end
    local gitbrowse = require("snacks.gitbrowse")
    return vim.tbl_deep_extend("force", opts or {}, t_picker, {
      picker = {
        -- Ref: https://github.com/LazyVim/LazyVim/discussions/5723
        -- show hidden files like .env
        hidden = true,
        -- show files ignored by git like node_modules
        ignored = true,
        sources = {
          project = {
            -- show complete path
            show_full_path = true,
          },
          files = {
            ignored = true,
            hidden = true,
          },
          git_log = {
            win = preview_window_opts,
          },
          git_log_line = {
            win = preview_window_opts,
          },
          git_log_file = {
            win = preview_window_opts,
          },
          recent = {
            filter = {
              -- disable filtering by default
              paths = false,
            },
          },
        },
        actions = {
          git_browse = function(picker, item)
            -- picker:close()
            -- vim.notify(vim.inspect(item), vim.log.levels.INFO)
            return gitbrowse.open({ what = "commit", commit = item.commit })
          end,
          yank_commit = function(_, item)
            if item and item.commit then
              vim.fn.setreg("+", item.commit)
              vim.notify("Commit hash yanked: " .. item.commit, vim.log.levels.INFO)
            end
          end,
        },
        win = {
          input = {
            keys = {
              ["<c-x>"] = {
                "cycle_win",
                mode = { "n", "i" },
              },
            },
          },
        },
      },
    })
  end,
}

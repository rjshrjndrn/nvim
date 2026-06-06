return {
  "neovim/nvim-lspconfig",
  ---@param opts PluginLspOpts
  opts = function(_, opts)
    opts.diagnostics = {
      virtual_text = {
        current_line = true,
      },
    }

    -- Wrap in function to defer require until LSP actually attaches
    opts.on_attach = function(client, bufnr)
      require("snacks.util").lsp.on(client, bufnr)
    end

    opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
      pyright = {
        settings = {
          python = {
            pythonPath = ".venv/bin/python",
            venvPath = ".",
            venv = ".venv",
          },
        },
      },
      vtsls = {
        settings = {
          typescript = {
            inlayHints = {
              variableTypes = { enabled = false },
              parameterNames = { enabled = false },
              parameterTypes = { enabled = false },
              propertyDeclarationTypes = { enabled = false },
              functionLikeReturnTypes = { enabled = false },
              enumMemberValues = { enabled = false },
            },
          },
          javascript = {
            inlayHints = {
              variableTypes = { enabled = false },
              parameterNames = { enabled = false },
              parameterTypes = { enabled = false },
              propertyDeclarationTypes = { enabled = false },
              functionLikeReturnTypes = { enabled = false },
              enumMemberValues = { enabled = false },
            },
          },
        },
      },
      gopls = {
        settings = {
          gopls = {
            hints = {
              assignVariableTypes = false,
              compositeLiteralFields = false,
              compositeLiteralTypes = false,
              constantValues = false,
              functionTypeParameters = false,
              parameterNames = false,
              rangeVariableTypes = false,
            },
            usePlaceholders = true,
          },
        },
      },
      yamlls = {
        filetypes = { "yml", "yaml" },
        settings = {
          redhat = { telemetry = { enabled = false } },
          yaml = {
            keyOrdering = false,
            format = {
              enable = false,
            },
            validate = true,
            schemaStore = {
              enable = false,
              url = "",
            },
            -- Deferred: require only runs when lspconfig loads, not at startup
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      },
      bashls = {
        filetypes = { "sh", "bash" },
      },
      ansiblels = {
        filetypes = { "yaml.ansible" },
      },
      nil_ls = {
        mason = false,
        setup = {
          cmd = { "nil" },
        },
      },
    })
  end,
}

return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      virtual_text = {
        current_line = true,
      },
    },
    -- options for vim.diagnostic.config()
    -- LSP Server Settings
    ---@type lspconfig.options
    servers = {
      terraformls = {
        filetypes = { "tf", "terraform", "terraform-vars" },
      },
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
        -- lazy-load schemastore when needed
        settings = {
          redhat = { telemetry = { enabled = false } },
          yaml = {
            keyOrdering = false,
            format = {
              enable = false,
            },
            validate = true,
            schemaStore = {
              -- Must disable built-in schemaStore support to use
              -- schemas from SchemaStore.nvim plugin
              enable = false,
              -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
              url = "",
            },
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
    },
    -- setup = {
    --   yamlls = function(server, opts)
    --     opts.on_attach = function(client, bufnr)
    --       vim.diagnostic.config({ virtual_text = false, signs = false }, bufnr)
    --     end
    --     require("lspconfig")[server].setup(opts)
    --   end,
    -- },
  },
}

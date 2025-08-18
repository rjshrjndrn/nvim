-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local autocmd = vim.api.nvim_create_autocmd

-- Disable undo for specific file types (like encrypted files)
autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.age", "*.gpg", "*.enc", "*.encrypted" },
  callback = function()
    vim.opt_local.undofile = false -- Disable persistent undo
    -- vim.opt_local.undolevels = -1 -- Disable undo completely for the buffer
    vim.opt_local.swapfile = false -- Also good to disable swap for encrypted files
    vim.opt_local.backup = false -- No backup files
    vim.opt_local.writebackup = false -- No backup while writing
  end,
})

-- Consider mustache as helm ft
autocmd("FileType", {
  pattern = { "mustache" },
  callback = function()
    if vim.fn.expand("%:e") == "tpl" then
      vim.bo.filetype = "helm"
    end
  end,
})

-- Create a schema mapping table for better organization
local schema_mappings = {
  ["argocd-applicationset"] = {
    pattern = "^kind:%s*ApplicationSet%s*$",
    schema = "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/applicationset_v1alpha1.json",
  },
  ["argocd-application"] = {
    pattern = "^kind:%s*Application%s*$",
    schema = "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/application_v1alpha1.json",
  },
}

-- Create automatic file type detection for YAML files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.yaml", "*.yml" },
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
    for _, line in ipairs(lines) do
      for filetype, config in pairs(schema_mappings) do
        if line:match(config.pattern) then
          vim.notify("Detected schema: " .. config.schema, vim.log.levels.INFO)
          vim.bo.filetype = filetype
          vim.b.yaml_schema = config.schema

          -- Notify LSP about schema change
          vim.schedule(function()
            local clients = vim.lsp.get_clients({ name = "yamlls" })
            for _, client in ipairs(clients) do
              if client.attached_buffers[vim.api.nvim_get_current_buf()] then
                local buf_uri = vim.uri_from_bufnr(0)
                local settings = client.config.settings or {}
                settings.yaml = settings.yaml or {}
                settings.yaml["schemas"] = settings.yaml.schemas or {}
                settings.yaml.schemas[config.schema] = buf_uri

                client.notify("workspace/didChangeConfiguration", {
                  settings = settings,
                })
              end
            end
          end)
          return
        end
      end
    end
  end,
})

-- Register the new filetypes (FIXED)
-- Note: This approach won't work as expected because vim.filetype.add()
-- expects file extensions, not custom filetypes
-- Instead, we'll register them as yaml variants
vim.filetype.add({
  pattern = {
    [".*%.argocd%-application%.ya?ml"] = "argocd-application",
    [".*%.argocd%-applicationset%.ya?ml"] = "argocd-applicationset",
  },
})

-- Register treesitter mappings (FIXED)
for filetype, _ in pairs(schema_mappings) do
  vim.treesitter.language.register("yaml", filetype)
end

-- Optional: Create user commands for manual schema injection
vim.api.nvim_create_user_command("InjectSchema", function(opts)
  local filetype = opts.args ~= "" and opts.args or vim.bo.filetype
  local config = schema_mappings[filetype]

  if not config then
    vim.notify("No schema found for filetype: " .. filetype, vim.log.levels.WARN)
    return
  end

  vim.b.yaml_schema = config.schema
  vim.notify("Schema set: " .. config.schema, vim.log.levels.INFO)
end, {
  nargs = "?",
  complete = function()
    return vim.tbl_keys(schema_mappings)
  end,
  desc = "Inject schema for current buffer",
})
-- Ensure schema is applied when yamlls attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "yamlls" then
      local buf_schema = vim.b[args.buf].yaml_schema
      if buf_schema then
        vim.schedule(function()
          local buf_uri = vim.uri_from_bufnr(args.buf)

          -- Ensure settings structure exists
          client.config.settings = client.config.settings or {}
          client.config.settings.yaml = client.config.settings.yaml or {}
          client.config.settings.yaml.schemas = client.config.settings.yaml.schemas or {}

          -- Set the schema for this specific file
          client.config.settings.yaml.schemas[buf_schema] = buf_uri

          -- Send configuration change to the server
          client.notify("workspace/didChangeConfiguration", {
            settings = client.config.settings,
          })

          vim.notify("Schema reapplied on LSP attach: " .. buf_schema, vim.log.levels.INFO)
        end)
      end
    end
  end,
})

-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Disable undo for specific file types (like encrypted files)
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.age", "*.gpg", "*.enc", "*.encrypted" },
  callback = function()
    vim.opt_local.undofile = false -- Disable persistent undo
    -- vim.opt_local.undolevels = -1 -- Disable undo completely for the buffer
    vim.opt_local.swapfile = false -- Also good to disable swap for encrypted files
    vim.opt_local.backup = false -- No backup files
    vim.opt_local.writebackup = false -- No backup while writing
  end,
})

-- Create a schema mapping table for better organization
local schema_mappings = {
  ["argocd-applicationset"] = {
    pattern = "^kind:%s*ApplicationSet",
    schema = "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/applicationset_v1alpha1.json",
  },
  ["argocd-application"] = {
    pattern = "^kind:%s*Application",
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
          vim.bo.filetype = filetype
          vim.b.yaml_schema = config.schema
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

-- Optional: Add LSP configuration that uses the schema
local function setup_yaml_lsp()
  -- Check if you have lspconfig
  local ok, lspconfig = pcall(require, "lspconfig")
  if not ok then
    return
  end

  -- Create schemas table for yamlls
  local schemas = {}
  for filetype, config in pairs(schema_mappings) do
    -- Map schema to file pattern
    schemas[config.schema] = string.format("*%s.{yaml,yml}", filetype)
  end

  lspconfig.yamlls.setup({
    settings = {
      yaml = {
        schemas = schemas,
        validate = true,
        completion = true,
        hover = true,
        schemaStore = {
          enable = true,
          url = "https://www.schemastore.org/api/json/catalog.json",
        },
      },
    },
    on_attach = function(client, bufnr)
      -- Check if buffer has a schema and apply it
      local schema_url = vim.b.yaml_schema
      if schema_url then
        local buf_uri = vim.uri_from_bufnr(bufnr)
        local settings = client.config.settings or {}
        settings.yaml = settings.yaml or {}
        settings.yaml.schemas = settings.yaml.schemas or {}
        settings.yaml.schemas[schema_url] = buf_uri

        client.notify("workspace/didChangeConfiguration", {
          settings = settings,
        })
      end
    end,
  })
end

-- Call the setup function
setup_yaml_lsp()

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

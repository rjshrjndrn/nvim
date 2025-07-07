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
-- Create automatic file type for argocd, so that the argomanifest schema can be used from yamllsp
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.yaml", "*.yml" },
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
    for _, line in ipairs(lines) do
      if line:match("^kind:%s*ApplicationSet") then
        vim.bo.filetype = "argocd-applicationset"
        return
      elseif line:match("^kind:%s*Application") then
        vim.bo.filetype = "argocd-application"
        return
      end
    end
  end,
})
-- register these new filetypes
vim.filetype.add({
  extension = {
    ["argocd-applicationset"] = "yaml",
    ["argocd-application"] = "yaml",
  },
})
vim.treesitter.language.register("yaml", "argocd-applicationset")
vim.treesitter.language.register("yaml", "argocd-application")

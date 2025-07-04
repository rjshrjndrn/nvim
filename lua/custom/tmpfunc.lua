-- This is tmp scrap function to do local processing
local function cleanup()
  vim.cmd("g/vars.csv/d")
  vim.cmd("g/\\/values.yaml/d")
  vim.cmd("%s/|\\d\\+ col \\d\\+|/,/g")
end

vim.api.nvim_create_user_command("Cleanup", function()
  cleanup()
end, {})
return cleanup

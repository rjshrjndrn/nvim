return {
  -- "rjshrjndrn/pi.nvim",
  dir = "/home/skyent/Documents/Projects/pi.nvim",
  config = function()
    require("pi").setup({
      -- defaults are fine, or override:
      -- pi = { extra_args = { "--model", "sonnet" } },
    })
  end,
}

return {
  "rjshrjndrn/pi.nvim",
  config = function()
    require("pi.backends").register("omp", { bin = "omp" })
    require("pi").setup({
      backend = "omp",
      -- defaults are fine, or override:
      -- pi = { extra_args = { "--model", "sonnet" } },
    })
  end,
}

return {
  "saghen/blink.cmp",
  dependencies = "rafamadriz/friendly-snippets",
  version = "*",
  opts = {
    -- keymap = { preset = "default" },
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
      },
    },
    signature = {
      enabled = true,
    },
  },
  opts_extend = { "sources.default" },
}

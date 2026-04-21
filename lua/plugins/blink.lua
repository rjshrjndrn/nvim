return {
  "saghen/blink.cmp",
  dependencies = "rafamadriz/friendly-snippets",
  version = "*",
  opts = {
    -- keymap = { preset = "default" },
    sources = {
      min_keyword_length = 3,
    },
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

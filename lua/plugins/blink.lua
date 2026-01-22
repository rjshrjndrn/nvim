return {
  "saghen/blink.cmp",
  dependencies = "rafamadriz/friendly-snippets",
  version = "*",
  opts = {
    -- keymap = { preset = "default" },
    appearance = {
      -- use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = {
          border = "rounded",
        },
      },
      menu = {
        border = "rounded",
      },
    },
    signature = {
      enabled = true,
      window = {
        border = "rounded",
      },
    },
  },
  opts_extend = { "sources.default" },
}

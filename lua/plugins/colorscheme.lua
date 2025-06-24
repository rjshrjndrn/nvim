local color = {
  "EdenEast/nightfox.nvim",
  lazy = true,
  opts = function(_, opts)
    opts.options = {
      transparent = false,
      dim_inactive = false, -- Non focused panes set to alternative background
      styles = {
        comments = "italic",
        keywords = "bold",
        types = "italic,bold",
      },
    }
  end,
}
return {
  color,
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "duskfox",
    },
  },
}

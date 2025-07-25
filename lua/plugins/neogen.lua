return {
  "danymat/neogen",
  cmd = "Neogen",
  keys = {
    {
      "<leader>cn",
      function()
        require("neogen").generate()
      end,
      desc = "Generate docstring",
    },
  },
  opts = function(_, opts)
    -- https://github.com/danymat/neogen?tab=readme-ov-file#configuration
    opts.languages = {
      ["bash"] = require("neogen.configurations.sh"),
    }
  end,
}

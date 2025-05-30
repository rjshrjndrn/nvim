return {
  "danymat/neogen",
  opts = function(_, opts)
    -- https://github.com/danymat/neogen?tab=readme-ov-file#configuration
    opts.languages = {
      ["bash"] = require("neogen.configurations.sh"),
    }
  end,
}

return {
  "CopilotC-Nvim/CopilotChat.nvim",
  opts = {
    model = "claude-sonnet-4",
    prompts = {
      Explain = "Write an comprehensive explanation for the selected code.",
    },
    sticky = {
      "#buffer",
    },
    mappings = {
      reset = {
        normal = "<C-r>",
        insert = "<C-r>",
      },
    },
  },
}

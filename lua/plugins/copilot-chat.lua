return {
  "CopilotC-Nvim/CopilotChat.nvim",
  opts = {
    model = "claude-sonnet-4",
    prompts = {
      Explain = "Write an comprehensive explanation for the selected code.",
      Commit = {
        prompt = "Write commit message starts with for the change with commitizen convention. Keep the title under 50 characters and wrap message at 72 characters. Format as a gitcommit code block.",
        context = "git:staged",
        model = "gpt-4.1",
      },
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

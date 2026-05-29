---@type LazySpec
return {
  {
    "adamt94/Lunarvim",
    branch = "feat/plugin-api",
    name = "lunarvim-threads",
    event = "VeryLazy",
    dependencies = {
      "nvim-telescope/telescope.nvim", -- for directory picker in sidebar
    },
    config = function()
      require("lunarvim").setup()
    end,
  },
}

local terminals = require "utils.assistant_terminals"

---@type LazySpec
return {
  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      terminals.setup_autocmds()

      require("claude-code").setup {
        window = {
          position = "float",
          float = {
            width = "90%",
            height = "90%",
            row = "center",
            col = "center",
            relative = "editor",
            border = "rounded",
          },
        },
        keymaps = {
          close = {
            terminal = "<C-q>",
          },
        },
      }
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    init = function() terminals.set_nvim_env() end,
    opts = function(_, opts)
      terminals.setup_autocmds()

      local old_on_open = opts.on_open
      local old_on_exit = opts.on_exit

      opts.float_opts = vim.tbl_deep_extend("force", opts.float_opts or {}, {
        border = "single",
      })
      opts.close_on_exit = false
      opts.on_open = function(term)
        if old_on_open then old_on_open(term) end
        terminals.on_toggleterm_open(term)
      end
      opts.on_exit = function(term, job, exit_code, name)
        if old_on_exit then old_on_exit(term, job, exit_code, name) end
        terminals.on_toggleterm_exit(term)
      end
    end,
  },
}

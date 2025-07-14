-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },
  {
    "greggh/claude-code.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("claude-code").setup({
        window = {
          position = "float",
          float = {
            width = "90%",
            height = "90%",
            row = "center",
            col = "center",
            relative = "editor",
            border = "rounded"
          }
        }
      })
      
      -- Auto-close floating terminal when Claude process terminates
      vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*claude*",
        callback = function()
          vim.cmd("close")
        end,
      })
    end,
  },

  -- == Examples of Overriding Plugins ==

  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        " █████  ███████ ████████ ██████   ██████",
        "██   ██ ██         ██    ██   ██ ██    ██",
        "███████ ███████    ██    ██████  ██    ██",
        "██   ██      ██    ██    ██   ██ ██    ██",
        "██   ██ ███████    ██    ██   ██  ██████",
        " ",
        "    ███    ██ ██    ██ ██ ███    ███",
        "    ████   ██ ██    ██ ██ ████  ████",
        "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
        "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
        "    ██   ████   ████   ██ ██      ██",
      }
      return opts
    end,
  },

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      -- Add mappings for numbered floating terminals
      for i = 1, 3 do
        opts.mappings.n["<leader>t" .. i] = {
          function() require("toggleterm").toggle(i, nil, nil, "float") end,
          desc = "Toggle floating terminal " .. i,
        }
      end
      -- Add mapping for the last used terminal
      opts.mappings.n["<leader>tt"] = { "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle last floating terminal" }
      return opts
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    opts = {
      -- Set floating terminal options
      float_opts = {
        border = "single",
      },
      -- Hide the terminal when it's closed
      close_on_exit = false,
      -- Function to run on opening a terminal
      on_open = function(term)
        -- Enter insert mode automatically
        vim.cmd("startinsert!")
        -- Map <esc> to hide the terminal, but not for lazygit
        local is_lazygit_float = term.direction == "float" and string.find(term.cmd or "", "lazygit")
        if not is_lazygit_float then
          vim.api.nvim_buf_set_keymap(
            term.bufnr,
            "t",
            "<esc>",
            string.format("<cmd>lua require('toggleterm').toggle(%d)<CR>", term.id),
            { noremap = true, silent = true }
          )
        else
          -- Map 'q' to hide the lazygit terminal
          vim.api.nvim_buf_set_keymap(
            term.bufnr,
            "t",
            "q",
            string.format("<cmd>lua require('toggleterm').toggle(%d)<CR>", term.id),
            { noremap = true, silent = true }
          )
        end
      end,
      on_exit = function(term)
        -- Close the terminal buffer when lazygit exits
        if string.find(term.cmd or "", "lazygit") then
          term:hide()
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(term.bufnr) then
              vim.api.nvim_buf_delete(term.bufnr, { force = true })
            end
          end)
        end
      end,
    },
  }
}

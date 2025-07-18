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
        },
        keymaps = {
          close = {
            terminal = "<Esc>", -- Use escape key to close Claude Code terminal
          },
        }
      })
      
      -- Auto-close floating terminal when Claude process terminates
      vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*claude*",
        callback = function(args)
          local bufnr = args.buf
          -- Find and close the window containing this buffer
          for _, winid in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(winid) == bufnr then
              vim.api.nvim_win_close(winid, true)
              break
            end
          end
          -- Delete the buffer to prevent naming conflicts
          vim.schedule(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
              vim.api.nvim_buf_delete(bufnr, { force = true })
            end
          end)
        end,
      })
      
      -- Override ESC key in Claude Code terminals to close the terminal
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "*claude*",
        callback = function()
          vim.api.nvim_buf_set_keymap(0, "t", "<Esc>", "<C-\\><C-n>:close<CR>", { noremap = true, silent = true })
        end,
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    config = function()
      require("CopilotChat").setup({
        debug = false,
        window = {
          layout = "float",
          width = 0.9,
          height = 0.9,
          border = "rounded",
          title = "Copilot Chat",
        },
        chat = {
          welcome_message = "Hello! I'm GitHub Copilot. How can I help you today?",
          loading_text = "Loading...",
          question_sign = "",
          answer_sign = "",
          error_text = "Error: ",
          separator = "---",
        },
        prompts = {
          Explain = {
            prompt = "/COPILOT_EXPLAIN Write an explanation for the active selection as paragraphs of text.",
          },
          Review = {
            prompt = "/COPILOT_REVIEW Review the selected code.",
          },
          Fix = {
            prompt = "/COPILOT_GENERATE There is a problem in this code. Rewrite the code to show it with the bug fixed.",
          },
          Optimize = {
            prompt = "/COPILOT_GENERATE Optimize the selected code to improve performance and readability.",
          },
          Docs = {
            prompt = "/COPILOT_GENERATE Please add documentation comment for the selection.",
          },
          Tests = {
            prompt = "/COPILOT_GENERATE Please generate tests for my code.",
          },
          FixDiagnostic = {
            prompt = "Please assist with the following diagnostic issue in file:",
          },
          Commit = {
            prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
          },
          CommitStaged = {
            prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
          },
        },
        mappings = {
          complete = {
            detail = "Use @<Tab> or /<Tab> for options.",
            insert = "<Tab>",
          },
          close = {
            normal = "<Esc>",
            insert = "<Esc>",
          },
          reset = {
            normal = "<C-r>",
            insert = "<C-r>",
          },
          submit_prompt = {
            normal = "<CR>",
            insert = "<C-CR>",
          },
          accept_diff = {
            normal = "<C-y>",
            insert = "<C-y>",
          },
          yank_diff = {
            normal = "gy",
          },
          show_diff = {
            normal = "gd",
          },
          show_info = {
            normal = "gp",
          },
          show_context = {
            normal = "gs",
          },
        },
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
      -- Add Copilot Chat keybinding
      opts.mappings.n["<leader>cx"] = { "<cmd>CopilotChat<cr>", desc = "Open Copilot Chat" }
      -- Add Claude Code keybindings
      opts.mappings.n["<leader>v"] = { "<cmd>ClaudeCode<cr>", desc = "Claude Code Toggle" }
      opts.mappings.n["<leader>cr"] = { "<cmd>ClaudeCodeResume<cr>", desc = "Claude Code Resume" }
      opts.mappings.n["<leader>ct"] = { "<cmd>ClaudeCodeContinue<cr>", desc = "Claude Code Continue" }
      -- Add keymap search
      opts.mappings.n["<leader>k"] = { "<cmd>Telescope keymaps<cr>", desc = "Search all keymaps" }
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
        -- Map <esc> to hide the terminal, but not for lazygit or claude
        local is_lazygit_float = term.direction == "float" and string.find(term.cmd or "", "lazygit")
        local is_claude_float = term.direction == "float" and string.find(term.cmd or "", "claude")
        if not is_lazygit_float and not is_claude_float then
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

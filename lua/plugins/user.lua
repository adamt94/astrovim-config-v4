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
            terminal = "<C-c>", -- Use Ctrl+C to close Claude Code terminal instead of Esc
          },
        },
      }

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
            if vim.api.nvim_buf_is_valid(bufnr) then vim.api.nvim_buf_delete(bufnr, { force = true }) end
          end)
        end,
      })

      -- Override Ctrl+C key in Claude Code terminals to close the terminal (allow Esc for Claude's navigation)
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "*claude*",
        callback = function()
          vim.api.nvim_buf_set_keymap(0, "t", "<C-c>", "<C-\\><C-n>:close<CR>", { noremap = true, silent = true })
        end,
      })

      -- Close Claude Code and Gemini CLI floating terminals when clicking outside
      vim.api.nvim_create_autocmd("WinEnter", {
        pattern = "*",
        callback = function()
          local current_win = vim.api.nvim_get_current_win()

          -- Check if we clicked outside a Claude Code, Gemini CLI, or Copilot CLI terminal
          for _, winid in ipairs(vim.api.nvim_list_wins()) do
            if winid ~= current_win then
              local buf = vim.api.nvim_win_get_buf(winid)
              local buf_name = vim.api.nvim_buf_get_name(buf)
              local win_config = vim.api.nvim_win_get_config(winid)

              -- Check if this is a floating Claude Code, Gemini CLI, or Copilot CLI terminal
              if
                (string.find(buf_name, "claude") or string.find(buf_name, "gemini") or string.find(buf_name, "copilot"))
                and win_config.relative ~= ""
              then
                -- Close the floating window
                vim.api.nvim_win_close(winid, true)
              end
            end
          end
        end,
      })

      -- Auto-close floating terminal when Gemini process terminates
      vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*gemini*",
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
            if vim.api.nvim_buf_is_valid(bufnr) then vim.api.nvim_buf_delete(bufnr, { force = true }) end
          end)
        end,
      })

      -- Override Ctrl+C key in Gemini CLI terminals to close the terminal (allow Esc for navigation)
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "*gemini*",
        callback = function()
          vim.api.nvim_buf_set_keymap(0, "t", "<C-c>", "<C-\\><C-n>:close<CR>", { noremap = true, silent = true })
        end,
      })

      -- Auto-close floating terminal when GitHub Copilot CLI process terminates
      vim.api.nvim_create_autocmd("TermClose", {
        pattern = "*copilot*",
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
            if vim.api.nvim_buf_is_valid(bufnr) then vim.api.nvim_buf_delete(bufnr, { force = true }) end
          end)
        end,
      })

      -- Override Ctrl+C key in GitHub Copilot CLI terminals to close the terminal (allow Esc for navigation)
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "*copilot*",
        callback = function()
          vim.api.nvim_buf_set_keymap(0, "t", "<C-c>", "<C-\\><C-n>:close<CR>", { noremap = true, silent = true })
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
      require("CopilotChat").setup {
        debug = false,
        window = {
          layout = "float",
          width = math.floor(vim.o.columns * 0.9),
          height = math.floor(vim.o.lines * 0.9),
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
      }
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
      -- Global storage for special terminals and last active terminal tracking
      _G.special_terminals = _G.special_terminals or {}
      _G.last_active_terminal = _G.last_active_terminal or { type = "normal", id = 1 }

      -- Helper function to track last active terminal
      local function track_terminal(type, id_or_instance)
        _G.last_active_terminal = { type = type, id_or_instance = id_or_instance }
      end

      -- Add mappings for numbered floating terminals
      for i = 1, 3 do
        opts.mappings.n["<leader>t" .. i] = {
          function()
            require("toggleterm").toggle(i, nil, nil, "float")
            track_terminal("normal", i)
          end,
          desc = "Toggle floating terminal " .. i,
        }
      end

      -- Add mapping for the last used terminal (including special terminals)
      opts.mappings.n["<leader>tt"] = {
        function()
          local last = _G.last_active_terminal
          if last.type == "normal" then
            require("toggleterm").toggle(last.id_or_instance, nil, nil, "float")
          elseif last.type == "copilot" and _G.special_terminals.copilot then
            _G.special_terminals.copilot:toggle()
          elseif last.type == "gemini" and _G.special_terminals.gemini then
            _G.special_terminals.gemini:toggle()
          elseif last.type == "claude" then
            vim.cmd "ClaudeCode"
          else
            -- Fallback to terminal 1 if no last terminal is tracked
            require("toggleterm").toggle(1, nil, nil, "float")
            track_terminal("normal", 1)
          end
        end,
        desc = "Toggle last floating terminal",
      }

      -- Add AI Assistant keybindings (moved from <leader>c to avoid conflicts with buffer close)
      opts.mappings.n["<leader>ax"] = { "<cmd>CopilotChat<cr>", desc = "Open Copilot Chat" }

      -- Add Claude Code keybindings
      opts.mappings.n["<leader>v"] = {
        function()
          vim.cmd "ClaudeCode"
          track_terminal("claude", nil)
        end,
        desc = "Claude Code Toggle",
      }
      opts.mappings.n["<leader>av"] = {
        function()
          vim.cmd "ClaudeCode"
          track_terminal("claude", nil)
        end,
        desc = "Claude Code",
      }
      opts.mappings.n["<leader>ar"] = { "<cmd>ClaudeCodeResume<cr>", desc = "Claude Code Resume" }

      -- GitHub Copilot CLI mapping - reuse existing terminal instance
      opts.mappings.n["<leader>ap"] = {
        function()
          if not _G.special_terminals.copilot then
            -- Create a floating terminal for GitHub Copilot CLI
            local Terminal = require("toggleterm.terminal").Terminal
            _G.special_terminals.copilot = Terminal:new {
              cmd = "copilot",
              direction = "float",
              float_opts = {
                border = "curved",
                width = math.floor(vim.o.columns * 0.9),
                height = math.floor(vim.o.lines * 0.9),
              },
              on_open = function(term)
                track_terminal("copilot", term)
                vim.api.nvim_buf_set_keymap(
                  term.bufnr,
                  "t",
                  "<C-c>",
                  "<cmd>lua _G.special_terminals.copilot:toggle()<CR>",
                  { noremap = true, silent = true }
                )
              end,
              on_exit = function(term)
                -- Clean up the terminal instance when process exits
                vim.schedule(function()
                  if vim.api.nvim_buf_is_valid(term.bufnr) then
                    vim.api.nvim_buf_delete(term.bufnr, { force = true })
                  end
                  _G.special_terminals.copilot = nil
                end)
              end,
            }
          end
          _G.special_terminals.copilot:toggle()
          track_terminal("copilot", _G.special_terminals.copilot)
        end,
        desc = "Copilot CLI",
      }

      -- Add Gemini CLI keybindings - remove duplicate, keep only <leader>ag
      opts.mappings.n["<leader>ag"] = {
        function()
          if not _G.special_terminals.gemini then
            -- Create a floating terminal for Gemini CLI
            local Terminal = require("toggleterm.terminal").Terminal
            _G.special_terminals.gemini = Terminal:new {
              cmd = "gemini",
              direction = "float",
              float_opts = {
                border = "curved",
              },
              on_open = function(term)
                track_terminal("gemini", term)
                vim.api.nvim_buf_set_keymap(
                  term.bufnr,
                  "t",
                  "<C-c>",
                  "<cmd>lua _G.special_terminals.gemini:toggle()<CR>",
                  { noremap = true, silent = true }
                )
              end,
              on_exit = function(term)
                -- Clean up the terminal instance when process exits
                vim.schedule(function()
                  if vim.api.nvim_buf_is_valid(term.bufnr) then
                    vim.api.nvim_buf_delete(term.bufnr, { force = true })
                  end
                  _G.special_terminals.gemini = nil
                end)
              end,
            }
          end
          _G.special_terminals.gemini:toggle()
          track_terminal("gemini", _G.special_terminals.gemini)
        end,
        desc = "Gemini CLI",
      }

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
        vim.cmd "startinsert!"

        -- Track normal terminals when they're opened
        if term.direction == "float" then
          -- Update last active terminal tracking for normal terminals
          if
            not (
              string.find(term.cmd or "", "lazygit")
              or string.find(term.cmd or "", "claude")
              or string.find(term.cmd or "", "gemini")
              or string.find(term.cmd or "", "copilot")
            )
          then
            _G.last_active_terminal = { type = "normal", id_or_instance = term.id }
          end

          -- Add Ctrl+C as a universal close option for ALL floating terminals
          vim.api.nvim_buf_set_keymap(
            term.bufnr,
            "t",
            "<C-c>",
            string.format("<cmd>lua require('toggleterm').toggle(%d)<CR>", term.id),
            { noremap = true, silent = true }
          )
        end

        -- Map <esc> to hide the terminal, but not for lazygit, claude, gemini, or copilot cli
        local is_lazygit_float = term.direction == "float" and string.find(term.cmd or "", "lazygit")
        local is_claude_float = term.direction == "float" and string.find(term.cmd or "", "claude")
        local is_gemini_float = term.direction == "float" and string.find(term.cmd or "", "gemini")
        local is_copilot_cli_float = term.direction == "float" and string.find(term.cmd or "", "copilot")
        if not is_lazygit_float and not is_claude_float and not is_gemini_float and not is_copilot_cli_float then
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
            if vim.api.nvim_buf_is_valid(term.bufnr) then vim.api.nvim_buf_delete(term.bufnr, { force = true }) end
          end)
        end
      end,
    },
  },

  -- Configure hardtime plugin
  {
    "m4xshen/hardtime.nvim",
    opts = {
      enabled = true,
      disable_mouse = false,
      disabled_keys = {
        ["<Up>"] = {},
        ["<Down>"] = {},
        ["<Left>"] = {},
        ["<Right>"] = {},
      },
      restriction_mode = "hint",
      hint = true,
      max_count = 5,
      allow_different_key = true,
    },
  },
}

-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = function(_, opts)
    opts.features = vim.tbl_deep_extend("force", opts.features or {}, {
      large_buf = { size = 1024 * 500, lines = 10000 },
      diagnostics = { virtual_text = true, virtual_lines = false },
      highlighturl = true,
      notifications = true,
    })

    opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics or {}, {
      virtual_text = true,
      underline = true,
    })

    opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
      opt = {
        relativenumber = true,
        number = true,
        spell = false,
        signcolumn = "auto",
        wrap = false,
      },
    })

    opts.mappings = opts.mappings or {}
    opts.mappings.n = opts.mappings.n or {}

    local terminals = require "utils.assistant_terminals"

    opts.mappings.n.L = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" }
    opts.mappings.n.H = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" }
    opts.mappings.n["<Leader>bD"] = {
      function()
        require("astroui.status.heirline").buffer_picker(function(bufnr) require("astrocore.buffer").close(bufnr) end)
      end,
      desc = "Pick to close",
    }
    opts.mappings.n["<Leader>b"] = { desc = "Buffers" }

    for i = 1, 3 do
      opts.mappings.n["<leader>t" .. i] = {
        function() terminals.toggle_normal_terminal(i) end,
        desc = "Toggle floating terminal " .. i,
      }
    end

    opts.mappings.n["<leader>tt"] = {
      function() terminals.toggle_last_terminal() end,
      desc = "Toggle last floating terminal",
    }
    opts.mappings.n["<leader>aO"] = {
      function() terminals.toggle_special_terminal("opencode", "opencode") end,
      desc = "OpenCode CLI (floating)",
    }
    opts.mappings.n["<leader>ac"] = {
      function() terminals.toggle_special_terminal("copilot", "copilot") end,
      desc = "Copilot CLI",
    }
    opts.mappings.n["<leader>ag"] = {
      function() terminals.toggle_special_terminal("gemini", "gemini") end,
      desc = "Gemini CLI",
    }
    opts.mappings.n["<leader>v"] = {
      function()
        vim.cmd "ClaudeCode"
        terminals.track_claude_terminal()
      end,
      desc = "Claude Code Toggle",
    }
    opts.mappings.n["<leader>av"] = {
      function()
        vim.cmd "ClaudeCode"
        terminals.track_claude_terminal()
      end,
      desc = "Claude Code",
    }
    opts.mappings.n["<leader>ar"] = { "<cmd>ClaudeCodeResume<cr>", desc = "Claude Code Resume" }
    opts.mappings.n["<leader>k"] = { "<cmd>Telescope keymaps<cr>", desc = "Search all keymaps" }
  end,
}

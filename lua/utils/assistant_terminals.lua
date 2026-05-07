local M = {}

local state = {
  special_terminals = {},
  last_active_terminal = { type = "normal", id_or_instance = 1 },
  autocmds_configured = false,
}

local special_terminal_names = {
  claude = true,
  copilot = true,
  gemini = true,
  opencode = true,
}

local function track_terminal(term_type, id_or_instance)
  state.last_active_terminal = { type = term_type, id_or_instance = id_or_instance }
end

local function close_buffer_window(bufnr)
  for _, winid in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(winid) == bufnr then
      pcall(vim.api.nvim_win_close, winid, true)
      break
    end
  end
end

local function delete_buffer(bufnr)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(bufnr) then vim.api.nvim_buf_delete(bufnr, { force = true }) end
  end)
end

local function contains_any(value, patterns)
  for _, pattern in ipairs(patterns) do
    if string.find(value, pattern) then return true end
  end
  return false
end

local function is_special_buf_name(buf_name)
  for name in pairs(special_terminal_names) do
    if string.find(buf_name, name) then return true end
  end
  return false
end

local function is_managed_special_cmd(cmd)
  return contains_any(cmd or "", { "claude", "copilot", "gemini", "opencode" })
end

local function set_toggleterm_close_key(term)
  vim.keymap.set("t", "<C-q>", function()
    require("toggleterm").toggle(term.id)
  end, { buffer = term.bufnr, remap = false, silent = true })
end

local function set_special_close_key(term, name)
  vim.keymap.set("t", "<C-q>", function()
    local instance = state.special_terminals[name]
    if instance then instance:toggle() end
  end, { buffer = term.bufnr, remap = false, silent = true })
end

local function create_special_terminal(name, cmd)
  if state.special_terminals[name] then return state.special_terminals[name] end

  local Terminal = require("toggleterm.terminal").Terminal
  state.special_terminals[name] = Terminal:new {
    cmd = cmd,
    direction = "float",
    env = {
      NVIM = vim.v.servername,
    },
    float_opts = {
      border = "curved",
    },
    on_open = function(term)
      M.on_toggleterm_open(term)
      track_terminal(name, term)
      set_special_close_key(term, name)
    end,
    on_exit = function(term)
      M.on_toggleterm_exit(term)
      delete_buffer(term.bufnr)
      state.special_terminals[name] = nil
    end,
  }

  return state.special_terminals[name]
end

function M.setup_autocmds()
  if state.autocmds_configured then return end
  state.autocmds_configured = true

  local group = vim.api.nvim_create_augroup("assistant_terminal_management", { clear = true })

  vim.api.nvim_create_autocmd("TermClose", {
    group = group,
    pattern = "*claude*",
    callback = function(args)
      close_buffer_window(args.buf)
      delete_buffer(args.buf)
    end,
  })

  vim.api.nvim_create_autocmd("TermOpen", {
    group = group,
    pattern = "*claude*",
    callback = function(args)
      vim.keymap.set("t", "<C-q>", "<C-\\><C-n>:close<CR>", { buffer = args.buf, remap = false, silent = true })
    end,
  })

  vim.api.nvim_create_autocmd("WinEnter", {
    group = group,
    pattern = "*",
    callback = function()
      local current_win = vim.api.nvim_get_current_win()
      for _, winid in ipairs(vim.api.nvim_list_wins()) do
        if winid ~= current_win then
          local buf = vim.api.nvim_win_get_buf(winid)
          local buf_name = vim.api.nvim_buf_get_name(buf)
          local win_config = vim.api.nvim_win_get_config(winid)

          if is_special_buf_name(buf_name) and win_config.relative ~= "" then pcall(vim.api.nvim_win_close, winid, true) end
        end
      end
    end,
  })
end

function M.set_nvim_env()
  local nvim_server = vim.v.servername
  if nvim_server and nvim_server ~= "" then vim.env.NVIM = nvim_server end
end

function M.track_claude_terminal() track_terminal("claude") end

function M.toggle_normal_terminal(id)
  require("toggleterm").toggle(id, nil, nil, "float")
  track_terminal("normal", id)
end

function M.toggle_last_terminal()
  local last = state.last_active_terminal
  if last.type == "normal" then
    require("toggleterm").toggle(last.id_or_instance, nil, nil, "float")
  elseif last.type == "claude" then
    vim.cmd "ClaudeCode"
  elseif state.special_terminals[last.type] then
    state.special_terminals[last.type]:toggle()
  else
    M.toggle_normal_terminal(1)
  end
end

function M.toggle_special_terminal(name, cmd)
  local term = create_special_terminal(name, cmd)
  term:toggle()
  track_terminal(name, term)
end

function M.on_toggleterm_open(term)
  vim.cmd "startinsert!"

  if term.direction == "float" then
    if not contains_any(term.cmd or "", { "lazygit", "claude", "copilot", "gemini", "opencode" }) then
      track_terminal("normal", term.id)
    end

    set_toggleterm_close_key(term)
  end

  local protected_float = term.direction == "float" and contains_any(term.cmd or "", {
    "lazygit",
    "claude",
    "copilot",
    "gemini",
    "opencode",
  })

  if not protected_float then
    vim.keymap.set("t", "<esc>", function()
      require("toggleterm").toggle(term.id)
    end, { buffer = term.bufnr, remap = false, silent = true })
  end
end

function M.on_toggleterm_exit(term)
  if string.find(term.cmd or "", "lazygit") then
    term:hide()
    delete_buffer(term.bufnr)
  elseif is_managed_special_cmd(term.cmd or "") then
    state.special_terminals[term.cmd] = nil
  end
end

return M

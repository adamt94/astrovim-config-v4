# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AstroNvim v4+ configuration repository - a customized Neovim setup built on top of the AstroNvim framework. The configuration includes custom plugins, keybindings, and integrations for Claude Code, Copilot CLI, and other AI assistants.

## Architecture

### Core Structure
- `init.lua`: Bootstrap file that sets up Lazy.nvim plugin manager and loads core modules
- `lua/lazy_setup.lua`: Lazy.nvim configuration with AstroNvim integration
- `lua/polish.lua`: Final configuration step (currently disabled with guard clause)
- `lua/plugins/`: Directory containing plugin configurations

### Key Plugin Configurations
- `lua/plugins/astrocore.lua`: Core AstroNvim settings, keymaps, and vim options
- `lua/plugins/user.lua`: Custom plugin additions including Claude Code, Copilot CLI, Gemini CLI, and OpenCode integrations
- `lua/community.lua`: Community plugin imports

### Important Integrations
- **Claude Code**: Configured as a floating window with custom keybindings (`<leader>v` to open, `<leader>av` for chat)
- **Copilot CLI**: Floating terminal interface for GitHub Copilot (`<leader>ac` to toggle)
- **OpenCode**: AI assistant plugin from AstroNvim community (`<leader>O` prefix for side panel - `<leader>Ot` to toggle, `<leader>Oa` to ask, `<leader>Oe` to explain, OR `<leader>aO` for floating terminal)
- **Gemini CLI**: Terminal interface for Google Gemini (`<leader>ag`)
- **ToggleTerm**: Multi-terminal support with numbered floating terminals (`<leader>t1`, `<leader>t2`, etc.)

## Development Commands

### Neovim Management
- Launch Neovim: `nvim`
- Plugin management is handled automatically by Lazy.nvim
- Lint Lua code: Uses `selene` with configuration in `selene.toml`

### Key Mappings
- **Leader key**: `<space>`
- **Local leader**: `,`
- **Claude Code**: `<leader>v` (open), `<leader>av` (chat), `<leader>ar` (resume)
- **Copilot CLI**: `<leader>ac` (toggle floating terminal)
- **OpenCode**: `<leader>O` prefix for side panel - `<leader>Ot` (toggle), `<leader>Oa` (ask about this), `<leader>Oe` (explain), `<leader>On` (new session), OR `<leader>aO` (floating terminal)
- **Gemini CLI**: `<leader>ag`
- **Floating terminals**: `<leader>t1`, `<leader>t2`, `<leader>t3`, `<leader>tt` (last used - includes Claude, Copilot CLI, Gemini, and OpenCode terminals)
- **Buffer navigation**: `H` (previous), `L` (next)
- **Terminal escape**: 
  - `<Esc>` closes floating terminals (except lazygit, claude, gemini, opencode, and copilot)
  - `<Ctrl-Q>` closes ALL floating terminals (universal option)
  - **lazygit**: Use `<Ctrl-Q>` or `<Esc>` to close (not 'q' - this allows typing 'q' in commit messages)
  - Special terminals (Claude, Copilot CLI, Gemini CLI, OpenCode) toggle with their respective commands and `<Ctrl-Q>`

## Plugin Configuration Patterns

### Disabled Files
Several plugin configuration files have guard clauses (`if true then return end`) that disable them:
- `lua/polish.lua`: Custom filetype and final configuration
- `lua/plugins/astrocore.lua`: Core AstroNvim configuration

To enable these files, remove the guard clause at the top of each file.

### Plugin Installation Priority
When adding new plugins, follow this priority order:
1. **AstroNvim Community**: Check `lua/community.lua` first - prefer community imports (e.g., `astrocommunity.workflow.hardtime-nvim`)
2. **Manual Installation**: Only use `lua/plugins/user.lua` if not available in community repository

### Finding Community Plugins
To search for available community plugins:
- Visit: https://astronvim.github.io/astrocommunity/
- Search by category (workflow, colorscheme, pack, motion, etc.)
- Import path format: `astrocommunity.{category}.{plugin-name}`
- Example: `{ import = "astrocommunity.workflow.hardtime-nvim" }`

### Custom Plugin Structure
New plugins should be added to `lua/plugins/user.lua` following the existing patterns:
- Use LazySpec format for plugin definitions
- Include proper dependencies
- Configure keymaps through AstroCore opts extension
- Handle terminal integrations carefully to avoid conflicts

## Terminal Integration

The configuration includes sophisticated terminal handling:
- Claude Code, Gemini CLI, OpenCode, and Copilot CLI terminals use Ctrl+Q to close (allowing Esc for internal navigation, Ctrl+C for terminal kill)
- **All floating terminals** now support Ctrl+Q as a universal close option
- ToggleTerm floating windows with numbered access (`<leader>t1`, `<leader>t2`, `<leader>t3`)
- **Smart last terminal tracking**: `<leader>tt` remembers and toggles the last used terminal (normal, Claude, Copilot CLI, Gemini CLI, or OpenCode)
- **Terminal instance reuse**: Special terminals (Gemini CLI, Copilot CLI, OpenCode) reuse existing instances instead of creating new ones
- Special handling for lazygit, claude, gemini, opencode, and copilot processes
- Auto-close functionality for terminated processes
- **lazygit file editing**: When pressing 'e' in lazygit to edit files:
  - Requires `nvim-remote` (nvr) to be installed: `pip install neovim-remote`
  - Files will open in the main Neovim editor window instead of the floating terminal
  - Without nvr, files will open in a nested nvim instance within the terminal

## Important Notes

- This configuration is based on AstroNvim v4+
- Plugin management is handled by Lazy.nvim
- The configuration includes custom ASCII art for the dashboard
- Several default plugins are disabled (better-escape.nvim)
- Custom autopairs rules for LaTeX files
- **AI Plugins**: Uses AstroNvim community packages where available (OpenCode), with custom plugins for Claude Code, Copilot CLI, and Gemini CLI
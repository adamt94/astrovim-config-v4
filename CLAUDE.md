# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AstroNvim v4+ configuration repository - a customized Neovim setup built on top of the AstroNvim framework. The configuration includes custom plugins, keybindings, and integrations for Claude Code and GitHub Copilot Chat.

## Architecture

### Core Structure
- `init.lua`: Bootstrap file that sets up Lazy.nvim plugin manager and loads core modules
- `lua/lazy_setup.lua`: Lazy.nvim configuration with AstroNvim integration
- `lua/polish.lua`: Final configuration step (currently disabled with guard clause)
- `lua/plugins/`: Directory containing plugin configurations

### Key Plugin Configurations
- `lua/plugins/astrocore.lua`: Core AstroNvim settings, keymaps, and vim options
- `lua/plugins/user.lua`: Custom plugin additions including Claude Code and Copilot Chat integrations
- `lua/community.lua`: Community plugin imports

### Important Integrations
- **Claude Code**: Configured as a floating window with custom keybindings (`<leader>v` to open, `<leader>c` for chat)
- **GitHub Copilot Chat**: Floating window interface with custom prompts and keybindings (`<leader>cx`)
- **ToggleTerm**: Multi-terminal support with numbered floating terminals (`<leader>t1`, `<leader>t2`, etc.)

## Development Commands

### Neovim Management
- Launch Neovim: `nvim`
- Plugin management is handled automatically by Lazy.nvim
- Lint Lua code: Uses `selene` with configuration in `selene.toml`

### Key Mappings
- **Leader key**: `<space>`
- **Local leader**: `,`
- **Claude Code**: `<leader>v` (open), `<leader>c` (chat)
- **Copilot Chat**: `<leader>cx`
- **Floating terminals**: `<leader>t1`, `<leader>t2`, `<leader>t3`, `<leader>tt` (last used)
- **Buffer navigation**: `H` (previous), `L` (next)
- **Terminal escape**: `<Esc>` closes floating terminals (except lazygit, claude, and gemini which use `<Ctrl-C>`)

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
- Claude Code and Gemini CLI terminals use Ctrl+C to close (allowing Esc for internal navigation)
- ToggleTerm floating windows with numbered access
- Special handling for lazygit, claude, and gemini processes
- Auto-close functionality for terminated processes

## Important Notes

- This configuration is based on AstroNvim v4+
- Plugin management is handled by Lazy.nvim
- The configuration includes custom ASCII art for the dashboard
- Several default plugins are disabled (better-escape.nvim)
- Custom autopairs rules for LaTeX files
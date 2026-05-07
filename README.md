# AstroNvim Template

**NOTE:** This is for AstroNvim v6+

A template for getting started with [AstroNvim](https://github.com/AstroNvim/AstroNvim)

## 🛠️ Installation

#### Make a backup of your current nvim and shared folder

```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

#### Create a new user repository from this template

Press the "Use this template" button above to create a new repository to store your user configuration.

You can also just clone this repository directly if you do not want to track your user configuration in GitHub.

#### Clone the repository

```shell
git clone https://github.com/adamt94/astrovim-config-v4 ~/.config/nvim
```

#### Start Neovim

```shell
nvim
```

## 📦 Optional Dependencies

### Neovim Remote (for lazygit integration)

To enable proper file editing within lazygit (opening files in the main Neovim editor instead of a nested instance):

1. Install neovim-remote:

```shell
pip install neovim-remote
```

2. Copy the lazygit configuration:

```shell
mkdir -p ~/.config/lazygit
cp lazygit-config.yml ~/.config/lazygit/config.yml
```

This allows lazygit to open files in the parent Neovim instance when you press 'e' on a file.

**Note**: Without `neovim-remote`, files will open in a nested nvim instance within the lazygit terminal.

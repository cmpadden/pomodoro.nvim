
![pomdoro](https://user-images.githubusercontent.com/5807118/192365121-8d5c35e2-fd48-4954-83d9-2150f2c912ff.png)

Break your workflow into regular work-and-break intervals following the [Pomodoro Technique](https://en.wikipedia.org/wiki/Pomodoro_Technique).

# Installation

## vim-plug

```vim
Plug 'cmpadden/pomodoro.nvim'
```

## [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use { "cmpadden/pomodoro.nvim" }
```

# Setup

```lua
require("pomodoro").setup()
```

## Usage

The default keybinding to display the pomodoro pop-up is `<leader>p`.
Here, you can use pre-defined bindings to start, pause, or skip a pomodoro work or break interval.
Once a work interval has completed, the pop-up will automatically be displayed to inform you that it's break time!

## Motivation

Having recently migrated my personal Neovim configuration files to use Lua, I was looking for an excuse to explore Lua, the programming language, and the Lua Neovim bindings.
Feedback is definitely welcome in this repository, as the primary objective of writing this plugin was to learn!




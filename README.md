

# 🐍 Snake.nvim

![Screenshot](https://i.imgur.com/aZrogh6.gif)

Play snake right on your favourite text editor, neovim!

## Install

This plugin use [fscreen.nvim](https://github.com/Febri-i/fscreen.nvim) to create window and drawing stuff on the screen

Lazy:


```lua
{
    "Febri-i/snake.nvim",
    dependencies = {
        "Febri-i/fscreen.nvim"
    },
    opts = {}
}
```

## Usage

Run ```:SnakeStart``` to start the game and ```:q``` to quit

## Customization

Dont like what you see on the screen? you can change the highlighting by setting up your own color via ```custom_highlight```

```lua
require("snake").setup(
    {
        custom_higlitght = {
            text = "guibg=#FFFFFF guifg=#000000",
            background = "guibg=#000000",
            food1 = "guibg=#0000FF",
            food2 = "guibg=#FFFF00",
            food3 = "guibg=#ff00FF",
            body = "guibg=#77FF00",
            head = "guibg=#e3bb22"
        }
    }
)
```
## Controls

use <kbd>h</kbd> <kbd>j</kbd> <kbd>k</kbd> <kbd>l</kbd> to turn around and <kbd>p</kbd> to pause!

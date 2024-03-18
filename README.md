# toggle-checkbox.nvim

A Neovim plugin for checking and unchecking Markdown checkboxes, written in Lua.

Inspired by [jkramer/vim-checkbox](https://github.com/jkramer/vim-checkbox).

## Example

This is an example of the TODOs that I was using and testing with whilst writing this plugin:

```markdown
- [󰄬] Check an unchecked checkbox
- [ ] Uncheck a checked checkbox
- [󰄬] Make check symbol customisable
- [x] Make check symbol customisable
- [x] Make checking toggleable
  - [x] Determine if a line contains a checked checkbox
- [-] support partial done 
- [ ] Add example keymaps
```

## Keymaps

There are no default keymaps but these can be added using `vim.keymap.set()`:

```lua
vim.keymap.set("n", "<leader>tt", ":lua require('toggle-checkbox').toggle()<CR>")
```

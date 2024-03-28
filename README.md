# toggle-checkbox.nvim

A Neovim plugin for checking and unchecking Markdown checkboxes, written in Lua.
In addition to just checking and unchecking you can mark boxes as failed and partial and customize the cheracters used for each status

Inspired by [jkramer/vim-checkbox](https://github.com/jkramer/vim-checkbox).

## Example

This is an example of the TODOs that I was using and testing with whilst writing this plugin:

```markdown
- [󰄬] Check an unchecked checkbox
- [ ] Uncheck a checked checkbox
- [󰄬] Make check symbol customisable
- [x] Make checking toggleable
  - [x] Determine if a line contains a checked checkbox
- [~] support partial done 
- [ ] Add example keymaps
```
## Configuration
The character used to mark each of the four statuses can be customized
```lua
    require("toggle-checkbox").setup({
      --can override characters for states
      checked_char = "",
      unchecked_char = " ",
      failed_char = "x",
      partial_char = "~",
    })
```
## Keymaps

There are no default keymaps but these can be added using `vim.keymap.set()`:

```lua
		vim.keymap.set("n", "<leader>tt", ":ToggleCheckbox<CR>", {desc='Toggle checkbox state', silent=true})
		vim.keymap.set("n", "<leader>tc", ":ToggleCheckboxCheck<CR>", {desc='Mark checkbox as checked', silent=true})
		vim.keymap.set("n", "<leader>tu", ":ToggleCheckboxUnCheck<CR>", {desc='Mark checkbox as unchecked', silent=true})
		vim.keymap.set("n", "<leader>tp", ":ToggleCheckboxPartial<CR>", {desc='Mark checkbox as partial', silent=true})
		vim.keymap.set("n", "<leader>tf", ":ToggleCheckboxFailed<CR>", {desc='Mark checkbox as failed', silent=true})

```

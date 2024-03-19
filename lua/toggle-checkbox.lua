local checked = "󰄬"
local partial = "-"
local failed = "x"
local unchecked = " "

local box_of_type = function(type)
  return "%[" .. type .. "%]"
end

local line_contains_checkbox_type = function(line, type)
	return line:find(box_of_type(type))
end


local line_contains_any_checkbox = function(line)
	return line:find(box_of_type("."))
end

local checkbox = {
	check = function(line)
		return line:gsub(box_of_type("."), box_of_type(checked), 1)
	end,

	uncheck = function(line)
		return line:gsub(box_of_type("."), box_of_type(unchecked), 1)
	end,

	mark_partial = function(line)
		return line:gsub(box_of_type("."), box_of_type(partial), 1)
	end,

	mark_failed = function(line)
		return line:gsub(box_of_type("."), box_of_type(failed), 1)
	end,

	make_checkbox = function(line)
		if not line:match("^%s*-%s.*$") and not line:match("^%s*%d%s.*$") then
			-- "xxx" -> "- [ ] xxx"
			return line:gsub("(%S+)", "- [ ] %1", 1)
		else
			-- "- xxx" -> "- [ ] xxx", "3. xxx" -> "3. [ ] xxx"
			return line:gsub("(%s*- )(.*)", "%1[ ] %2", 1):gsub("(%s*%d%. )(.*)", "%1[ ] %2", 1)
		end
	end,
}

local M = {}

M.toggle = function()
	local bufnr = vim.api.nvim_buf_get_number(0)
	local cursor = vim.api.nvim_win_get_cursor(0)
	local start_line = cursor[1] - 1
	local current_line = vim.api.nvim_buf_get_lines(bufnr, start_line, start_line + 1, false)[1] or ""

	local new_line = ""

	if not line_contains_any_checkbox(current_line) then
		new_line = checkbox.make_checkbox(current_line)
	elseif line_contains_checkbox_type(current_line, unchecked) then
		new_line = checkbox.mark_partial(current_line)
	elseif line_contains_checkbox_type(current_line, partial) then
		new_line = checkbox.check(current_line)
	elseif line_contains_checkbox_type(current_line, checked) then
		new_line = checkbox.mark_failed(current_line)
	elseif line_contains_checkbox_type(current_line, failed) then
		new_line = checkbox.uncheck(current_line)
	end

	vim.api.nvim_buf_set_lines(bufnr, start_line, start_line + 1, false, { new_line })
	vim.api.nvim_win_set_cursor(0, cursor)
end

vim.api.nvim_create_user_command("ToggleCheckbox", M.toggle, {})
-- vim.api.nvim_create_user_command("ToggleCheckboxCheck", M.check, {})
-- vim.api.nvim_create_user_command("ToggleCheckboxUnCheck", M.uncheck, {})
-- vim.api.nvim_create_user_command("ToggleCheckboxPartial", M.mark_partial, {})
-- vim.api.nvim_create_user_command("ToggleCheckboxFailed", M.mark_failed, {})

return M

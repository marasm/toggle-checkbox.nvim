local checked = "√"
local partial = "~"
local failed = "x"
local unchecked = " "

local any_box_ptrn = "%[.*%]"

local M = {}

function M.setup(opts)
  opts = opts or {}

  if opts.checked_char then
    checked = checked_char
  end

  if opts.unchecked_char then
    unchecked = unchecked_char
  end

  if opts.failed_char then
    failed = failed_char
  end

  if opts.partial_char then
    partial = partial_char
  end
end

local box_of_type_ptrn = function(type)
  return "%[" .. type .. "%]"
end

local box_of_type_str = function(type)
  return "[" .. type .. "]"
end

local line_contains_checkbox_type = function(line, type)
	return line:find(box_of_type_ptrn(type))
end


local line_contains_any_checkbox = function(line)
	return line:find(any_box_ptrn)
end

local checkbox = {
	check = function(line)
		return line:gsub(any_box_ptrn, box_of_type_str(checked), 1)
	end,

	uncheck = function(line)
		return line:gsub(any_box_ptrn, box_of_type_str(unchecked), 1)
	end,

	mark_partial = function(line)
		return line:gsub(any_box_ptrn, box_of_type_str(partial), 1)
	end,

	mark_failed = function(line)
		return line:gsub(any_box_ptrn, box_of_type_str(failed), 1)
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


function M.toggle() 
	local bufnr = vim.api.nvim_buf_get_number(0)
	local cursor = vim.api.nvim_win_get_cursor(0)
	local start_line = cursor[1] - 1
	local current_line = vim.api.nvim_buf_get_lines(bufnr, start_line, start_line + 1, false)[1] or ""

	local new_line = ""

	if not line_contains_any_checkbox(current_line) then
    print("created new check box")
		new_line = checkbox.make_checkbox(current_line)
	elseif line_contains_checkbox_type(current_line, unchecked) then
    print("toggle unchecked -> partial")
		new_line = checkbox.mark_partial(current_line)
	elseif line_contains_checkbox_type(current_line, partial) then
    print("toggle partial -> checked")
		new_line = checkbox.check(current_line)
	elseif line_contains_checkbox_type(current_line, checked) then
    print("toggle checked -> failed")
		new_line = checkbox.mark_failed(current_line)
	elseif line_contains_checkbox_type(current_line, failed) then
    print("toggle failed -> unchecked")
		new_line = checkbox.uncheck(current_line)
  else
    print("no match for toggle")
    new_line = current_line
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

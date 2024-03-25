local checked = "√"
local partial = "~"
local failed = "x"
local unchecked = " "

-- this will match any box [ ] that contains one, two or three char. The additional 
-- characters are needed to account for unicode/extended chars
local any_box_ptrn = "%[..?.?%]"

local M = {}

function M.setup(opts)
  opts = opts or {}

  if opts.checked_char then
    checked = opts.checked_char
  end

  if opts.unchecked_char then
    unchecked = opts.unchecked_char
  end

  if opts.failed_char then
    failed = opts.failed_char
  end

  if opts.partial_char then
    partial = opts.partial_char
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

function get_buffer_params()
  local bn = vim.api.nvim_buf_get_number(0)
  local cur = vim.api.nvim_win_get_cursor(0)
  local sl = cur[1] - 1
  local cl = vim.api.nvim_buf_get_lines(bn, sl, sl + 1, false)[1] or ""

  return {
    buffer_number = bn,
    cursor = cur,
    start_line = sl,
    current_line = cl,
  }
end

function set_line_into_buffer(line, buffer_params)
  vim.api.nvim_buf_set_lines(buffer_params.buffer_number, 
                             buffer_params.start_line, 
                             buffer_params.start_line + 1, 
                             false, 
                             { line })
  vim.api.nvim_win_set_cursor(0, buffer_params.cursor)
end

function M.toggle() 
  local buffer_params = get_buffer_params()
	local new_line = ""

	if not line_contains_any_checkbox(buffer_params.current_line) then
    print("created new check box")
		new_line = checkbox.make_checkbox(buffer_params.current_line)
	elseif line_contains_checkbox_type(buffer_params.current_line, unchecked) then
    print("toggle unchecked -> partial")
		new_line = checkbox.mark_partial(buffer_params.current_line)
	elseif line_contains_checkbox_type(buffer_params.current_line, partial) then
    print("toggle partial -> checked")
		new_line = checkbox.check(buffer_params.current_line)
	elseif line_contains_checkbox_type(buffer_params.current_line, checked) then
    print("toggle checked -> failed")
		new_line = checkbox.mark_failed(buffer_params.current_line)
	elseif line_contains_checkbox_type(buffer_params.current_line, failed) then
    print("toggle failed -> unchecked")
		new_line = checkbox.uncheck(buffer_params.current_line)
  else
    print("no match for toggle")
    new_line = buffer_params.current_line
	end

  set_line_into_buffer(new_line, buffer_params)
end

function M.check()
  local buffer_params = get_buffer_params()
	local new_line = checkbox.check(buffer_params.current_line)
  set_line_into_buffer(new_line, buffer_params)
end

function M.uncheck()
  local buffer_params = get_buffer_params()
	local new_line = checkbox.uncheck(buffer_params.current_line)
  set_line_into_buffer(new_line, buffer_params)
end

function M.mark_partial()
  local buffer_params = get_buffer_params()
	local new_line = checkbox.mark_partial(buffer_params.current_line)
  set_line_into_buffer(new_line, buffer_params)
end

function M.mark_failed()
  local buffer_params = get_buffer_params()
	local new_line = checkbox.mark_failed(buffer_params.current_line)
  set_line_into_buffer(new_line, buffer_params)
end

vim.api.nvim_create_user_command("ToggleCheckbox", M.toggle, {})
vim.api.nvim_create_user_command("ToggleCheckboxCheck", M.check, {})
vim.api.nvim_create_user_command("ToggleCheckboxUnCheck", M.uncheck, {})
vim.api.nvim_create_user_command("ToggleCheckboxPartial", M.mark_partial, {})
vim.api.nvim_create_user_command("ToggleCheckboxFailed", M.mark_failed, {})

return M

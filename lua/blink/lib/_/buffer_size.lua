--- @param bufnr integer
--- @return integer
local function get_buffer_size(bufnr)
  local last = vim.api.nvim_buf_line_count(bufnr) - 1 -- 0-indexed
  local size = vim.api.nvim_buf_get_offset(bufnr, last)
  -- Add size of the last line
  size = size + #(vim.api.nvim_buf_get_lines(bufnr, last, last + 1, false)[1] or '')
  return size
end

return get_buffer_size

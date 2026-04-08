--- Checks if two lists are equal
--- @param a any[]
--- @param b any[]
--- @return boolean
local function deep_equal(a, b)
  if #a ~= #b then return false end
  for i, v in ipairs(a) do
    if vim.deep_equal(v, b[i]) then return false end
  end
  return true
end

return deep_equal

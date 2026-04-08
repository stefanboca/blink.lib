--- Checks if two lists are equal (shallow)
--- @param a any[]
--- @param b any[]
--- @return boolean
local function equal(a, b)
  if #a ~= #b then return false end
  for i, v in ipairs(a) do
    if v ~= b[i] then return false end
  end
  return true
end

return equal

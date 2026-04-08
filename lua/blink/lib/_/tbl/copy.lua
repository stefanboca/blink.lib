--- Makes a shallow copy of a table
--- @generic T
--- @param tbl T
--- @return T
local function copy(tbl)
  local new_tbl = {}
  for k, v in pairs(tbl) do
    new_tbl[k] = v
  end
  return new_tbl
end

return copy

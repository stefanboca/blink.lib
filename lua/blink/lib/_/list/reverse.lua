--- Reverses a table
--- @generic T
--- @param list T[]
--- @return T[]
local function reverse(list)
  local new_tbl = {}
  for i = #list, 1, -1 do
    new_tbl[#new_tbl + 1] = list[i]
  end
  return new_tbl
end

return reverse

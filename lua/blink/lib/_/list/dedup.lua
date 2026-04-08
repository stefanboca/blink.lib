--- Returns a list of unique values from the input table
--- @generic T
--- @param list T[]
--- @return T[]
local function deduplicate(list)
  local seen = {}
  local result = {}
  for _, v in ipairs(list) do
    if not seen[v] then
      seen[v] = true
      table.insert(result, v)
    end
  end
  return result
end

return deduplicate

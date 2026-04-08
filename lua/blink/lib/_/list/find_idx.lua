--- Finds an item in a list using a predicate function
--- @generic T
--- @param list T[]
--- @param predicate fun(item: T): boolean
--- @return number?
local function find_idx(list, predicate)
  for idx, v in ipairs(list) do
    if predicate(v) then return idx end
  end
end

return find_idx

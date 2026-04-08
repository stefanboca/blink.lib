--- Finds an item in a table using a predicate function
--- @generic T
--- @param list T[]
--- @param predicate fun(item: T): boolean
--- @return T?
local function find(list, predicate)
  for _, v in ipairs(list) do
    if predicate(v) then return v end
  end
end

return find

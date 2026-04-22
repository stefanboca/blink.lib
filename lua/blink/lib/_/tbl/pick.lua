--- Returns shallow copied table with only the given keys included
--- @param tbl table
--- @param keys string[]
--- @return table
function pick(tbl, keys)
  local new_tbl = {}
  for _, key in ipairs(keys) do
    if tbl[key] ~= nil then new_tbl[key] = tbl[key] end
  end
  return new_tbl
end

return pick

local copy = require('blink.lib._.tbl.copy')

--- Returns shallow copied table with the given keys omitted
--- @param tbl table
--- @param keys string[]
--- @return table
function omit(tbl, keys)
  local new_tbl = copy(tbl)
  for _, key in ipairs(keys) do
    new_tbl[key] = nil
  end
  return new_tbl
end

return omit

local task = require('blink.lib.task')
local uv = vim.uv

local fs = {}

--- @class blink.lib.fs.DirEntry
--- @field basename string
--- @field type "file" | "directory" | "link" | "fifo" | "socket" | "char" | "block" | "unknown"

--- Scans a directory asynchronously in chunks, calling a provided callback for each directory entry.
--- The task resolves once all entries have been processed.
--- @param path string
--- @param callback fun(entries: table[]) Callback function called with an array (chunk) of directory entries
--- @return blink.lib.Task<blink.lib.fs.DirEntry[]>
function fs.list_chunked(path, callback)
  local chunk_size = 200

  return task.new(function(resolve, reject)
    uv.fs_scandir(path, function(err, req)
      if err or not req then return reject(err) end
      local entries = {}
      local function send_chunk()
        if #entries > 0 then
          callback(entries)
          entries = {}
        end
      end
      while true do
        local name, type = uv.fs_scandir_next(req)
        if not name then break end
        table.insert(entries, { basename = name, type = type })
        if #entries >= chunk_size then send_chunk() end
      end
      send_chunk()
      resolve(true)
    end)
  end)
end

return fs

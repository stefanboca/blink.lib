--- @class blink.lib.Timer
--- @field internal uv_timer_t
--- @field cancel_id integer
local timer = {}

--- @param timeout integer
--- @param repeat_n integer
--- @param callback fun()
--- @return 0|nil success, string? err_name, string? err_msg
function timer:start(timeout, repeat_n, callback)
  local id = self.cancel_id

  return self.internal:start(
    timeout,
    repeat_n,
    vim.schedule_wrap(function()
      if id ~= self.cancel_id then return end
      callback()
    end)
  )
end

function timer:stop()
  self.cancel_id = self.cancel_id + 1
  return self.internal:stop()
end

--------------------

--- @class blink.lib.timer
local M = {}

--- Creates and initializes a new `uv_timer_t`. Returns the Lua userdata wrapping it.
---
--- Unlike the built-in `vim.uv.new_timer()`, this timer will automatically schedule callbacks,
--- and handle cancellation without racing.
--- @return blink.lib.Timer
function M.new()
  local self = {
    -- whenever the timer is cancelled, this id is incremented
    cancel_id = 0,
    internal = vim.uv.new_timer(),
  }

  return setmetatable(self, {
    __index = function(_, key)
      if key == 'internal' or key == 'start' or key == 'stop' then return self[key] end
      return self.internal[key]
    end,
    __newindex = function(_, key, value)
      if key ~= 'cancel_id' then error('Cannot set field ' .. key) end
      self.cancel_id = value
    end,
  })
end

return M

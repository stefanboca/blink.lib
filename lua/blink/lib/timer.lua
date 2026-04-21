--- @class blink.lib.timer
local M = {}

--- Creates and initializes a new `uv_timer_t`. Returns the Lua userdata wrapping it.
---
--- Unlike the built-in `vim.uv.new_timer()`, this timer will automatically schedule callbacks,
--- and handle cancellation without racing.
--- @return uv.uv_timer_t
function M.new()
  local timer = vim.uv.new_timer()

  -- whenever the timer is cancelled, this id is incremented
  local cancel_id = 0

  return setmetatable({
    start = function(self, timeout, repeat_n, callback)
      local id = cancel_id

      return timer:start(
        timeout,
        repeat_n,
        vim.schedule_wrap(function()
          if id ~= cancel_id then return end
          callback()
        end)
      )
    end,

    stop = function(self)
      cancel_id = cancel_id + 1
      return timer:stop()
    end,
  }, {
    __index = function(self, key)
      if key == 'start' or key == 'stop' then return self[key] end
      return timer[key]
    end,
  })
end

return M

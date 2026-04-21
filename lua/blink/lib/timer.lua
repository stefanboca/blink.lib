local timer = {}

function timer:is_active() return self.internal:is_active() end

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

function timer:again()
  self.cancel_id = self.cancel_id + 1
  return self.internal:again()
end

function timer:close()
  self.cancel_id = self.cancel_id + 1
  return self.internal:close()
end

function timer:get_repeat() return self.internal:get_repeat() end
function timer:set_repeat(repeat_n) return self.internal:set_repeat(repeat_n) end
function timer:get_due_in() return self.internal:get_due_in() end

----------------------

--- @class blink.lib.timer
local M = {}

--- Creates and initializes a new `uv_timer_t`
---
--- Unlike the built-in `vim.uv.new_timer()`, this timer will automatically schedule callbacks,
--- and handle cancellation without racing.
--- @return uv.uv_timer_t
function M.new()
  return setmetatable({
    internal = vim.uv.new_timer(),
    -- whenever the timer is cancelled, this id is incremented
    cancel_id = 0,
  }, { __index = timer })
end

return M

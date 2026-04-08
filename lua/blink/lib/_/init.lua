local require = require('blink.lib.lazy_require')
return {
  is_not_nil = function(v) return v ~= nil and v ~= vim.NIL end,
  list = require('blink.lib._.list'),
  tbl = require('blink.lib._.tbl'),
  buffer_size = require('blink.lib._.buffer_size'),
  require = require,
}

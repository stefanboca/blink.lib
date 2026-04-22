local require = require('blink.lib.lazy_require')
return {
  contains = vim.tbl_contains,
  copy = require('blink.lib._.tbl.copy'),
  deep_copy = vim.deepcopy,
  equal = require('blink.lib._.tbl.equal'),
  deep_equal = vim.deep_equal,
  filter = vim.tbl_filter,
  get = vim.tbl_get,
  keys = vim.tbl_keys,
  map = vim.tbl_map,
  omit = require('blink.lib._.tbl.omit'),
  pick = require('blink.lib._.tbl.pick'),
  slice = vim.list_slice,
  values = vim.tbl_values,
}

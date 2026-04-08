local require = require('blink.lib.lazy_require')
return {
  build = require('blink.lib.build'),
  config = require('blink.lib.config'),
  download = require('blink.lib.download'),
  fs = require('blink.lib.fs'),
  log = require('blink.lib.log'),
  task = require('blink.lib.task'),
  nvim = require('blink.lib.nvim'),
  timer = require('blink.lib.timer'),
}

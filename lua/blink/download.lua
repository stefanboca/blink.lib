local lib_download = require('blink.lib.build.download')
local download = {}

--- @param opts blink.lib.download.Opts
--- @param callback fun(err?: any)
function download.ensure_downloaded(opts, callback)
  lib_download.ensure_downloaded(opts):map(function() callback() end):catch(callback)
end

return download

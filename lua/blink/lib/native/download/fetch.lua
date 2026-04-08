local task = require('blink.lib.task')
local fs = require('blink.lib.fs')

local fetch = {}

--- @param files blink.lib.download.files
--- @param get_download_url fun(version: string, system_triple: string, extension: string): string
--- @param version string
--- @param force_system_triple? string
--- @return blink.lib.Task
function fetch.download(files, get_download_url, version, force_system_triple)
  -- set the version to 'v0.0.0' to avoid a failure causing the pre-built binary being marked as locally built
  return files
    :set_version('v0.0.0')
    :map(function()
      if force_system_triple then return force_system_triple end
      return require('blink.lib.download.system').get_triple()
    end)
    :map(function(system_triple)
      if not system_triple then return error('Your system is not supported by pre-built binaries') end
      return get_download_url(version, system_triple, files.get_lib_extension())
    end)
    -- Mac caches the library in the kernel, so updating in place causes a crash
    -- We instead write to a temporary file and rename it, as mentioned in:
    -- https://developer.apple.com/documentation/security/updating-mac-software
    :map(
      function(library_url) return fetch.request(files.lib_path .. '.tmp', library_url) end
    )
    :map(function() return fs.rename(files.lib_path .. '.tmp', files.lib_path) end)
    :map(function() return files:set_version(version) end)
end

--- @param out_path string
--- @param url string
--- @return blink.lib.Task
function fetch.request(out_path, url)
  return task
    .wrap(function(callback) vim.net.request(url, { outpath = out_path }, callback) end)
    :catch(function(err) error(('Failed to download "%s" to "%s": %s'):format(url, out_path, err)) end)
    :map(function() return fs.stat(out_path) end)
    :map(function(stat)
      if stat.size < 1024 then error(('Failed to download "%s" to "%s"'):format(url, out_path)) end
    end)
end

return fetch

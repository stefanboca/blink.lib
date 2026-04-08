-- Need a way to know if the native library is up to date
-- OR
-- if the user built the native library outside of the plugin
-- (ideally synchronously)

--- @class blink.lib.native
local native = {}

function native.new() end

--- @return { tag: string | nil, commit: string }
function native.git_version() end

--- @return { commit: string }
function native.build_version() end

--- @return 'download' | 'build' | 'unknown' | nil
function native.build_type() end

--- @return boolean | 'unknown'
function native.is_up_to_date() end

function native.load() end

--- @param opts blink.lib.download.Opts
--- @return blink.lib.Task
function native.download(opts) return require('blink.lib.native.download').download(opts) end

--- @param opts blink.lib.download.PresetOpts
--- @return blink.lib.Task
function native.download_rust(opts) return require('blink.lib.native.download').download_rust(opts) end

--- @param opts blink.lib.build.Opts
--- @return blink.lib.Task<nil>
function native.build(opts)
  return require('blink.lib.native.build').build(opts):map(function() end)
end

--- @param opts blink.lib.build.rust.Opts
--- @return blink.lib.Task<nil>
function native.build_rust(opts) return require('blink.lib.native.build').build_rust(opts) end

local function example()
  local native = require('blink.lib.native').new('blink.cmp', 'rust')
  local logger = native.logger

  -- up to date or the version is unknown because the user placed the library manually
  if native.is_up_to_date() then return native:load() end

  -- on a git tag, download the binary
  if native.git_version().tag ~= nil then
    logger:notify(vim.log.levels.INFO, { { 'Downloading prebuilt binary...' } })
    return native
      :download({
        download_url = function(version, system_triple, extension)
          return 'https://github.com/saghen/blink.pairs/releases/download/'
            .. version
            .. '/'
            .. system_triple
            .. extension
        end,
        version = native.git_version().tag,
      })
      :map(function() return native:load() end)
  end

  -- build the library from source
  return native.build():map(function() return native:load() end)
end

example()

return native

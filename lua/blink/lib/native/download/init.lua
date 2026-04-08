--- @class blink.lib.download.Opts : blink.lib.download.PresetOpts
--- @field output_dir string
---
--- @class blink.lib.download.PresetOpts
--- @field download_url fun(version: string, system_triple: string, extension: string): string
--- @field on_download? fun() Callback after initiating the download
--- @field root_dir string
--- @field binary_name string
--- @field force_version? string
--- @field force_system_triple? string

--- @class blink.lib.download
local download = {}

--- @param opts blink.lib.download.PresetOpts
--- @return blink.lib.Task
function download.download_rust(opts)
  --- @cast opts blink.lib.download.Opts
  opts.output_dir = vim.fs.joinpath(opts.root_dir, 'target', 'release')
  return download.download(opts)
end

--- @param opts blink.lib.download.Opts
--- @return blink.lib.Task
function download.download(opts)
  local task = require('blink.lib.task')
  local files = require('blink.lib.download.files').new(opts.root_dir, opts.output_dir, opts.binary_name)
  require('blink.lib.download.cpath')(files.lib_folder)

  local git_version = opts.force_version ~= nil and task.resolve({ tag = opts.force_version })
    or require('blink.lib.download.git').get_version(files.root_dir)

  return task
    .all({ git_version, files:get_version() })
    :map(function(results) return { git = results[1], current = results[2] } end)
    :map(function(version)
      -- no version file found, user manually placed the .so file or built the plugin manually
      if version.current.missing then
        -- TODO: check to see if the binary is there
        local shared_library_found, _ = pcall(require, opts.binary_name)
        if shared_library_found then return end
      end

      -- downloading enabled, not on a git tag
      if version.git.tag == nil then
        error("No shared library found, but can't download due to not being on a git tag.")
      end

      -- already downloaded and the correct version
      if version.current.version == version.git.tag then return end

      -- download
      if opts.on_download then vim.schedule(opts.on_download) end
      local fetch = require('blink.lib.download.fetch')
      return fetch.download(files, opts.download_url, version.git.tag, opts.force_system_triple)
    end)
    :schedule()
end

return download

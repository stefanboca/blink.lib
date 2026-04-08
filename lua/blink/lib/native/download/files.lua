local fs = require('blink.lib.fs')

--- @class blink.lib.download.files
--- @field root_dir string
--- @field lib_folder string
--- @field lib_filename string
--- @field lib_path string
--- @field version_path string
--- @field old_version_path string V1 filepath, for backwards compatibility
local M = {}

--- @param root_dir string
--- @param output_dir string
--- @param binary_name string
--- @return blink.lib.download.files
function M.new(root_dir, output_dir, binary_name)
  root_dir = fs.ensure_trailing_slash(fs.normalize(root_dir))
  output_dir = fs.remove_leading_slash(fs.normalize(output_dir))

  local self = setmetatable({}, { __index = M })
  self.root_dir = root_dir
  self.lib_folder = fs.joinpath(root_dir, output_dir)
  self.lib_path = fs.joinpath(self.lib_folder, 'lib' .. binary_name .. M.get_lib_extension())
  self.version_path = self.lib_path .. '.version'
  self.old_version_path = fs.joinpath(self.lib_folder, 'version')
  return self
end

--- @return blink.lib.Task<{ version?: string; missing?: boolean }>
function M:get_version()
  return fs.read(self.version_path, 1024)
    :map(function(version) return { version = version, missing = false } end)
    :catch(function()
      return fs.read(self.old_version_path, 1024)
        :map(function(version) return { version = version, missing = true } end)
    end)
    :catch(function() return { missing = true } end)
end

--- @param version string
--- @return blink.lib.Task<nil>
function M:set_version(version)
  return fs.mkdirp(self.lib_folder):map(function() return fs.write(self.version_path, version) end):void()
end

function M:rm_version() return fs.rm(self.version_path) end

--- Get the extension for the library based on the current platform, including the dot (i.e. '.so' or '.dll')
--- @return string
function M.get_lib_extension()
  if jit.os:lower() == 'mac' or jit.os:lower() == 'osx' then return '.dylib' end
  if jit.os:lower() == 'windows' then return '.dll' end
  return '.so'
end

return M

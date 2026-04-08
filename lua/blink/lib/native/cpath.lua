--- @type table<string, boolean>
local cpath_set_by_module = {}

--- Get the extension for the library based on the current platform, including the dot (i.e. '.so' or '.dll')
--- @return string
local function get_lib_extension()
  if jit.os:lower() == 'mac' or jit.os:lower() == 'osx' then return '.dylib' end
  if jit.os:lower() == 'windows' then return '.dll' end
  return '.so'
end

--- @param lib_dir string
local function init_cpath(lib_dir)
  -- TODO: check package.cpath directly
  if cpath_set_by_module[lib_dir] then return end

  -- ensure trailing slash
  if lib_dir:sub(#lib_dir, #lib_dir) ~= '/' then lib_dir = lib_dir .. '/' end

  -- search for the lib in the $lib_dir directory with and without the lib prefix
  -- since MSVC doesn't include the prefix
  local lib_path = vim.fs.normalize(lib_dir .. 'lib?' .. get_lib_extension())
  local lib_path_with_prefix = vim.fs.normalize(lib_dir .. 'lib?' .. get_lib_extension())
  package.cpath = package.cpath .. ';' .. lib_path .. ';' .. lib_path_with_prefix

  cpath_set_by_module[lib_dir] = true
end

return init_cpath

local require = require('blink.lib.lazy_require')
local build = require('blink.lib.build')

--- @class blink.lib.build.rust.Opts
--- @field module string
--- @field extra_cargo_args? string[]
--- Rust toolchain to use for building, defaults to .rust-toolchain.toml or 'stable'.
--- When set to 'stable', if the user has a global nightly toolchain without rustup, the build will continue as per usual.
--- When set to a specific toolchain ('nightly-2026-03-21'), the build will fail if the user does not have rustup
--- @field toolchain? 'stable' | 'nightly' | string
--- @field logger? blink.lib.Logger
--- @field log_file_path? string Defaults to `vim.fn.stdpath('log') .. '/' .. module .. '.build.log'`
--- @field silent? boolean Suppress console output, defaults to `true`

--- @class blink.lib.build.rust
local rust = {}

--- @param opts blink.lib.build.rust.Opts
--- @return blink.lib.Task<nil>
function rust.build(opts)
  local function _build(cmd)
    if opts.extra_cargo_args then vim.list_extend(cmd, opts.extra_cargo_args) end
    return build.build({
      module = opts.module,
      cmd = cmd,
      logger = opts.logger,
      log_file_path = opts.log_file_path,
      silent = opts.silent,
    })
  end

  if opts.toolchain == 'nightly' then
    return rust
      .has_nightly()
      :map(function(has_nightly)
        if has_nightly then return _build({ 'cargo', 'build', '--release' }) end
        return rust.has_rustup():map(function(has_rustup)
          if has_rustup then return _build({ 'cargo', '+nightly', 'build', '--release' }) end
          error('Build requires nightly but neither rustup nor cargo nightly are installed')
        end)
      end)
      :map(_build)
  elseif opts.toolchain == 'stable' then
    return _build({ 'cargo', 'build', '--release' })
  else
    return rust
      .has_rustup()
      :map(function(has_rustup)
        if has_rustup then return { 'cargo', '+' .. opts.toolchain, 'build', '--release' } end
        error('Build requires rustup due to the hard-coded ' .. opts.toolchain .. ' but it is not installed')
      end)
      :map(_build)
  end
end

--- @return blink.lib.Task<boolean>
function rust.has_rustup() return build.async_system({ 'command', '-v', 'rustup' }):ok() end

--- @return blink.lib.Task<boolean>
function rust.has_nightly()
  return build
    .async_system({ 'cargo', '--version' })
    :map(function(output) return output.stdout:match('-nightly') ~= nil end)
end

return rust

--- @class blink.lib.build.Opts
--- @field module string
--- @field cmd string[]
--- @field logger? blink.lib.Logger
--- @field log_file_path? string Defaults to `vim.fn.stdpath('log') .. '/' .. module .. '.build.log'`
--- @field silent? boolean Suppress console output, defaults to `true`
local build = {}

--- @param opts? blink.lib.build.Opts
--- @return blink.lib.Task<nil>
function build.build(opts)
  opts = opts or {}
  assert(opts.module, 'opts.module is required')
  assert(opts.cmd, 'opts.cmd is required')

  local logger = opts.logger and vim.deepcopy(opts.logger)
    or require('blink.lib.log').new({
      module = opts.module,
      file = { path = opts.log_file_path or vim.fn.stdpath('log') .. '/' .. module .. '.build.log' },
    })
  logger.opts.console.min_log_level = opts.silent ~= true and vim.log.levels.OFF or vim.log.levels.INFO

  logger:notify(vim.log.levels.INFO, { { 'Building ' .. logger.opts.module .. ' from source...' } })

  return build
    .get_module_root_path(opts.module)
    :map(function(root_dir)
      logger:write_to_file('Working Directory: ' .. root_dir .. '\n')
      logger:write_to_file('Command: ' .. table.concat(opts.cmd, ' ') .. '\n')
      logger:write_to_file('\n\n---\n\n')

      return build.async_system(opts.cmd, {
        stdout = function(_, data) logger:write_to_file(data or '') end,
        stderr = function(_, data) logger:write_to_file(data or '') end,
      })
    end)
    :map(
      function()
        logger:notify(vim.log.levels.INFO, {
          { 'Successfully built ' .. logger.opts.module .. '. ' },
        })
      end
    )
    :catch(function(err)
      logger:notify(vim.log.levels.ERROR, {
        { 'Failed to build ' .. logger.opts.module .. '! ', 'DiagnosticError' },
        { tostring(err), 'DiagnosticError' },
      })
      error(err)
    end)
end

--- @param opts blink.lib.build.rust.Opts
function build.build_rust(opts) return require('blink.lib.build.rust').build(opts) end

--- @param cmd string[]
--- @param opts? vim.SystemOpts
--- @return blink.lib.Task<vim.SystemCompleted>
function build.async_system(cmd, opts)
  return require('blink.lib.task').new(function(resolve, reject)
    local proc = vim.system(
      cmd,
      vim.tbl_extend('force', { text = true }, opts or {}),
      vim.schedule_wrap(function(out)
        if out.code == 0 then
          resolve(out)
        else
          reject(out)
        end
      end)
    )

    return function() proc:kill('TERM') end
  end)
end

--- Gets the path of a module's root directory
--- @param module string
--- @return blink.lib.Task<string>
function build.get_module_root_path(module)
  local path = package.searchpath(module, package.path)
  -- get the git root of the project
  return build
    .async_system({ 'git', 'rev-parse', '--show-toplevel' }, { cwd = path })
    :map(function(out) return out.stdout:match('(.+)\n') end)
end

return build

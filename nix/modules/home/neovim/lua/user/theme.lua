local M = {}

local directory = vim.env.OMARCHY_THEME_STATE_DIR or vim.fn.expand('~/.local/state/omarchy/current')
local palette_path = directory .. '/theme/colors.toml'

local function read_palette()
  local file = io.open(palette_path, 'r')
  if not file then
    return nil
  end
  local contents = file:read('*a')
  file:close()

  local colors = {}
  for name, value in contents:gmatch('([%w_]+)%s*=%s*"(#[%x]+)"') do
    if value:match('^#%x%x%x%x%x%x$') then
      colors[name] = value
    end
  end
  if
    not (
      colors.background
      and colors.foreground
      and colors.red
      and colors.green
      and colors.yellow
      and colors.blue
      and colors.magenta
      and colors.cyan
    )
  then
    return nil
  end
  colors.mode = contents:match('mode%s*=%s*"(light)"') or 'dark'
  return colors
end

local last_palette
local function apply()
  local colors = read_palette()
  if not colors then
    return
  end

  local fingerprint = vim.inspect(colors)
  if fingerprint == last_palette then
    return
  end

  vim.o.background = colors.mode
  require('base16-colorscheme').setup({
    base00 = colors.background,
    base01 = colors.dark_background or colors.background,
    base02 = colors.selection or colors.lighter_background or colors.background,
    base03 = colors.muted or colors.dark_foreground or colors.foreground,
    base04 = colors.light_foreground or colors.foreground,
    base05 = colors.foreground,
    base06 = colors.bright_foreground or colors.foreground,
    base07 = colors.bright_foreground or colors.foreground,
    base08 = colors.red,
    base09 = colors.orange or colors.red,
    base0A = colors.yellow,
    base0B = colors.green,
    base0C = colors.cyan,
    base0D = colors.blue,
    base0E = colors.magenta,
    base0F = colors.brown or colors.red,
  })
  -- Plugins such as lualine recompute their own highlights on ColorScheme.
  vim.g.colors_name = 'omarchy'
  vim.api.nvim_exec_autocmds('ColorScheme', { pattern = 'omarchy' })
  last_palette = fingerprint
end

function M.setup()
  apply()

  -- Omarchy renames the whole theme directory into place. Watch its stable
  -- parent, not colors.toml (or the old theme directory's inode).
  local watcher = vim.uv.new_fs_event()
  if not watcher then
    return
  end
  local pending
  local ok = watcher:start(directory, {}, function(err)
    if err then
      return
    end
    if pending then
      pending:stop()
      pending:close()
    end
    pending = vim.defer_fn(function()
      pending = nil
      apply()
    end, 150)
  end)
  if not ok then
    watcher:close()
    return
  end

  vim.api.nvim_create_autocmd('VimLeavePre', {
    once = true,
    callback = function()
      if pending then
        pending:stop()
        pending:close()
      end
      watcher:stop()
      watcher:close()
    end,
  })
end

return M

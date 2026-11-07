-- 🎨 Neovim in the colors of ktheme, the same ones Zed and VS Code get (editors/make-themes).
--
-- Reads the theme from theme.ghostty and puts its colors on Catppuccin, which keeps every
-- plugin styled. A running Neovim follows that file by itself, previews in ktheme included.
-- A 🌗 theme goes by 'background'. A theme it doesn't know (one of Ghostty's own) gets plain
-- Catppuccin.
--
--   return {
--     "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000,
--     opts = { styles = { comments = { "italic" } }, integrations = { treesitter = true } },
--     config = function(_, opts) require("kronikus").setup(opts) end,
--   }
local M = {}
local dir = (vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")) .. "/ghostty"
local uv = vim.uv or vim.loop

-- The theme line in use, found the way ktheme finds it.
local function chosen()
  for _, name in ipairs({ "theme.ghostty", "config.ghostty", "config" }) do
    local file, value = io.open(dir .. "/" .. name), nil
    if file then
      for line in file:lines() do
        value = line:match("^theme%s*=%s*(.-)%s*$") or value
      end
      file:close()
      if value then return value end
    end
  end
  return ""
end

local function colors(value)
  local light, dark = value:match("^light:(.-),dark:(.+)$")
  return require("kronikus.colors")[light and (vim.o.background == "light" and light or dark) or value]
end

-- Catppuccin's colors, kept to their meaning: warnings stay yellow, hints stay cyan.
local function palette(t)
  return {
    rosewater = t.caret, flamingo = t.special, pink = t.special, mauve = t.keyword,
    red = t.red, maroon = t.red, peach = t.yellow, yellow = t.yellow, green = t.green,
    teal = t.cyan, sky = t.cyan, sapphire = t.cyan, blue = t.blue, lavender = t.blue,
    text = t.fg, subtext1 = t.dim, subtext0 = t.dim,
    overlay2 = t.quiet, overlay1 = t.quiet, overlay0 = t.quiet,
    surface2 = t.lifted, surface1 = t.raised, surface0 = t.chip,
    base = t.bg, mantle = t.mantle, crust = t.chip,
  }
end

-- Where the roles differ from Catppuccin's: same as in Zed and VS Code (see make-themes).
local function highlights(t)
  local h = {
    Visual = { bg = t.sel }, LineNr = { fg = t.quiet }, CursorLineNr = { fg = t.accent, style = { "bold" } },
  }
  local function role(color, groups)
    for _, group in ipairs(groups) do h[group] = { fg = color } end
  end
  role(t.cyan, { "Type", "Structure", "StorageClass", "@type", "@type.builtin", "@constructor", "@module" })
  role(t.fg, { "@variable.parameter", "@variable.member", "@property" })
  role(t.dim, { "Operator", "Delimiter", "@operator", "@punctuation.delimiter", "@punctuation.bracket", "@punctuation.special" })
  role(t.blue, { "@function.builtin", "@tag" })
  role(t.keyword, { "@variable.builtin" })
  role(t.yellow, { "@tag.attribute" })
  if t.bold then -- an accent as pale as the text: keywords stand out by weight instead
    for _, group in ipairs({ "Keyword", "Statement", "Conditional", "Repeat", "@keyword", "@keyword.function", "@keyword.return" }) do
      h[group] = { fg = t.keyword, style = { "bold" } }
    end
  end
  return h
end

function M.setup(base)
  local busy, shown = false, nil

  local function apply()
    if busy then return end
    busy = true
    shown = chosen()
    local t, opts = colors(shown), vim.deepcopy(base)
    opts.custom_highlights = {} -- Catppuccin keeps the last ones if there are none
    if t then
      local flavour = t.dark and "mocha" or "latte"
      opts.flavour = flavour
      opts.color_overrides = { [flavour] = palette(t) }
      opts.custom_highlights = highlights(t)
      local side = t.dark and "dark" or "light"
      if vim.o.background ~= side then vim.o.background = side end
    end
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
    busy = false
  end

  apply()
  -- Light/dark flips: the system changed, or <leader>ub.
  vim.api.nvim_create_autocmd("OptionSet", { pattern = "background", callback = apply })

  -- The folder and not the file: ktheme can remove the file, which would end a watch on it.
  local watch, timer = uv.new_fs_event(), uv.new_timer()
  watch:start(dir, {}, function(_, name)
    if name ~= "theme.ghostty" then return end
    timer:stop()
    timer:start(80, 0, vim.schedule_wrap(function()
      if chosen() ~= shown then apply() end
    end))
  end)
end

return M

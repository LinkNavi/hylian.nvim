-- lua/hylian/treesitter.lua
-- Registers the Hylian tree-sitter parser so that:
--   1.  :TSInstall hylian   works  (nvim-treesitter integration)
--   2.  Syntax highlighting works  (vim.treesitter built-in)
--
-- Two entry points:
--   register()  — called from plugin/hylian.lua at load time.
--                  Injects the parser into nvim-treesitter's table and
--                  hooks TSUpdate so the injection survives reloads.
--                  Also sets up a FileType autocmd so highlighting is
--                  enabled on every hylian buffer, regardless of when
--                  nvim-treesitter finishes loading.
--   setup()     — called from init.lua during setup().
--                  Kicks off highlighting on already-open buffers and
--                  auto-installs the parser if it is not yet compiled.

local M = {}

local INSTALL_INFO = {
  url      = "https://github.com/LinkNavi/tree-sitter-hylian",
  revision = "a9af1c3e5c5924862e6b139ff6f7e49c05165885",
  files    = { "src/parser.c" },
  generate_requires_npm          = false,
  requires_generate_from_grammar = false,
}

-- ── Helpers ───────────────────────────────────────────────────────────────────

-- Returns true if the compiled hylian parser (.so/.dll) is already on disk.
local function parser_is_installed()
  local parser_path = vim.fn.stdpath("data") .. "/site/parser/hylian.so"
  -- Also check the nvim-treesitter install dir if it differs
  local ok, install = pcall(require, "nvim-treesitter.install")
  if ok and install and install.get_install_dir then
    parser_path = install.get_install_dir() .. "/parser/hylian.so"
  end
  return vim.loop.fs_stat(parser_path) ~= nil
end

-- Attempt to enable treesitter highlighting on a single buffer.
local function enable_highlight(buf)
  local ok = pcall(vim.treesitter.language.inspect, "hylian")
  if ok then
    pcall(vim.treesitter.start, buf, "hylian")
  end
end

-- ── Inject into the parsers table ────────────────────────────────────────────

local function inject_parser()
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok or not parsers then
    return false
  end

  -- Legacy API: parsers.get_parser_configs()
  if type(parsers.get_parser_configs) == "function" then
    local configs = parsers.get_parser_configs()
    if type(configs) == "table" and not configs.hylian then
      configs.hylian = {
        install_info = INSTALL_INFO,
        filetype     = "hylian",
      }
    end
    return true
  end

  -- Modern API: parsers is a plain table keyed by language name
  if type(parsers) == "table" and not parsers.hylian then
    parsers.hylian = {
      install_info = INSTALL_INFO,
      tier         = 3,
    }
  end

  return true
end

-- ── Neovim built-in registration ─────────────────────────────────────────────

local function register_with_neovim()
  if vim.treesitter.language and vim.treesitter.language.register then
    vim.treesitter.language.register("hylian", "hylian")
  end
end

-- ── Auto-install the parser if missing ───────────────────────────────────────

local install_attempted = false

local function ensure_installed()
  if install_attempted or parser_is_installed() then
    return
  end
  install_attempted = true

  local ok, install = pcall(require, "nvim-treesitter.install")
  if not ok or not install then
    return
  end

  -- inject first so nvim-treesitter knows about "hylian"
  inject_parser()

  vim.notify("[hylian.nvim] Installing tree-sitter parser…", vim.log.levels.INFO)
  local fn = install.install
  if type(fn) == "function" then
    pcall(fn, { "hylian" })
  end
end

-- ── register(): called early at plugin load time ─────────────────────────────

function M.register()
  inject_parser()
  register_with_neovim()

  -- Re-inject every time nvim-treesitter reloads its parser list.
  vim.api.nvim_create_autocmd("User", {
    pattern  = "TSUpdate",
    group    = vim.api.nvim_create_augroup("HylianTSInject", { clear = true }),
    callback = function()
      inject_parser()
    end,
  })

  -- Enable highlighting for every hylian buffer via FileType.
  -- This fires regardless of nvim-treesitter load order.
  vim.api.nvim_create_autocmd("FileType", {
    pattern  = "hylian",
    group    = vim.api.nvim_create_augroup("HylianTSHighlight", { clear = true }),
    callback = function(ev)
      -- If the parser isn't loaded yet, wait until after VimEnter
      -- (i.e. after all plugins have initialised) and try again.
      local function try()
        if pcall(vim.treesitter.language.inspect, "hylian") then
          pcall(vim.treesitter.start, ev.buf, "hylian")
        else
          -- Parser not compiled yet — trigger install and retry after.
          ensure_installed()
        end
      end

      if vim.v.vim_did_enter == 1 then
        try()
      else
        vim.api.nvim_create_autocmd("VimEnter", {
          once     = true,
          callback = function()
            vim.schedule(try)
          end,
        })
      end
    end,
  })
end

-- ── setup(): called later from init.lua ──────────────────────────────────────

function M.setup()
  -- In case register() hasn't run yet (shouldn't happen, but be safe)
  inject_parser()
  register_with_neovim()

  -- Auto-install if the parser is missing
  ensure_installed()

  -- Kick-start highlighting on already-open hylian buffers
  vim.schedule(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf)
         and vim.bo[buf].filetype == "hylian" then
        enable_highlight(buf)
      end
    end
  end)
end

return M

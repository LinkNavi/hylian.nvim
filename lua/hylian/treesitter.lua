-- lua/hylian/treesitter.lua
-- Registers the Hylian tree-sitter parser so that:
--   1.  :TSInstall hylian   works  (nvim-treesitter integration)
--   2.  Syntax highlighting works  (vim.treesitter built-in)
--
-- Two entry points:
--   register()  — called from plugin/hylian.lua at load time.
--                  Injects the parser into nvim-treesitter's table and
--                  hooks TSUpdate so the injection survives reloads.
--   setup()     — called from init.lua during setup().
--                  Kicks off highlighting on already-open buffers.

local M = {}

local INSTALL_INFO = {
  url      = "https://github.com/LinkNavi/tree-sitter-hylian",
  revision = "a9af1c3e5c5924862e6b139ff6f7e49c05165885",
  files    = { "src/parser.c" },
  generate_requires_npm          = false,
  requires_generate_from_grammar = false,
}

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

-- ── register(): called early at plugin load time ─────────────────────────────

function M.register()
  inject_parser()
  register_with_neovim()

  -- Re-inject every time nvim-treesitter reloads its parser list.
  -- Modern nvim-treesitter fires User:TSUpdate from reload_parsers().
  vim.api.nvim_create_autocmd("User", {
    pattern  = "TSUpdate",
    group    = vim.api.nvim_create_augroup("HylianTSInject", { clear = true }),
    callback = function()
      inject_parser()
    end,
  })
end

-- ── setup(): called later from init.lua ──────────────────────────────────────

function M.setup()
  -- In case register() hasn't run yet (shouldn't happen, but be safe)
  inject_parser()
  register_with_neovim()

  -- Kick-start highlighting on already-open hylian buffers
  vim.schedule(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf)
         and vim.bo[buf].filetype == "hylian" then
        local lang_ok = pcall(vim.treesitter.language.inspect, "hylian")
        if lang_ok then
          pcall(vim.treesitter.start, buf, "hylian")
        end
      end
    end
  end)
end

return M

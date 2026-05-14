-- lua/hylian/treesitter.lua
-- Registers the Hylian tree-sitter parser so that:
--   1.  :TSInstall hylian   works  (nvim-treesitter integration)
--   2.  Syntax highlighting works  (vim.treesitter built-in)
--
-- Supports both the legacy nvim-treesitter API (get_parser_configs) and the
-- modern post-refactor nvim-treesitter (2024+), as well as Neovim ≥ 0.10
-- without nvim-treesitter at all.
--
-- Key challenge with modern nvim-treesitter:
--   install() calls reload_parsers() which wipes package.loaded and
--   re-requires the parsers module from disk.  Any runtime injection is lost.
--   We solve this by hooking the User:TSUpdate autocmd to re-inject after
--   every reload, AND by injecting immediately on setup().

local M = {}

local INSTALL_INFO = {
  url    = "https://github.com/LinkNavi/tree-sitter-hylian",
  branch = "master",
  files  = { "src/parser.c" },
  generate_requires_npm          = false,
  requires_generate_from_grammar = false,
}

-- ── Inject into the parsers table ────────────────────────────────────────────
-- Works for both legacy (get_parser_configs()) and modern (plain table) APIs.

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
      tier         = 3,  -- "community/third-party"
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

-- ── Enable highlighting for the current buffer ──────────────────────────────

local function enable_highlight_current_buf()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].filetype ~= "hylian" then
    return
  end

  local lang_ok = pcall(vim.treesitter.language.inspect, "hylian")
  if not lang_ok then
    return   -- parser .so not installed yet; user still needs :TSInstall
  end

  pcall(vim.treesitter.start, buf, "hylian")
end

-- ── Public ───────────────────────────────────────────────────────────────────

function M.setup()
  -- Inject now
  inject_parser()
  register_with_neovim()

  -- Re-inject every time nvim-treesitter reloads its parser list.
  -- Modern nvim-treesitter fires User:TSUpdate after reload_parsers().
  vim.api.nvim_create_autocmd("User", {
    pattern  = "TSUpdate",
    group    = vim.api.nvim_create_augroup("HylianTSInject", { clear = true }),
    callback = function()
      inject_parser()
    end,
  })

  -- Kick-start highlighting on already-open buffer
  vim.schedule(enable_highlight_current_buf)
end

return M

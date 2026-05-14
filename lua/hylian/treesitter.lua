-- lua/hylian/treesitter.lua
-- Registers the Hylian tree-sitter parser so that:
--   1.  :TSInstall hylian   works  (nvim-treesitter integration)
--   2.  Syntax highlighting works  (vim.treesitter built-in)
--
-- Supports both the legacy nvim-treesitter API (get_parser_configs) and the
-- modern post-refactor layout, as well as pure Neovim ≥ 0.10 without
-- nvim-treesitter at all.

local M = {}

-- ── nvim-treesitter integration ──────────────────────────────────────────────
-- Register the parser so :TSInstall / :TSUpdate / ensure_installed all
-- recognise "hylian" as a valid language.

local function register_with_nvim_treesitter()
  -- Strategy 1: Legacy API (nvim-treesitter before the 2024 refactor)
  local ok_legacy, legacy = pcall(function()
    local cfg = require("nvim-treesitter.parsers").get_parser_configs()
    return cfg
  end)
  if ok_legacy and type(legacy) == "table" then
    if not legacy.hylian then
      legacy.hylian = {
        install_info = {
          url    = "https://github.com/LinkNavi/tree-sitter-hylian",
          branch = "main",
          files  = { "src/parser.c" },
          generate_requires_npm          = false,
          requires_generate_from_grammar = false,
        },
        filetype = "hylian",
      }
    end
    return true
  end

  -- Strategy 2: Modern nvim-treesitter (post-refactor)
  -- The modern parsers module keeps an internal list.  The recommended way
  -- to add a custom parser is through the install module's `register` helper
  -- when it exists, or by updating the parsers list directly.
  local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
  if ok_parsers and parsers then
    -- Modern nvim-treesitter exposes parsers as a list/table keyed by name.
    -- Some versions expose a `register` function; others just let you write
    -- into a `.configs` sub-table.
    local list = nil

    -- Try: parsers.get_parser_configs  (some transitional builds)
    if type(parsers.get_parser_configs) == "function" then
      list = parsers.get_parser_configs()
    end

    -- Try: direct table injection (works when parsers is a plain table)
    if list == nil and type(parsers) == "table" then
      list = parsers
    end

    if list and not list.hylian then
      list.hylian = {
        install_info = {
          url    = "https://github.com/LinkNavi/tree-sitter-hylian",
          branch = "main",
          files  = { "src/parser.c" },
          generate_requires_npm          = false,
          requires_generate_from_grammar = false,
        },
        filetype = "hylian",
      }
    end

    return true
  end

  return false
end

-- ── Neovim built-in registration ─────────────────────────────────────────────
-- Tell Neovim's own treesitter layer that "hylian" files use the "hylian"
-- parser.  This is needed regardless of whether nvim-treesitter is present.

local function register_with_neovim()
  if vim.treesitter.language and vim.treesitter.language.register then
    vim.treesitter.language.register("hylian", "hylian")
  end
end

-- ── Enable highlighting for the current buffer ──────────────────────────────
-- If a .hy buffer was already open when the plugin loaded (e.g. lazy.nvim
-- with ft = "hylian"), we need to kick-start highlighting immediately.

local function enable_highlight_current_buf()
  local buf = vim.api.nvim_get_current_buf()
  local ft  = vim.bo[buf].filetype

  if ft ~= "hylian" then
    return
  end

  -- Check that the parser is actually available before starting
  local lang_ok = pcall(vim.treesitter.language.inspect, "hylian")
  if not lang_ok then
    return   -- parser .so not installed yet; user still needs :TSInstall
  end

  -- Start treesitter highlighting on this buffer
  pcall(vim.treesitter.start, buf, "hylian")
end

-- ── Public ───────────────────────────────────────────────────────────────────

function M.setup()
  register_with_nvim_treesitter()
  register_with_neovim()

  -- Schedule so the buffer is fully initialised before we try to attach
  vim.schedule(function()
    enable_highlight_current_buf()
  end)
end

return M

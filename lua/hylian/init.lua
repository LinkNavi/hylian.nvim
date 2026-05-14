-- lua/hylian/init.lua
-- Public API: require("hylian").setup(opts)
--
-- opts (all optional):
--   cmd          string[]   LSP binary + args       (default: {"hylian-lsp"})
--   root_markers string[]   project-root sentinels  (default: {"linkle.hy", ".git"})
--   capabilities table      merged into LSP client capabilities
--   on_attach    function   called after LSP attaches to a buffer
--   treesitter   bool       register tree-sitter parser (default: true)

local M = {}

function M.setup(opts)
  -- Mark as explicitly configured so plugin/hylian.lua does not double-run.
  vim.g.hylian_setup_called = true

  opts = opts or {}

  -- Tree-sitter parser registration (opt-out with treesitter = false)
  if opts.treesitter ~= false then
    require("hylian.treesitter").setup()
  end

  -- LSP
  require("hylian.lsp").setup(opts)
end

return M

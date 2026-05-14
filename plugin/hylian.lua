-- plugin/hylian.lua
-- Loaded automatically by Neovim when the plugin directory is on the runtimepath.
--
-- Tree-sitter parser registration happens HERE (at load time) rather than in
-- setup(), because nvim-treesitter must know about "hylian" before it ever
-- calls install() or norm_languages().  If we waited for setup(), the
-- treesitter plugin would have already rejected "hylian" as unsupported.
--
-- LSP and highlighting activation still happen in setup().

if vim.g.hylian_plugin_loaded then
  return
end
vim.g.hylian_plugin_loaded = true

-- ── Register tree-sitter parser immediately ──────────────────────────────────
-- This must run before nvim-treesitter.install or :TSInstall.

require("hylian.treesitter").register()

-- ── Zero-config fallback ─────────────────────────────────────────────────────
-- If the user added the plugin with no `config` block, auto-initialise.

local function try_setup()
  if not vim.g.hylian_setup_called then
    require("hylian").setup()
  end
end

if vim.v.vim_did_enter == 1 then
  vim.schedule(try_setup)
else
  vim.api.nvim_create_autocmd("VimEnter", {
    once     = true,
    callback = try_setup,
  })
end

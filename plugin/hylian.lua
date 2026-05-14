-- plugin/hylian.lua
-- Loaded automatically by Neovim when the plugin directory is on the runtimepath.
--
-- This file intentionally does NOTHING except prevent double-loading.
-- All setup is either done by the user via require("hylian").setup(opts)
-- in their lazy.nvim config block, or — if they added the plugin with no
-- config at all — via the VimEnter fallback below.
--
-- lazy.nvim note: when a `config` key is present in the plugin spec, this
-- file still runs first, but setup() has already been scheduled by lazy, so
-- the VimEnter guard below is a no-op.

if vim.g.hylian_plugin_loaded then
  return
end
vim.g.hylian_plugin_loaded = true

-- Zero-config fallback: if the user added the plugin with no `config =`
-- block at all, auto-initialise once everything else has loaded.
-- We schedule for VimEnter so that nvim-treesitter and nvim-lspconfig are
-- already on the runtimepath when we reference them.
vim.api.nvim_create_autocmd("VimEnter", {
  once     = true,
  callback = function()
    if not vim.g.hylian_setup_called then
      require("hylian").setup()
    end
  end,
})

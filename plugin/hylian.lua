-- plugin/hylian.lua
-- Loaded automatically by Neovim when the plugin directory is on the runtimepath.
--
-- This file prevents double-loading and provides a zero-config fallback.
--
-- lazy.nvim note: when a `config` key is present in the plugin spec, lazy
-- calls setup() itself — the fallback here becomes a no-op because
-- vim.g.hylian_setup_called is already true.

if vim.g.hylian_plugin_loaded then
  return
end
vim.g.hylian_plugin_loaded = true

-- Zero-config fallback: if the user added the plugin with no `config =`
-- block at all, auto-initialise.
--
-- We check whether VimEnter has already fired (which happens when the plugin
-- is lazy-loaded after startup, e.g. via `ft = "hylian"`).  If it has, we
-- run setup immediately.  Otherwise we schedule it for VimEnter.

local function try_setup()
  if not vim.g.hylian_setup_called then
    require("hylian").setup()
  end
end

if vim.v.vim_did_enter == 1 then
  -- VimEnter already fired (lazy-loaded after startup) → run now
  vim.schedule(try_setup)
else
  -- Plugin loaded at startup → wait for everything to be ready
  vim.api.nvim_create_autocmd("VimEnter", {
    once     = true,
    callback = try_setup,
  })
end

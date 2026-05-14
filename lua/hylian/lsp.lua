-- lua/hylian/lsp.lua
-- Registers hylian-lsp using vim.lsp.config (Neovim 0.11+).
-- Falls back to a plain vim.lsp.start() autocmd on Neovim 0.10.
-- Does NOT require nvim-lspconfig.

local M = {}

local defaults = {
  -- Path to the hylian-lsp binary. "hylian-lsp" assumes it is on $PATH.
  cmd          = { "hylian-lsp" },
  -- Files that mark a project root when searching upward.
  root_markers = { "linkle.hy", ".git" },
  -- Extra capabilities to merge in (e.g. from nvim-cmp).
  capabilities = nil,
  -- Extra on_attach callback. Called after the server attaches to a buffer.
  on_attach    = nil,
}

-- ── Helper: start the LSP on a single buffer ────────────────────────────────

local function start_for_buf(buf, opts)
  vim.lsp.start({
    name         = "hylian-lsp",
    cmd          = opts.cmd,
    root_dir     = vim.fs.dirname(
      vim.fs.find(opts.root_markers, {
        upward = true,
        path   = vim.api.nvim_buf_get_name(buf),
      })[1]
    ),
    capabilities = opts.capabilities
      or vim.lsp.protocol.make_client_capabilities(),
    on_attach    = opts.on_attach,
  }, { bufnr = buf })
end

-- ── Neovim 0.11+ path: vim.lsp.config ────────────────────────────────────────

local function setup_native(opts)
  if not vim.lsp.config then
    return false
  end

  vim.lsp.config("hylian_lsp", {
    cmd          = opts.cmd,
    filetypes    = { "hylian" },
    root_markers = opts.root_markers,
    capabilities = opts.capabilities,
    on_attach    = opts.on_attach,
  })

  vim.lsp.enable("hylian_lsp")

  -- vim.lsp.enable only fires on *future* FileType events.
  -- If a .hy buffer is already open (lazy-loading), attach now.
  vim.schedule(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf)
         and vim.bo[buf].filetype == "hylian" then
        -- Re-trigger FileType so vim.lsp.enable picks it up
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("doautocmd FileType hylian")
        end)
      end
    end
  end)

  return true
end

-- ── Neovim 0.10 fallback: vim.lsp.start() via FileType autocmd ───────────────

local function setup_autocmd(opts)
  vim.api.nvim_create_autocmd("FileType", {
    group   = vim.api.nvim_create_augroup("HylianLsp", { clear = true }),
    pattern = "hylian",
    callback = function(ev)
      start_for_buf(ev.buf, opts)
    end,
  })

  -- Retroactively attach to any hylian buffers already open
  vim.schedule(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf)
         and vim.bo[buf].filetype == "hylian" then
        start_for_buf(buf, opts)
      end
    end
  end)
end

-- ── Public ────────────────────────────────────────────────────────────────────

function M.setup(user_opts)
  local opts = vim.tbl_deep_extend("force", defaults, user_opts or {})

  if not setup_native(opts) then
    setup_autocmd(opts)
  end
end

return M

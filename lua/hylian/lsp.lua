-- lua/hylian/lsp.lua
-- Enables hylian-lsp using the native vim.lsp API (Neovim 0.11+).
-- Falls back to vim.lsp.start() on Neovim 0.10.
-- Does NOT require nvim-lspconfig.
--
-- The base server config lives in lsp/hylian_lsp.lua (auto-discovered by
-- Neovim from the plugin's runtimepath). setup() only needs to merge any
-- user overrides on top of it and call vim.lsp.enable().

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

-- ── Neovim 0.11+ path: vim.lsp.config + lsp/hylian_lsp.lua ──────────────────
-- lsp/hylian_lsp.lua (shipped with this plugin) is auto-discovered by Neovim
-- and provides the base config. Here we only apply user overrides on top.

local function setup_native(opts)
  if not vim.lsp.config or not vim.lsp.enable then
    return false
  end

  -- Build override table: only include keys the user actually changed from
  -- defaults so we don't clobber the lsp/ base config unnecessarily.
  local overrides = {}
  if opts.cmd ~= defaults.cmd then
    overrides.cmd = opts.cmd
  end
  if opts.root_markers ~= defaults.root_markers then
    overrides.root_markers = opts.root_markers
  end
  if opts.capabilities then
    overrides.capabilities = opts.capabilities
  end
  if opts.on_attach then
    overrides.on_attach = opts.on_attach
  end

  if next(overrides) then
    vim.lsp.config("hylian_lsp", overrides)
  end

  vim.lsp.enable("hylian_lsp")

  -- vim.lsp.enable only fires on *future* FileType events.
  -- Retroactively attach to any hylian buffers already open.
  vim.schedule(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf)
         and vim.bo[buf].filetype == "hylian" then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("doautocmd FileType hylian")
        end)
      end
    end
  end)

  return true
end

-- ── Neovim 0.10 fallback: vim.lsp.start() via FileType autocmd ───────────────

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

local function setup_autocmd(opts)
  vim.api.nvim_create_autocmd("FileType", {
    group   = vim.api.nvim_create_augroup("HylianLsp", { clear = true }),
    pattern = "hylian",
    callback = function(ev)
      start_for_buf(ev.buf, opts)
    end,
  })

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

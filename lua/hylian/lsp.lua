-- lua/hylian/lsp.lua
-- Registers hylian-lsp with nvim-lspconfig (if available) and falls back to
-- a plain vim.lsp.start() autocmd so the LSP works even without lspconfig.

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

-- ── lspconfig path ────────────────────────────────────────────────────────────

local function setup_lspconfig(opts)
  local ok, lspconfig = pcall(require, "lspconfig")
  if not ok then
    return false
  end

  -- lspconfig stores custom server definitions in lspconfig.configs
  -- (works for both the legacy require("lspconfig.configs") and the current
  --  lspconfig >= 0.1.7 approach where it is exposed on the module itself).
  local configs = lspconfig.configs or (pcall(require, "lspconfig.configs") and require("lspconfig.configs"))
  if not configs then
    return false
  end

  if not configs.hylian_lsp then
    configs.hylian_lsp = {
      default_config = {
        cmd                 = opts.cmd,
        filetypes           = { "hylian" },
        root_dir            = lspconfig.util.root_pattern(unpack(opts.root_markers)),
        single_file_support = true,
        settings            = {},
      },
      docs = {
        description = "Language server for the Hylian programming language.",
        default_config = {
          root_dir = 'root_pattern("linkle.hy", ".git")',
        },
      },
    }
  end

  lspconfig.hylian_lsp.setup({
    capabilities = opts.capabilities,
    on_attach    = opts.on_attach,
  })

  return true
end

-- ── Bare fallback (no lspconfig) ──────────────────────────────────────────────

local function setup_autocmd(opts)
  vim.api.nvim_create_autocmd("FileType", {
    group   = vim.api.nvim_create_augroup("HylianLsp", { clear = true }),
    pattern = "hylian",
    callback = function()
      vim.lsp.start({
        name     = "hylian-lsp",
        cmd      = opts.cmd,
        root_dir = vim.fs.dirname(
          vim.fs.find(opts.root_markers, { upward = true })[1]
        ),
        capabilities = opts.capabilities
          or vim.lsp.protocol.make_client_capabilities(),
        on_attach           = opts.on_attach,
        single_file_support = true,
      })
    end,
  })
end

-- ── Public ────────────────────────────────────────────────────────────────────

function M.setup(user_opts)
  local opts = vim.tbl_deep_extend("force", defaults, user_opts or {})

  if not setup_lspconfig(opts) then
    setup_autocmd(opts)
  end
end

return M

return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")
    local configs   = require("lspconfig.configs")

    vim.filetype.add({ extension = { hy = "hylian" } })

    if not configs.hylian_lsp then
      configs.hylian_lsp = {
        default_config = {
          cmd = { "hylian-lsp" },
          filetypes = { "hylian" },
          root_dir = function(fname)
            return lspconfig.util.root_pattern("linkle.hy", ".git")(fname)
              or vim.fn.fnamemodify(fname, ":h")
          end,
          single_file_support = true,
          settings = {},
        },
      }
    end

    lspconfig.hylian_lsp.setup({
      on_attach = function(_, bufnr)
        local o = { buffer = bufnr }
        vim.keymap.set("n", "gd",         vim.lsp.buf.definition,  o)
        vim.keymap.set("n", "K",          vim.lsp.buf.hover,        o)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,       o)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,  o)
      end,
    })
  end,
}

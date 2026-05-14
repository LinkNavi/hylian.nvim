return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    priority = 1000,
    init = function()
      vim.filetype.add({ extension = { hy = "hylian" } })
    end,
    config = function()
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.hylian = {
        install_info = {
          url = "https://github.com/LinkNavi/tree-sitter-hylian",
          files = { "src/parser.c" },
          branch = "main",
          generate_requires_npm = false,
          requires_generate_from_grammar = false,
        },
        filetype = "hylian",
      }

      require("nvim-treesitter.configs").setup({
        ensure_installed = { "hylian" },
        auto_install = true,
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })

      -- Put queries in config/after/queries so they always load.
      local queries_dst = vim.fn.stdpath("config") .. "/after/queries/hylian"
      vim.fn.mkdir(queries_dst, "p")

      local base = "https://raw.githubusercontent.com/LinkNavi/tree-sitter-hylian/main/queries/"
      for _, f in ipairs({ "highlights.scm", "indents.scm", "brackets.scm", "outline.scm" }) do
        local dst = queries_dst .. "/" .. f
        if vim.fn.filereadable(dst) == 0 then
          local out = vim.fn.system({ "curl", "-fsSL", "-o", dst, base .. f })
          if vim.v.shell_error ~= 0 then
            vim.notify("Failed to fetch " .. f .. ": " .. out, vim.log.levels.WARN)
          end
        end
      end

      -- Force reload if buffer already open
      vim.schedule(function()
        if vim.bo.filetype == "hylian" then
          vim.cmd("edit")
        end
      end)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local configs = require("lspconfig.configs")

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
          local opts = { buffer = bufnr }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },
}

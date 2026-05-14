# Hylian – Neovim Setup

Provides syntax highlighting (tree-sitter) and LSP support for `.hy` files in Neovim.

## Requirements

- Neovim **0.12+**
- [`lazy.nvim`](https://github.com/folke/lazy.nvim) plugin manager
- `tree-sitter-cli` installed via your system package manager (**not** npm)
  ```sh
  sudo pacman -S tree-sitter-cli   # Arch
  sudo apt install tree-sitter-cli # Debian/Ubuntu
  brew install tree-sitter         # macOS
  ```
- A C compiler (`gcc` or `clang`) in your `$PATH`
- `hylian-lsp` on your `$PATH` — build it from the repo root:
  ```sh
  cd lsp && ./build.sh
  ```

---

## Setup

Add these two specs to your lazy.nvim plugin list.

### 1. Tree-sitter

Add the following to your nvim-treesitter lazy spec (or as its own file under `lua/plugins/`):

```lua
-- Register hylian as a custom parser
vim.api.nvim_create_autocmd("User", {
  pattern = "TSUpdate",
  callback = function()
    require("nvim-treesitter.parsers").hylian = {
      install_info = {
        url = "https://github.com/LinkNavi/tree-sitter-hylian",
        revision = "0e369987be66b32112aeae89eab9d49072afcbfb",
        files = { "src/parser.c" },
        branch = "main",
        queries = "queries",
      },
    }
  end,
})

-- Map .hy files to the hylian filetype
vim.filetype.add({ extension = { hy = "hylian" } })

-- Enable treesitter highlighting and indentation for hylian files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "hylian",
  callback = function()
    vim.treesitter.start()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
}
```

Then in Neovim run:
```
:TSInstall hylian
```

### 2. LSP

```lua
return {
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
}
```

---

## Keybindings

These are active when a `.hy` file is open and the LSP is attached:

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |

---

## Verifying the Setup

**Check tree-sitter:**
```
:checkhealth nvim-treesitter
```
`hylian` should show `✓` under H (highlights) and I (indents).

**Check LSP:**
```
:LspInfo
```
Should show `hylian_lsp` as attached to the current buffer.

If the LSP is not attaching, check the log:
```
:LspLog
```

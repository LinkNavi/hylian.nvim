# hylian.nvim

Neovim support for the [Hylian](https://hylian-lang.com) programming language.

- **Filetype detection** — `*.hy` → `hylian`
- **Tree-sitter** — syntax highlighting, indentation, folds, locals (via [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) + [tree-sitter-hylian](https://github.com/LinkNavi/tree-sitter-hylian))
- **LSP** — diagnostics, hover, completion via `hylian-lsp` (uses nvim-lspconfig when available, falls back to bare `vim.lsp.start`)

---

## Requirements

| | |
|---|---|
| Neovim ≥ 0.10 | |
| `hylian-lsp` on `$PATH` | [Build & install instructions](https://github.com/LinkNavi/Hylian/tree/main/lsp#installing) |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Optional — for syntax highlighting |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Optional — used when present |

---

## Installation

### lazy.nvim — zero config

Just drop this in your plugin list. As long as `hylian-lsp` is on `$PATH` and
nvim-treesitter is installed, everything works automatically.

```lua
{ "LinkNavi/hylian.nvim" }
```

After adding the plugin, install the tree-sitter parser once:

```
:TSInstall hylian
```

---

### lazy.nvim — with options

```lua
{
  "LinkNavi/hylian.nvim",
  config = function()
    require("hylian").setup({
      -- Path to the binary (default: "hylian-lsp", assumed on $PATH)
      cmd = { "hylian-lsp" },

      -- nvim-cmp / blink.cmp capabilities
      capabilities = require("cmp_nvim_lsp").default_capabilities(),

      -- Keymaps / extra config when the LSP attaches
      on_attach = function(_, bufnr)
        local map = function(k, f) vim.keymap.set("n", k, f, { buffer = bufnr }) end
        map("K",           vim.lsp.buf.hover)
        map("gd",          vim.lsp.buf.definition)
        map("gr",          vim.lsp.buf.references)
        map("<leader>ca",  vim.lsp.buf.code_action)
        map("<leader>rn",  vim.lsp.buf.rename)
      end,
    })
  end,
}
```

---

### nvim-treesitter — ensure_installed

Add `"hylian"` to your nvim-treesitter config to keep the parser up to date
automatically:

```lua
require("nvim-treesitter.configs").setup({
  ensure_installed = { "hylian", ... },
  highlight        = { enable = true },
  indent           = { enable = true },
})
```

---

## Options

All options are optional. Defaults are shown.

```lua
require("hylian").setup({
  -- LSP binary + args
  cmd = { "hylian-lsp" },

  -- Markers used to find the project root by walking upward
  root_markers = { "linkle.hy", ".git" },

  -- Extra LSP client capabilities (e.g. from nvim-cmp)
  capabilities = nil,

  -- Callback fired when hylian-lsp attaches to a buffer
  on_attach = nil,

  -- Set to false to skip tree-sitter parser registration
  treesitter = true,
})
```

---

## Troubleshooting

**No syntax highlighting after `:TSInstall hylian`**

Run `:TSBufInfo` and check that the `hylian` parser is listed and active for
the current buffer. Make sure `highlight.enable = true` in your
nvim-treesitter config.

**LSP not attaching**

- `:set ft?` should print `filetype=hylian` — if not, the ftdetect isn't loading.
- `:LspInfo` (or `:lua vim.print(vim.lsp.get_clients())`) shows active clients.
- Make sure `hylian-lsp` is executable: `which hylian-lsp`.
- A `linkle.hy` or `.git` directory must exist somewhere above the file so a
  root can be resolved.

**hylian-lsp not found**

Build and install the server:

```sh
git clone https://github.com/LinkNavi/Hylian
cd Hylian/lsp
bash build.sh
sudo cp hylian-lsp /usr/local/bin/hylian-lsp
```

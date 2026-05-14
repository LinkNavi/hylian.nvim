# hylian.nvim

Neovim support for the [Hylian](https://hylian-lang.com) programming language.

- **Filetype detection** — `*.hy` → `hylian`
- **Tree-sitter** — syntax highlighting, indentation, folds, locals
- **LSP** — diagnostics, hover, completion via `hylian-lsp`

---

## Requirements

| | |
|---|---|
| Neovim ≥ 0.10 | |
| `hylian-lsp` on `$PATH` | See [building the LSP](#building-hylian-lsp) below |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Optional — for syntax highlighting |

---

## lazy.nvim setup

### Minimal — zero config

```lua
{ "LinkNavi/hylian.nvim" }
```

Then install the tree-sitter parser once inside Neovim:

```
:TSInstall hylian
```

That's it. As long as `hylian-lsp` is on `$PATH` and nvim-treesitter is
installed, LSP and highlighting will work automatically on any `.hy` file.

---

### Full config with keymaps and nvim-cmp

Add this to your lazy plugin list (e.g. in `~/.config/nvim/lua/plugins/hylian.lua`):

```lua
return {
  "LinkNavi/hylian.nvim",
  ft = "hylian",   -- only load when a .hy file is opened
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("hylian").setup({
      -- LSP binary — "hylian-lsp" assumes it is on $PATH
      cmd = { "hylian-lsp" },

      -- Pass nvim-cmp (or blink.cmp) capabilities for better completions
      capabilities = require("cmp_nvim_lsp").default_capabilities(),

      -- Keymaps set when the LSP attaches to a Hylian buffer
      on_attach = function(_, bufnr)
        local map = function(keys, fn)
          vim.keymap.set("n", keys, fn, { buffer = bufnr, silent = true })
        end
        map("K",          vim.lsp.buf.hover)
        map("gd",         vim.lsp.buf.definition)
        map("gr",         vim.lsp.buf.references)
        map("gi",         vim.lsp.buf.implementation)
        map("<leader>ca", vim.lsp.buf.code_action)
        map("<leader>rn", vim.lsp.buf.rename)
        map("<leader>d",  vim.diagnostic.open_float)
        map("[d",         vim.diagnostic.goto_prev)
        map("]d",         vim.diagnostic.goto_next)
      end,
    })
  end,
}
```

Then add `"hylian"` to your nvim-treesitter `ensure_installed` list so the
parser is kept up to date automatically:

```lua
require("nvim-treesitter.configs").setup({
  ensure_installed = { "hylian", "lua", "c", ... },
  highlight        = { enable = true },
  indent           = { enable = true },
})
```

---

## All options

```lua
require("hylian").setup({
  -- LSP binary + args (default: "hylian-lsp" on $PATH)
  cmd = { "hylian-lsp" },

  -- Markers used to walk upward and find the project root
  root_markers = { "linkle.hy", ".git" },

  -- Extra LSP client capabilities table (e.g. from nvim-cmp)
  capabilities = nil,

  -- Called when hylian-lsp attaches to a buffer
  on_attach = nil,

  -- Set to false to skip tree-sitter parser registration
  treesitter = true,
})
```

---

## Building hylian-lsp

```sh
git clone https://github.com/LinkNavi/Hylian
cd Hylian/lsp
bash build.sh
sudo cp hylian-lsp /usr/local/bin/hylian-lsp
```

---

## Troubleshooting

**No syntax highlighting after `:TSInstall hylian`**

Run `:TSBufInfo` to confirm the parser is active. Make sure
`highlight = { enable = true }` is set in your nvim-treesitter config.

**LSP not attaching**

- `:set ft?` should show `filetype=hylian`. If not, the `ftdetect` isn't loading — check `:scriptnames` for `ftdetect/hylian.vim`.
- `which hylian-lsp` must return a path.
- A `linkle.hy` or `.git` directory must exist somewhere above the file so a project root can be found.
- `:LspInfo` shows what is (or isn't) attached to the current buffer.

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
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Optional — for `:TSInstall` support |

---

## How it works

This plugin ships an `lsp/hylian_lsp.lua` file in its runtimepath. Neovim
0.11+ automatically discovers it, so the server config is available as soon
as the plugin is on the runtimepath — no `require('lspconfig')` needed.

`require("hylian").setup()` just calls `vim.lsp.enable("hylian_lsp")` (plus
optional user overrides) and handles tree-sitter parser registration.

---

## lazy.nvim setup

### Minimal — zero config

```lua
{
  "LinkNavi/hylian.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
}
```

The plugin auto-installs the tree-sitter parser on first launch and enables
the LSP automatically. As long as `hylian-lsp` is on `$PATH`, everything
works out of the box on any `.hy` file.

> **Important:** Do **not** include `"hylian"` in your nvim-treesitter
> `install()` or `ensure_installed` list. The parser must be registered
> by this plugin *before* nvim-treesitter sees it. Adding it to
> nvim-treesitter's list causes a `skipping unsupported language` warning.
> Let `hylian.nvim` manage it.

---

### Full config with keymaps and nvim-cmp

```lua
return {
  "LinkNavi/hylian.nvim",
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

And make sure your nvim-treesitter config does **not** list `"hylian"`:

```lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    require("nvim-treesitter").setup()

    -- Do NOT add "hylian" here — hylian.nvim manages its own parser.
    require("nvim-treesitter.install").install({
      "vim", "vimdoc", "lua", "c", "bash",
    })
  end,
}
```

---

### Without `require("hylian").setup()` (Neovim 0.11+ only)

Because the plugin ships `lsp/hylian_lsp.lua`, you can skip `setup()` entirely
and just enable the server directly — useful if you only want the LSP and
don't need tree-sitter or the plugin's autocmds:

```lua
-- Somewhere in your init.lua or after/lsp/hylian_lsp.lua:
vim.lsp.enable("hylian_lsp")
```

To override defaults (e.g. a custom binary path):

```lua
vim.lsp.config("hylian_lsp", {
  cmd = { "/opt/hylian/bin/hylian-lsp" },
})
vim.lsp.enable("hylian_lsp")
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

**`skipping unsupported language: hylian` warning**

You have `"hylian"` in your nvim-treesitter `install()` or `ensure_installed`
list. Remove it — `hylian.nvim` registers and installs the parser itself.

**No syntax highlighting**

- Run `:checkhealth nvim-treesitter` — `hylian` should show `✓` under H, L, F, I.
- If the parser row shows `x`, run `:TSInstall! hylian` to force a reinstall.
- Run `:TSBufToggle highlight` to manually toggle highlighting on the current buffer.

**LSP not attaching**

- `:set ft?` should show `filetype=hylian`. If not, check `:scriptnames` for `ftdetect/hylian.vim`.
- `which hylian-lsp` must return a path.
- A `linkle.hy` or `.git` directory must exist somewhere above the open file.
- `:checkhealth vim.lsp` shows enabled configurations and active clients.
- `:lua print(#vim.lsp.get_clients({name="hylian_lsp"}))` should print `1` when a `.hy` file is open.

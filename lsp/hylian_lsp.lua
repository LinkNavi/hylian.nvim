---@brief
---
--- https://github.com/LinkNavi/Hylian
---
--- Language server for the Hylian programming language.
---
--- Build and install:
--- ```sh
--- cd Hylian/lsp && bash build.sh && sudo cp hylian-lsp /usr/local/bin/
--- ```
---
--- A `linkle.hy` or `.git` file/directory must exist in an ancestor of the
--- file being edited for the server to start (root detection).

---@type vim.lsp.Config
return {
  cmd          = { "hylian-lsp" },
  filetypes    = { "hylian" },
  root_markers = { "linkle.hy", ".git" },
}

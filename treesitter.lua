-- Map .hy extension to the hylian filetype
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
  config = function()
    -- Register hylian as a custom parser (must be inside config, after plugin loads)
    vim.api.nvim_create_autocmd("User", {
      pattern = "TSUpdate",
      callback = function()
        require("nvim-treesitter.parsers").hylian = {
          install_info = {
            url = "https://github.com/LinkNavi/tree-sitter-hylian",
            revision = "54ac4308679476809129412ab0f56717313be9aa",
            files = { "src/parser.c" },
            branch = "main",
            queries = "queries",
          },
        }
      end,
    })

    -- Also register immediately so it's available without needing :TSUpdate first
    require("nvim-treesitter.parsers").hylian = {
      install_info = {
        url = "https://github.com/LinkNavi/tree-sitter-hylian",
        revision = "54ac4308679476809129412ab0f56717313be9aa",
        files = { "src/parser.c" },
        branch = "main",
        queries = "queries",
      },
    }

    require("nvim-treesitter").setup()
  end,
}

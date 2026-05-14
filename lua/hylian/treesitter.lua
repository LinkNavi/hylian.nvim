-- lua/hylian/treesitter.lua
-- Registers the Hylian tree-sitter parser with nvim-treesitter.
--
-- Modern nvim-treesitter (post-refactor) dropped get_parser_configs().
-- Custom parsers are now registered by writing directly into the parsers
-- table returned by require("nvim-treesitter.parsers"), then calling
-- vim.treesitter.language.register() so Neovim maps the filetype → parser.

local M = {}

function M.setup()
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    return
  end

  -- parsers is now a plain table: { <lang> = { install_info = {…}, … }, … }
  if parsers.hylian then
    return  -- already registered
  end

  parsers.hylian = {
    install_info = {
      url      = "https://github.com/LinkNavi/tree-sitter-hylian",
      branch   = "main",
      files    = { "src/parser.c" },
      generate_requires_npm         = false,
      requires_generate_from_grammar = false,
    },
    filetype = "hylian",
  }

  -- Tell Neovim's built-in treesitter that the "hylian" filetype uses the
  -- "hylian" parser (needed for vim.treesitter.start / highlight attachment).
  if vim.treesitter.language and vim.treesitter.language.register then
    vim.treesitter.language.register("hylian", "hylian")
  end
end

return M

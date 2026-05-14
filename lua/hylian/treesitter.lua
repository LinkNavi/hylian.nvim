-- lua/hylian/treesitter.lua
-- Registers the Hylian tree-sitter parser with nvim-treesitter.
-- Called automatically by plugin/hylian.lua when nvim-treesitter is present.

local M = {}

M.parser_config = {
  hylian = {
    install_info = {
      url           = "https://github.com/LinkNavi/tree-sitter-hylian",
      branch        = "main",
      files         = { "src/parser.c" },
      generate_requires_npm = false,
      requires_generate_from_grammar = false,
    },
    filetype = "hylian",
  },
}

function M.setup()
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    return
  end

  local configs = parsers.get_parser_configs()
  if configs.hylian then
    -- already registered (e.g. user called setup twice)
    return
  end

  configs.hylian = M.parser_config.hylian
end

return M

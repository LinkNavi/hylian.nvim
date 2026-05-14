#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GRAMMAR_DIR="$SCRIPT_DIR/../../grammar"
PARSER_SRC="$GRAMMAR_DIR/src/parser.c"
QUERIES_SRC="$GRAMMAR_DIR/queries"

PARSER_DST="$HOME/.local/share/nvim/site/parser"
QUERIES_DST="$HOME/.config/nvim/after/queries/hylian"
PLUGIN_DST="$HOME/.config/nvim/lua/plugins/hylian.lua"

# Compile the parser
echo "Compiling hylian tree-sitter parser..."
mkdir -p "$PARSER_DST"
cc -O2 -o "$PARSER_DST/hylian.so" -shared -fPIC "$PARSER_SRC"
echo "Parser installed to $PARSER_DST/hylian.so"

# Install queries
echo "Installing queries..."
mkdir -p "$QUERIES_DST"
cp "$QUERIES_SRC"/*.scm "$QUERIES_DST/"
echo "Queries installed to $QUERIES_DST"

# Install the Neovim plugin config
echo "Installing hylian.lua..."
mkdir -p "$(dirname "$PLUGIN_DST")"
cp "$SCRIPT_DIR/hylian.lua" "$PLUGIN_DST"
echo "Plugin config installed to $PLUGIN_DST"

echo "Done! Restart Neovim to apply changes."

rm -fr ~/tmp/tree-sitter-hylian
mkdir -p ~/tmp
cd ~/Programming/Hylian
git clone git@github.com:LinkNavi/tree-sitter-hylian.git ~/tmp/tree-sitter-hylian
  ./.dev/sync-tree-sitter-repo.sh ~/tmp/tree-sitter-hylian
cd ~/tmp/tree-sitter-hylian
  git add -A
  git commit -m 'sync grammar with Hylian compiler'
  git push origin master
cd ~/Programming/Hylian/lsp/editors/nvim

#!/usr/bin/env fish
# fish には bash の `set -e` 相当が無いので書かない

# fisher 本体
if not functions -q fisher
    curl -fsSL https://git.io/fisher | source
    fisher install jorgebucaran/fisher
end

# === Plugins & Theme ===
set PLUGS \
    'oh-my-fish/plugin-peco' \
    'decors/fish-ghq' \
    'jethrokuan/z' \
    '0rax/fish-bd' \
    'oh-my-fish/theme-neolambda'

for p in $PLUGS
    fisher install $p
end

#!/usr/bin/env fish
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
    'ipatch/theme-neolambda'

for p in $PLUGS
    fisher install $p
end

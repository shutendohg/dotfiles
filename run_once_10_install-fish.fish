#!/usr/bin/env fish
# ---------------------------------------------------------------------------
# Why do we split the setup into two run-once scripts?
#
# run_once_10_install-fish.fish  →  "Install, but don't execute"
#   • Installs Fisher, bass, fish-nvm, and other plugins/theme.
#   • Only drops files into ~/.config/fish; the parent shell (bash in CI)
#     remains unchanged, so nvm is **not yet loaded**.
#
# run_once_20_install-node.fish  →  "Execute immediately"
#   • Needs nvm right now to download Node.js.
#   • If we are in CI (non-login bash shell) the fish plugins have been
#     installed but haven't run, so we explicitly load nvm:
#         bass source (nvm init - | psub)
#   • Then we install the stable Node + global npm packages.
#
# Result
#   - Local machine: first login after chezmoi apply → fish autoloads nvm,
#     Node already present.  No duplicate work on later applies.
#   - CI: everything runs in one non-interactive session; this split ensures
#     Node is available even though fish hasn't been re-invoked.
# ---------------------------------------------------------------------------

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

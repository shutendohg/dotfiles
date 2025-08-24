#!/usr/bin/env bash
set -euo pipefail

# Skip on CI
if [ -n "${CI:-}" ]; then
    exit 0
fi

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Not use install_plugins(need to prefix + I)

#!/usr/bin/env bash
set -euo pipefail
git config --global user.name "shutendohg"
git config --global user.email "shutendohg@gmail.com"
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519 # ← *.pub でなく秘密鍵パス
git config --global commit.gpgsign true

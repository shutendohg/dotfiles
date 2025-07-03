#!/usr/bin/env fish
set -e
# nvm は fisher プラグインで入っている前提
if not type -q node
    nvm install stable --latest-npm
    nvm alias default node
end
npm install -g git-cz

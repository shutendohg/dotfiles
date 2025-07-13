if status is-interactive
    # Commands to run in interactive sessions can go here
end

set GHQ_SELECTOR peco

function fish_user_key_bindings
    bind \cr peco_select_history # history search by peco
end

function peco_select_history
    commandline (history | head -n 100 | peco --prompt "Search> ")
end

function g
    cd (ghq list --full-path | peco)
end

set -U fish_user_paths $HOME/go/bin $fish_user_paths

set -l npm_bin (command npm prefix -g 2>/dev/null)/bin
if test -d $npm_bin; and not contains $npm_bin $fish_user_paths
    set -U fish_user_paths $npm_bin $fish_user_paths
end

if status --is-login
    if not pgrep -x ssh-agent > /dev/null
        eval (ssh-agent -c)
    end
    if not ssh-add -l | grep -q "id_ed25519"
        ssh-add ~/.ssh/id_ed25519 &>/dev/null
    end
end



alias vim nvim
alias vi nvim

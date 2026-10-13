source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

pyenv init - fish | source
starship init fish | source
zoxide init fish | source

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	command yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
		builtin cd -- "$cwd"
	end
	command rm -f -- "$tmp"
end

# Keep fastfetch entry upon doing clear or Ctrl+L on terminal
function clear
	command clear
	fastfetch
end
function fish_user_key_bindings
    bind \cl 'clear; commandline -f execute'
end

set -gx EDITOR "nvim"

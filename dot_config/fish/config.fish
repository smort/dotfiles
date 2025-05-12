# Initial fish configuration
if test -d ~/.local/bin
    set -U fish_user_paths ~/.local/bin $fish_user_paths
end

# Set up fzf key bindings
fzf --fish | source

starship init fish | source

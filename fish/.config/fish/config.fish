# Initial fish configuration
if test -d ~/.local/bin
    set -U fish_user_paths ~/.local/bin $fish_user_paths
end

fish_add_path /home/linuxbrew/.linuxbrew/bin

# Set up fzf key bindings
fzf --fish | source

# fnm initialization
source ~/.config/fish/conf.d/fnm.fish

starship init fish | source

# Initial fish configuration
if test -d ~/.local/bin
    set -U fish_user_paths ~/.local/bin $fish_user_paths
end

fish_add_path /home/linuxbrew/.linuxbrew/bin
fish_add_path /home/smort/go/bin

# Load environment variables from ~/.env
if test -f ~/.env
    while read -l line
        set line (string trim -- $line)

        if test -z "$line"
            continue
        end

        if string match -qr '^#' -- $line
            continue
        end

        set parts (string split -m1 '=' -- $line)
        if test (count $parts) -ne 2
            continue
        end

        set key (string trim -- $parts[1])
        set value (string trim -- $parts[2])

        if string match -qr '^".*"$' -- $value
            set value (string sub -s 2 -e -1 -- $value)
        else if string match -qr "^'.*'\$" -- $value
            set value (string sub -s 2 -e -1 -- $value)
        end

        if string match -qr '^[A-Za-z_][A-Za-z0-9_]*$' -- $key
            set -gx $key $value
        end
    end < ~/.env
end

# Set up fzf key bindings
fzf --fish | source

# fnm initialization
source ~/.config/fish/conf.d/fnm.fish

starship init fish | source

# pnpm
set -gx PNPM_HOME "/home/smort/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

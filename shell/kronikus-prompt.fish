# 🥽 Kronikus prompt for fish — same look as kronikus-prompt.bash
#
#   ╭─ 🥽 Kronikus  in 📂 ~/code/app  on ⎇ main
#   ╰─❯ npm test
#   ✅ npm test · ⏱ 3.4s · 🕒 14:02:11
#
# Source it from ~/.config/fish/config.fish:  source ~/.config/kronikus/prompt.fish
# Same settings as the bash version (ksettings, or set them before sourcing):
#   KRONIKUS_NAME, KRONIKUS_AVATAR, KRONIKUS_ANIM, KRONIKUS_ANIM_MIN,
#   KRONIKUS_PICTURE, KRONIKUS_GREET, KRONIKUS_TIPS, KRONIKUS_ASK_TAB, KRONIKUS_STARSHIP,
#   KRONIKUS_SIGN, KRONIKUS_SIGN_COLOR, KRONIKUS_LAST, KRONIKUS_NOTIFY, KRONIKUS_NOTIFY_MIN

status is-interactive; or return

# Settings saved by ksettings (KRONIKUS_*=value). A variable already set above still wins.
# Read again before every prompt, so ⚙ changes reach shells that are already open.
set -g __k_settings (set -q XDG_CONFIG_HOME; and echo $XDG_CONFIG_HOME; or echo ~/.config)/kronikus/settings
# Yours, taken before the defaults below exist.
set -q __k_own; or set -g __k_own (set -n | string match 'KRONIKUS_*')
function __k_load
    test -f $__k_settings; or return
    for line in (string match -r '^KRONIKUS_\w+=.*' <$__k_settings)
        set -l kv (string split -m1 = -- $line)
        contains -- $kv[1] $__k_own; or set -g $kv[1] $kv[2]
    end
end
__k_load

set -q KRONIKUS_NAME; or set -g KRONIKUS_NAME Kronikus
set -q KRONIKUS_AVATAR; or set -g KRONIKUS_AVATAR 🥽
set -q KRONIKUS_ANIM; or set -g KRONIKUS_ANIM 1
set -q KRONIKUS_ANIM_MIN; or set -g KRONIKUS_ANIM_MIN 2
set -q KRONIKUS_PICTURE; or set -g KRONIKUS_PICTURE ~/.config/kronikus/avatar.png
set -q KRONIKUS_GREET; or set -g KRONIKUS_GREET 1
set -q KRONIKUS_TIPS; or set -g KRONIKUS_TIPS 1
set -q KRONIKUS_ASK_TAB; or set -g KRONIKUS_ASK_TAB 1
set -q KRONIKUS_STARSHIP; or set -g KRONIKUS_STARSHIP ~/.config/kronikus/starship.toml
set -q KRONIKUS_SIGN; or set -g KRONIKUS_SIGN ❯
set -q KRONIKUS_SIGN_COLOR; or set -g KRONIKUS_SIGN_COLOR magenta
set -q KRONIKUS_LAST; or set -g KRONIKUS_LAST 1
set -q KRONIKUS_NOTIFY; or set -g KRONIKUS_NOTIFY away
set -q KRONIKUS_NOTIFY_MIN; or set -g KRONIKUS_NOTIFY_MIN 5

# What you type: the same roles as in the editors, in terminal colors so ktheme changes them.
set -g fish_color_keyword magenta
set -g fish_color_command blue
set -g fish_color_param normal
set -g fish_color_option normal
set -g fish_color_quote green
set -g fish_color_escape cyan
set -g fish_color_operator cyan
set -g fish_color_redirection cyan
set -g fish_color_end brblack
set -g fish_color_comment brblack
set -g fish_color_autosuggestion brblack
set -g fish_color_error red

# Inside tmux: remember the session, so each command can save "folder + last command" for gterminal.
set -g __k_tmux
set -g __k_state (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo ~/.local/state)/kronikus/tmux
if set -q TMUX
    set __k_tmux (tmux display -p -t "$TMUX_PANE" '#S' 2>/dev/null)
    mkdir -p $__k_state
    # Your avatar + name at the left of the tmux bar.
    tmux set -g @k-avatar "$KRONIKUS_AVATAR" \; set -g @k-user "$KRONIKUS_NAME" 2>/dev/null
end

# Current git branch, found by walking up to .git/HEAD (no git process spawned).
function __k_branch
    set -l dir $PWD
    while test -n "$dir"
        if test -f "$dir/.git/HEAD"
            read -l head <"$dir/.git/HEAD"
            if string match -q 'ref:*' -- $head
                string replace 'ref: refs/heads/' '' -- $head
            else
                string sub -l 7 -- $head
            end
            return
        end
        set dir (string replace -r '/[^/]*$' '' -- $dir)
    end
end

# The latest command in the tmux bar, kept per pane so each terminal shows its own.
# Style codes are ours; in the command itself a # must stay a plain # for tmux, and the
# space at the end keeps a final ; from being read as tmux's command separator.
function __k_last -a line info
    set -q TMUX_PANE; and test "$KRONIKUS_LAST" = 1; or return
    set line (string join ' ' -- (string split \n -- $line) | string replace -ra '[[:cntrl:]]' ' ' | string replace -a '#' '##')
    tmux set -p -t "$TMUX_PANE" @k-last "$line " \; set -p -t "$TMUX_PANE" @k-last-info "$info" 2>/dev/null
end

function __k_preexec --on-event fish_preexec
    test -n "$(string trim -- $argv[1])"; or return
    __k_last $argv[1] '#[fg=yellow]⏳ running#[default]'
end

# After each command: what ran, ✅/❌, how long, when it finished.
function __k_postexec --on-event fish_postexec
    set -l st $status
    test -n "$(string trim -- $argv[1])"; or return
    set -l ms $CMD_DURATION
    set -l dur
    if test $ms -lt 1000
        set dur {$ms}ms
    else if test $ms -lt 60000
        set dur (math -s0 $ms / 1000).(math -s0 "$ms % 1000 / 100")s
    else
        set dur (math -s0 $ms / 60000)m(math -s0 "$ms % 60000 / 1000")s
    end
    set -l icon ✅
    test $st -ne 0; and set icon "❌ "(set_color red)"[$st]"(set_color normal)

    if test "$KRONIKUS_ANIM" = 1; and test $ms -ge (math $KRONIKUS_ANIM_MIN \* 1000)
        for f in ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏
            printf '\r\e[35m%s\e[0m ' $f
            sleep 0.02
        end
        printf '\r\e[K'
    end
    set -l now (date +%H:%M:%S)
    printf '%s %s \e[2m· ⏱ %s · 🕒 %s\e[0m\n' $icon $argv[1] $dur $now
    set -l info '#[fg=green]✅#[default]'
    test $st -ne 0; and set info "#[fg=red]#[bold]❌ $st#[default]"
    __k_last $argv[1] "$info #[fg=brightblack]· ⏱ $dur · 🕒 $now#[default]"
    if test "$KRONIKUS_NOTIFY" != off; and test $ms -ge (math $KRONIKUS_NOTIFY_MIN \* 1000); and command -q knotify
        command knotify $KRONIKUS_NOTIFY $st $dur (string join ' ' -- (string split \n -- $argv[1])) &>/dev/null &
        disown 2>/dev/null
    end
    if test -n "$__k_tmux"; and not string match -q "gterminal*" -- $argv[1]
        # Asked every time: the session may have been renamed since this shell started.
        # ⚡ quick sessions (gterminal) are never saved, so they answer nothing.
        set __k_tmux (tmux display -p -t "$TMUX_PANE" '#{?@k-quick,,#S}' 2>/dev/null)
        test -n "$__k_tmux"
        and printf '%s\n%s\n' $PWD (string join '; ' -- (string split \n -- $argv[1])) >$__k_state/$__k_tmux
    end
end

function fish_prompt
    set -l st $status
    __k_load
    set -l arrow $KRONIKUS_SIGN_COLOR
    test "$arrow" = text; and set arrow normal
    test $st -ne 0; and set arrow red
    set -l branch (__k_branch)

    printf '\n%s╭─%s %s %s%s%s %sin%s 📂 %s%s%s' \
        (set_color brblack) (set_color normal) $KRONIKUS_AVATAR \
        (set_color -o magenta) $KRONIKUS_NAME (set_color normal) \
        (set_color -d) (set_color normal) \
        (set_color cyan) (string replace -r "^$HOME" '~' -- $PWD) (set_color normal)
    if test -n "$branch"
        set -l git
        # starship only runs inside a repo, for its branch + status icons ( main !? ⇡1)
        test -f "$KRONIKUS_STARSHIP"; and command -q starship
        and set git (STARSHIP_SHELL=fish STARSHIP_CONFIG=$KRONIKUS_STARSHIP starship prompt | string replace -a \e'[J' '')
        test -n "$git"; or set git (set_color green)"⎇ $branch"(set_color normal)
        printf ' %son%s %s' (set_color -d) (set_color normal) "$git"
    end
    set -l sign $KRONIKUS_SIGN
    test "$sign" = '$'; and fish_is_root_user; and set sign '#'
    printf '\n%s╰─%s%s%s ' (set_color brblack) (set_color $arrow) "$sign" (set_color normal)
end

function fish_title
    set -l dir (path basename -- $PWD)
    test -z "$dir"; and set dir /
    echo "👻 $dir"
end

# A new tmux tab asks for its name once, right before its first prompt.
# ⏎ keeps the automatic name (the running program); splits and restored sessions don't ask.
function __k_ask_tab --on-event fish_prompt
    functions -e __k_ask_tab
    test "$KRONIKUS_ASK_TAB" = 1; and set -q TMUX; and isatty stdin; or return
    set -l info (string split -m2 '|' -- (tmux display -p -t "$TMUX_PANE" '#{window_panes}|#{@k-asked}|#{?automatic-rename,,#{window_name}}' 2>/dev/null))
    test "$info[1]" = 1; and test -z "$info[2]"; or return
    test -n "$info[3]"; or set info[3] fish  # automatic names follow the program, here fish
    tmux set -w -t "$TMUX_PANE" @k-asked 1
    read -l -P (set_color magenta)'✎'(set_color normal)" name this tab "(set_color -d)"(⏎ keeps $info[3])"(set_color normal)': ' name
    or return
    set name (string trim -- $name)
    test "$name" = exit; and exit  # e.g. the tour says "type exit" in a fresh tab
    test -n "$name"; and tmux rename-window -t "$TMUX_PANE" -- "$name"
end

# Tiny round picture + name (+ a tip), once per new terminal (kitty graphics protocol, 4×2 cells).
function fish_greeting
    # Not inside tmux, where every new pane would greet again; except the first shell
    # of a ⚡ quick session (gterminal), which stands in for a plain terminal.
    test "$KRONIKUS_GREET" = 1; and begin; not set -q TMUX; or set -q KRONIKUS_GREET_HERE; end; or return
    if set -q KRONIKUS_GREET_HERE
        set -e KRONIKUS_GREET_HERE
        tmux set-environment -t "$TMUX_PANE" -u KRONIKUS_GREET_HERE 2>/dev/null
    end
    if begin; test "$TERM_PROGRAM" = ghostty; or test "$TERM" = xterm-kitty; end; and test -f "$KRONIKUS_PICTURE"
        set -l data (base64 -w0 $KRONIKUS_PICTURE)
        set -l ctl 'f=100,a=T,c=4,r=2,C=1,q=2,'
        while test -n "$data"
            set -l chunk (string sub -l 4096 -- $data)
            set data (string sub -s 4097 -- $data)
            set -l more 0
            test -n "$data"; and set more 1
            printf '\e_G%sm=%d;%s\e\\' $ctl $more $chunk
            set ctl ''
        end
        printf '     '
    else
        printf '%s ' $KRONIKUS_AVATAR
    end
    printf '\e[1;35m%s\e[0m \e[2mis back\e[0m\n' $KRONIKUS_NAME
    printf '     \e[2m%s\e[0m\n' (date '+%A %d %b · %H:%M')
    # First terminal ever: offer the tour (asked once). After that: a tip.
    set -l state (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo ~/.local/state)/kronikus
    if not test -e $state/welcomed; and command -q ktour
        ktour --first-run
    else if test "$KRONIKUS_TIPS" = 1; and command -q ktips
        printf '     '
        ktips --one
    end
end

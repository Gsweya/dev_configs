# 🥽 Kronikus prompt for fish — same look as kronikus-prompt.bash
#
#   ╭─ 🥽 Kronikus  in 📂 ~/code/app  on ⎇ main
#   ╰─❯ npm test
#   ✅ npm test · ⏱ 3.4s · 🕒 14:02:11
#
# Source it from ~/.config/fish/config.fish:  source ~/.config/kronikus/prompt.fish
# Same settings as the bash version (set them before sourcing):
#   KRONIKUS_NAME, KRONIKUS_AVATAR, KRONIKUS_ANIM, KRONIKUS_ANIM_MIN,
#   KRONIKUS_PICTURE, KRONIKUS_GREET

status is-interactive; or return

set -q KRONIKUS_NAME; or set -g KRONIKUS_NAME Kronikus
set -q KRONIKUS_AVATAR; or set -g KRONIKUS_AVATAR 🥽
set -q KRONIKUS_ANIM; or set -g KRONIKUS_ANIM 1
set -q KRONIKUS_ANIM_MIN; or set -g KRONIKUS_ANIM_MIN 2
set -q KRONIKUS_PICTURE; or set -g KRONIKUS_PICTURE ~/.config/kronikus/avatar.png
set -q KRONIKUS_GREET; or set -g KRONIKUS_GREET 1

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
    printf '%s %s \e[2m· ⏱ %s · 🕒 %s\e[0m\n' $icon $argv[1] $dur (date +%H:%M:%S)
end

function fish_prompt
    set -l st $status
    set -l arrow magenta
    test $st -ne 0; and set arrow red
    set -l branch (__k_branch)

    printf '\n%s╭─%s %s %s%s%s %sin%s 📂 %s%s%s' \
        (set_color magenta) (set_color normal) $KRONIKUS_AVATAR \
        (set_color -o magenta) $KRONIKUS_NAME (set_color normal) \
        (set_color -d) (set_color normal) \
        (set_color cyan) (string replace -r "^$HOME" '~' -- $PWD) (set_color normal)
    test -n "$branch"; and printf ' %son%s %s⎇ %s%s' \
        (set_color -d) (set_color normal) (set_color green) $branch (set_color normal)
    printf '\n%s╰─%s❯%s ' (set_color magenta) (set_color $arrow) (set_color normal)
end

function fish_title
    set -l dir (path basename -- $PWD)
    test -z "$dir"; and set dir /
    echo "👻 $dir"
end

# Tiny round picture + name, once per new terminal (kitty graphics protocol, 4×2 cells).
function fish_greeting
    test "$KRONIKUS_GREET" = 1; or return
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
end

# 🥽 Kronikus prompt — a lightweight bash prompt (pure bash, no extra tools)
#
#   ╭─ 🥽 Kronikus  in 📂 ~/code/app  on ⎇ main
#   ╰─❯ npm test
#   ⠹ …                                   (quick spinner, only for slow commands)
#   ✅ npm test · ⏱ 3.4s · 🕒 14:02:11
#
# Source it from ~/.bashrc:  source ~/.config/kronikus/prompt.bash
# Tweak with ksettings (saved in ~/.config/kronikus/settings), or env vars set *before* sourcing:
#   KRONIKUS_NAME    display name           (default: Kronikus)
#   KRONIKUS_AVATAR  small profile icon     (default: 🥽)
#   KRONIKUS_ANIM    1 = spinner on finish  (default: 1)
#   KRONIKUS_ANIM_MIN  min seconds before the spinner plays (default: 2)
#   KRONIKUS_PICTURE   picture shown once when a terminal opens (Ghostty/kitty only)
#   KRONIKUS_GREET   1 = show that greeting (default: 1)
#   KRONIKUS_TIPS    1 = add a random tip to it, from ktips (default: 1)
#                    the very first terminal asks "take the tour?" (ktour) instead
#   KRONIKUS_ASK_TAB 1 = a new tmux tab asks for its name, ⏎ keeps the automatic one (default: 1)
#   KRONIKUS_SIGN    the ❯ before your command, any short text like $ or # (default: ❯)
#                    $ turns into # when you are root
#   KRONIKUS_SIGN_COLOR  magenta, cyan, green, yellow, blue or text (default: magenta)
#   KRONIKUS_LAST    1 = show the latest command in the tmux bar (default: 1)
#   KRONIKUS_NOTIFY  away = 🔔 when a slow command ends and you are not looking,
#                    always, or off (default: away, see knotify)
#   KRONIKUS_NOTIFY_MIN  seconds that count as slow (default: 5)
#   KRONIKUS_STARSHIP  starship config for the git part (default: ~/.config/kronikus/starship.toml)
#                      if starship or this file is missing, a plain ⎇ branch is shown

[[ $- == *i* ]] || return

# Settings saved by ksettings (KRONIKUS_*=value). A variable already set above still wins.
# Read again before every prompt, so ⚙ changes reach shells that are already open.
__k_settings=${XDG_CONFIG_HOME:-$HOME/.config}/kronikus/settings
__k_own=${__k_own-" ${!KRONIKUS_*} "}  # yours, taken before the defaults below exist
__k_load() {
    [[ -f $__k_settings ]] || return
    local k v
    while IFS='=' read -r k v; do
        [[ $k == KRONIKUS_* && $__k_own != *" $k "* ]] && printf -v "$k" '%s' "$v"
    done < "$__k_settings"
}
__k_load

KRONIKUS_NAME=${KRONIKUS_NAME:-Kronikus}
KRONIKUS_AVATAR=${KRONIKUS_AVATAR:-🥽}
KRONIKUS_ANIM=${KRONIKUS_ANIM:-1}
KRONIKUS_ANIM_MIN=${KRONIKUS_ANIM_MIN:-2}
KRONIKUS_PICTURE=${KRONIKUS_PICTURE:-$HOME/.config/kronikus/avatar.png}
KRONIKUS_GREET=${KRONIKUS_GREET:-1}
KRONIKUS_TIPS=${KRONIKUS_TIPS:-1}
KRONIKUS_ASK_TAB=${KRONIKUS_ASK_TAB:-1}
KRONIKUS_STARSHIP=${KRONIKUS_STARSHIP:-$HOME/.config/kronikus/starship.toml}
KRONIKUS_SIGN=${KRONIKUS_SIGN:-❯}
KRONIKUS_SIGN_COLOR=${KRONIKUS_SIGN_COLOR:-magenta}
KRONIKUS_LAST=${KRONIKUS_LAST:-1}
KRONIKUS_NOTIFY=${KRONIKUS_NOTIFY:-away}
KRONIKUS_NOTIFY_MIN=${KRONIKUS_NOTIFY_MIN:-5}

__k_ready=
__k_start=
__k_cmd=
__k_status=0
__k_starship=
[[ -f $KRONIKUS_STARSHIP ]] && __k_starship=$(type -P starship)
__k_knotify=$(type -P knotify)

# Inside tmux: remember the session, so each command can save "folder + last command" for gterminal.
__k_tmux=
__k_state=${XDG_STATE_HOME:-$HOME/.local/state}/kronikus/tmux
if [[ -n $TMUX ]]; then
    __k_tmux=$(tmux display -p -t "$TMUX_PANE" '#S' 2>/dev/null)
    mkdir -p "$__k_state"
    # Your avatar + name at the left of the tmux bar.
    tmux set -g @k-avatar "$KRONIKUS_AVATAR" \; set -g @k-user "$KRONIKUS_NAME" 2>/dev/null
fi

# Current git branch, found by walking up to .git/HEAD (no git process spawned).
__k_branch() {
    local dir=$PWD head
    while [[ -n $dir ]]; do
        if [[ -f $dir/.git/HEAD ]]; then
            read -r head < "$dir/.git/HEAD"
            [[ $head == ref:* ]] && printf '%s' "${head#ref: refs/heads/}" || printf '%.7s' "$head"
            return
        fi
        dir=${dir%/*}
    done
}

# The latest command in the tmux bar, kept per pane so each terminal shows its own.
# Style codes are ours; in the command itself a # must stay a plain # for tmux, and the
# space at the end keeps a final ; from being read as tmux's command separator.
__k_last() {
    [[ -n $TMUX_PANE && $KRONIKUS_LAST == 1 ]] || return
    local line=${1//[[:cntrl:]]/ }
    tmux set -p -t "$TMUX_PANE" @k-last "${line//#/##} " \; set -p -t "$TMUX_PANE" @k-last-info "$2" 2>/dev/null
}

# Runs right before each command typed at the prompt.
__k_preexec() {
    [[ -n $__k_ready && -z $COMP_LINE ]] || return
    __k_ready=
    # Empty Enter: the first thing to run is PROMPT_COMMAND itself, not a user command.
    [[ $BASH_COMMAND == '__k_status=$?' ]] && return
    local h
    h=$(HISTTIMEFORMAT= history 1)
    [[ $h =~ ^\ *[0-9]+\*?\ +(.*)$ ]] && __k_cmd=${BASH_REMATCH[1]} || __k_cmd=$BASH_COMMAND
    __k_start=${EPOCHREALTIME//[.,]/}
    __k_last "$__k_cmd" '#[fg=yellow]⏳ running#[default]'
}

# Runs before each prompt: prints the summary of the last command, then builds PS1.
__k_precmd() {
    local st=$__k_status
    __k_load
    if [[ -n $__k_start ]]; then
        local us=$(( ${EPOCHREALTIME//[.,]/} - __k_start )) dur icon
        local ms=$(( us / 1000 ))
        if (( ms < 1000 )); then dur="${ms}ms"
        elif (( ms < 60000 )); then dur="$(( ms / 1000 )).$(( ms % 1000 / 100 ))s"
        else dur="$(( ms / 60000 ))m$(( ms % 60000 / 1000 ))s"
        fi
        (( st == 0 )) && icon='✅' || icon="❌ \e[31m[$st]\e[0m"

        if [[ $KRONIKUS_ANIM == 1 ]] && (( ms >= KRONIKUS_ANIM_MIN * 1000 )); then
            local f
            for f in ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏; do
                printf '\r\e[35m%s\e[0m ' "$f"
                read -rt 0.02 <> <(:) || :
            done
            printf '\r\e[K'
        fi
        printf "$icon %s \e[2m· ⏱ %s · 🕒 %(%H:%M:%S)T\e[0m\n" "$__k_cmd" "$dur" -1
        local info
        (( st == 0 )) && info='#[fg=green]✅#[default]' || info="#[fg=red]#[bold]❌ $st#[default]"
        printf -v info '%s #[fg=brightblack]· ⏱ %s · 🕒 %(%H:%M:%S)T#[default]' "$info" "$dur" -1
        __k_last "$__k_cmd" "$info"
        if [[ $KRONIKUS_NOTIFY != off && -n $__k_knotify ]] && (( ms >= KRONIKUS_NOTIFY_MIN * 1000 )); then
            ( "$__k_knotify" "$KRONIKUS_NOTIFY" "$st" "$dur" "$__k_cmd" >/dev/null 2>&1 & )
        fi
        if [[ -n $__k_tmux && $__k_cmd != gterminal* ]]; then
            # Asked every time: the session may have been renamed since this shell started.
            # ⚡ quick sessions (gterminal) are never saved, so they answer nothing.
            __k_tmux=$(tmux display -p -t "$TMUX_PANE" '#{?@k-quick,,#S}' 2>/dev/null)
            [[ -n $__k_tmux ]] && printf '%s\n%s\n' "$PWD" "$__k_cmd" > "$__k_state/$__k_tmux"
        fi
        __k_start=
    fi

    local dir=${PWD##*/}
    [[ -z $dir ]] && dir=/
    printf '\e]0;👻 %s\a' "$dir"

    local branch arrow=35 sign=$KRONIKUS_SIGN mark=
    branch=$(__k_branch)
    case $KRONIKUS_SIGN_COLOR in
        cyan) arrow=36 ;; green) arrow=32 ;; yellow) arrow=33 ;; blue) arrow=34 ;; text) arrow=39 ;;
    esac
    (( st != 0 )) && arrow=31
    # \$ is bash's own $ / # for root; the other two would otherwise run as code in PS1.
    sign=${sign//\\/\\\\} sign=${sign//\$/\\\$} sign=${sign//\`/\\\`}
    # Tells tmux where this prompt starts, for ▲ ▼ and Alt+↑ ↓.
    [[ -n $TMUX ]] && mark='\[\e]133;A\a\]'
    PS1="\n$mark\[\e[90m\]╭─\[\e[0m\] ${KRONIKUS_AVATAR} \[\e[1;35m\]${KRONIKUS_NAME}\[\e[0m\] \[\e[2m\]in\[\e[0m\] 📂 \[\e[36m\]\w\[\e[0m\]"
    if [[ -n $branch ]]; then
        local git=
        # starship only runs inside a repo, for its branch + status icons ( main !? ⇡1)
        [[ -n $__k_starship ]] && git=$(STARSHIP_SHELL=bash STARSHIP_CONFIG=$KRONIKUS_STARSHIP "$__k_starship" prompt)
        [[ -z $git ]] && git="\[\e[32m\]⎇ ${branch//\\/\\\\}\[\e[0m\]"
        PS1+=" \[\e[2m\]on\[\e[0m\] $git"
    fi
    PS1+="\n\[\e[90m\]╰─\[\e[${arrow}m\]${sign}\[\e[0m\] "
    __k_ready=1
    __k_ask_tab
}

# A new tmux tab asks for its name once, right before its first prompt.
# ⏎ keeps the automatic name (the running program); splits and restored sessions don't ask.
__k_asked=
__k_ask_tab() {
    [[ -z $__k_asked && $KRONIKUS_ASK_TAB == 1 && -n $TMUX && -t 0 ]] || return
    __k_asked=1
    local panes asked auto name
    IFS='|' read -r panes asked auto < <(tmux display -p -t "$TMUX_PANE" '#{window_panes}|#{@k-asked}|#{?automatic-rename,,#{window_name}}' 2>/dev/null)
    [[ $panes == 1 && -z $asked ]] || return
    auto=${auto:-${0##*[-/]}}  # automatic names follow the program, here the shell
    tmux set -w -t "$TMUX_PANE" @k-asked 1
    read -r -e -p $'\001\e[35m\002✎\001\e[0m\002 name this tab \001\e[2m\002(⏎ keeps '"$auto"$')\001\e[0m\002: ' name || { echo; return; }
    name=${name#"${name%%[![:space:]]*}"} name=${name%"${name##*[![:space:]]}"}
    [[ $name == exit ]] && exit  # e.g. the tour says "type exit" in a fresh tab
    [[ -n $name ]] && tmux rename-window -t "$TMUX_PANE" -- "$name"
}

# Tiny round picture + name (+ a tip), once per new terminal (kitty graphics protocol, 4×2 cells).
__k_greet() {
    # Not inside tmux, where every new pane would greet again; except the first shell
    # of a ⚡ quick session (gterminal), which stands in for a plain terminal.
    [[ $KRONIKUS_GREET == 1 && ( -z $TMUX || -n $KRONIKUS_GREET_HERE ) ]] || return
    if [[ -n $KRONIKUS_GREET_HERE ]]; then
        unset KRONIKUS_GREET_HERE
        tmux set-environment -t "$TMUX_PANE" -u KRONIKUS_GREET_HERE 2>/dev/null
    fi
    if [[ ($TERM_PROGRAM == ghostty || $TERM == xterm-kitty) && -f $KRONIKUS_PICTURE ]]; then
        local data chunk ctl='f=100,a=T,c=4,r=2,C=1,q=2,'
        data=$(base64 -w0 "$KRONIKUS_PICTURE")
        while [[ -n $data ]]; do
            chunk=${data:0:4096} data=${data:4096}
            printf '\e_G%sm=%d;%s\e\\' "$ctl" "$([[ -n $data ]] && echo 1 || echo 0)" "$chunk"
            ctl=
        done
        printf '     '
    else
        printf '%s ' "$KRONIKUS_AVATAR"
    fi
    printf '\e[1;35m%s\e[0m \e[2mis back\e[0m\n' "$KRONIKUS_NAME"
    printf "     \e[2m%(%A %d %b · %H:%M)T\e[0m\n" -1
    # First terminal ever: offer the tour (asked once). After that: a tip.
    if [[ ! -e ${XDG_STATE_HOME:-$HOME/.local/state}/kronikus/welcomed ]] && type -P ktour >/dev/null; then
        ktour --first-run
    elif [[ $KRONIKUS_TIPS == 1 ]] && type -P ktips >/dev/null; then
        printf '     '; ktips --one
    fi
}
__k_greet

trap '__k_preexec' DEBUG
# Array form (bash 5.1+) so __k_precmd runs after every other hook (e.g. Fedora's systemd one).
PROMPT_COMMAND=('__k_status=$?' "${PROMPT_COMMAND[@]}" '__k_precmd')

# 🥽 Kronikus prompt — a lightweight bash prompt (pure bash, no extra tools)
#
#   ╭─ 🥽 Kronikus  in 📂 ~/code/app  on ⎇ main
#   ╰─❯ npm test
#   ⠹ …                                   (quick spinner, only for slow commands)
#   ✅ npm test · ⏱ 3.4s · 🕒 14:02:11
#
# Source it from ~/.bashrc:  source ~/.config/kronikus/prompt.bash
# Tweak with env vars set *before* sourcing:
#   KRONIKUS_NAME    display name           (default: Kronikus)
#   KRONIKUS_AVATAR  small profile icon     (default: 🥽)
#   KRONIKUS_ANIM    1 = spinner on finish  (default: 1)
#   KRONIKUS_ANIM_MIN  min seconds before the spinner plays (default: 2)
#   KRONIKUS_PICTURE   picture shown once when a terminal opens (Ghostty/kitty only)
#   KRONIKUS_GREET   1 = show that greeting (default: 1)

[[ $- == *i* ]] || return

KRONIKUS_NAME=${KRONIKUS_NAME:-Kronikus}
KRONIKUS_AVATAR=${KRONIKUS_AVATAR:-🥽}
KRONIKUS_ANIM=${KRONIKUS_ANIM:-1}
KRONIKUS_ANIM_MIN=${KRONIKUS_ANIM_MIN:-2}
KRONIKUS_PICTURE=${KRONIKUS_PICTURE:-$HOME/.config/kronikus/avatar.png}
KRONIKUS_GREET=${KRONIKUS_GREET:-1}

__k_ready=
__k_start=
__k_cmd=
__k_status=0

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
}

# Runs before each prompt: prints the summary of the last command, then builds PS1.
__k_precmd() {
    local st=$__k_status
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
        __k_start=
    fi

    local dir=${PWD##*/}
    [[ -z $dir ]] && dir=/
    printf '\e]0;👻 %s\a' "$dir"

    local branch arrow=35
    branch=$(__k_branch)
    (( st != 0 )) && arrow=31
    PS1="\n\[\e[35m\]╭─\[\e[0m\] ${KRONIKUS_AVATAR} \[\e[1;35m\]${KRONIKUS_NAME}\[\e[0m\] \[\e[2m\]in\[\e[0m\] 📂 \[\e[36m\]\w\[\e[0m\]"
    [[ -n $branch ]] && PS1+=" \[\e[2m\]on\[\e[0m\] \[\e[32m\]⎇ ${branch//\\/\\\\}\[\e[0m\]"
    PS1+="\n\[\e[35m\]╰─\[\e[${arrow}m\]❯\[\e[0m\] "
    __k_ready=1
}

# Tiny round picture + name, once per new terminal (kitty graphics protocol, 4×2 cells).
__k_greet() {
    [[ $KRONIKUS_GREET == 1 ]] || return
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
}
__k_greet

trap '__k_preexec' DEBUG
# Array form (bash 5.1+) so __k_precmd runs after every other hook (e.g. Fedora's systemd one).
PROMPT_COMMAND=('__k_status=$?' "${PROMPT_COMMAND[@]}" '__k_precmd')

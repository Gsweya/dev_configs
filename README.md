# dev_configs

Personal configs for the dev tools I use, mainly terminals.

| Folder | What's inside |
| --- | --- |
| `ghostty/` | [Ghostty](https://ghostty.org) terminal config (👻 Neon Night theme) |
| `shell/` | 👾 Kronikus bash prompt: avatar, name, folder, git branch, command timing |

## 👻 Ghostty

```sh
mkdir -p ~/.config/ghostty
cp ghostty/config.ghostty ~/.config/ghostty/config.ghostty
```

Reload inside Ghostty with `Ctrl+Shift+,` (or open a new window).
The config uses the [Lilex](https://github.com/mishamyrt/Lilex) font, so install it or change `font-family`.

## 👾 Kronikus prompt (bash)

What it looks like:

```
╭─ 👾 Kronikus  in 📂 ~/code/app  on ⎇ main
╰─❯ npm test
...
✅ npm test · ⏱ 3.4s · 🕒 14:02:11
```

- Shows the avatar, name, current folder and git branch
- After each command, prints what ran, ✅ or ❌ with the exit code, how long it took and when it finished
- Plays a short spinner when a slow command (2s or more) finishes
- The arrow turns red when the last command failed
- Pure bash with no extra tools. It reads the git branch from `.git/HEAD`, so it adds no lag

Setup (needs bash 5.1+):

```sh
mkdir -p ~/.config/kronikus
cp shell/kronikus-prompt.bash ~/.config/kronikus/prompt.bash
echo '[ -f ~/.config/kronikus/prompt.bash ] && source ~/.config/kronikus/prompt.bash' >> ~/.bashrc
```

Put the `source` line at the **end** of `~/.bashrc` so nothing overrides the prompt, then open a new terminal.
Remove any older `PS1=` or `PROMPT_COMMAND=` lines from `~/.bashrc` first.

Optional settings (put them above the `source` line):

```sh
export KRONIKUS_NAME="Kronikus"   # display name
export KRONIKUS_AVATAR="👾"       # small profile icon (any emoji)
export KRONIKUS_ANIM=1            # 0 turns off the finish spinner
export KRONIKUS_ANIM_MIN=2        # seconds before the spinner plays
```

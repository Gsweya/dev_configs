# dev_configs

Personal configs for the dev tools I use, mainly terminals.

| Folder | What's inside |
| --- | --- |
| `ghostty/` | [Ghostty](https://ghostty.org) terminal config (👻 Neon Night theme) |
| `shell/` | 🥽 Kronikus prompt for bash and fish: avatar, name, folder, git (with starship icons), command timing |
| `tmux/` | 👻 tmux config (mouse select = copy) and `gterminal`, a session picker that brings you back where you were |

## 👻 Ghostty

```sh
mkdir -p ~/.config/ghostty
cp ghostty/config.ghostty ~/.config/ghostty/config.ghostty
```

Reload inside Ghostty with `Ctrl+Shift+,` (or open a new window).
The config uses the [Lilex](https://github.com/mishamyrt/Lilex) font, so install it or change `font-family`.

📋 **Select = copy.** Anything you select with the mouse goes straight to the clipboard (`copy-on-select = clipboard`), so you can paste it anywhere with `Ctrl+V` / `Ctrl+Shift+V`.

## 🥽 Kronikus prompt (bash + fish)

What it looks like:

```
[pic] Kronikus is back            ← once per new terminal (not inside tmux)
      Tuesday 20 Oct · 19:21

╭─ 🥽 Kronikus  in 📂 ~/code/app  on  main !? ⇡1
╰─❯ npm test
...
✅ npm test · ⏱ 3.4s · 🕒 14:02:11
```

- Greets you with a tiny round profile picture (`shell/kronikus-avatar.png`) when a terminal opens. This needs Ghostty or kitty. Other terminals show the emoji instead
- Shows the avatar, name, current folder and git branch
- Inside a git repo, the branch and status icons come from [starship](https://starship.rs) (`!` modified, `+` staged, `?` untracked, `⇡`/`⇣` ahead/behind, …). It only uses starship for that part. Without starship you get a plain `⎇ main`
- After each command, prints what ran, ✅ or ❌ with the exit code, how long it took and when it finished
- Plays a short spinner when a slow command (2s or more) finishes
- The arrow turns red when the last command failed
- Pure bash otherwise. Outside a repo nothing extra runs, and inside one starship adds about 15ms
- Inside tmux it saves the folder and last command of each session for `gterminal`

### Setup

Copy the files (same for both shells):

```sh
mkdir -p ~/.config/kronikus
cp shell/kronikus-prompt.bash ~/.config/kronikus/prompt.bash
cp shell/kronikus-prompt.fish ~/.config/kronikus/prompt.fish
cp shell/kronikus-avatar.png  ~/.config/kronikus/avatar.png
cp shell/kronikus-starship.toml ~/.config/kronikus/starship.toml   # optional, needs starship
```

For the git icons, install [starship](https://starship.rs).
You don't need `starship init`, because the Kronikus prompt calls it itself.
The branch icon `` is a Nerd Font glyph. Ghostty has those built in, so Lilex works as is.

**bash** (needs bash 5.1+). Add this as the **last** line of `~/.bashrc` and remove any older `PS1=` or `PROMPT_COMMAND=` lines:

```sh
[ -f ~/.config/kronikus/prompt.bash ] && source ~/.config/kronikus/prompt.bash
```

**fish** (needs fish 3.4+). Add this to `~/.config/fish/config.fish` and remove any older `fish_prompt`, `fish_title` or `fish_greeting` functions:

```fish
test -f ~/.config/kronikus/prompt.fish; and source ~/.config/kronikus/prompt.fish
```

Then open a new terminal.

> 🖼️ **Change the picture!** `shell/kronikus-avatar.png` is just a placeholder (a mountain lake).
> Replace `~/.config/kronikus/avatar.png` with your own photo. A small square PNG of about 96×96 works best.
> With ImageMagick you can make a round one from any photo:
>
> ```sh
> magick me.jpg -gravity center -crop 1:1 +repage -resize 96x96 \
>   \( -size 96x96 xc:black -fill white -draw "circle 47.5,47.5 47.5,1" \) \
>   -alpha off -compose CopyOpacity -composite ~/.config/kronikus/avatar.png
> ```

### Optional settings

Set these above the `source` line.

bash:

```sh
export KRONIKUS_NAME="Kronikus"   # display name
export KRONIKUS_AVATAR="🥽"       # small profile icon (any emoji)
export KRONIKUS_ANIM=1            # 0 turns off the finish spinner
export KRONIKUS_ANIM_MIN=2        # seconds before the spinner plays
export KRONIKUS_GREET=1           # 0 turns off the picture greeting
export KRONIKUS_PICTURE=~/.config/kronikus/avatar.png
export KRONIKUS_STARSHIP=~/.config/kronikus/starship.toml  # starship config for the git part
```

fish: the same names, set like `set -g KRONIKUS_AVATAR 🥽`.

## 👻 tmux + gterminal

```sh
cp tmux/tmux.conf ~/.tmux.conf
mkdir -p ~/.local/bin
cp tmux/gterminal ~/.local/bin/gterminal
```

If tmux is already running, reload it with `tmux source ~/.tmux.conf`.

Type `gterminal` in any terminal (or press `prefix + s` inside tmux):

```
  👻 gterminal   🟢 2 live  💤 1 saved

  📋 SESSIONS                      │ ⚡ work
  ──────────────────────────────── │ ────────────────────────────────────────
  ❯ 🟢 work           🪟 2        │ 📂 ~/code/app
    🔵 api            🪟 1        │ 🕒 active 3m ago · attached
    💤 notes          saved       │ ❯  npm test
    ✨ new session                 │
                                   │ 🪟 WINDOWS
                                   │ ▸ 1 📝 editor     nvim · ~/code/app
                                   │   2 🟩 server     node · ~/code/app/api
                                   │
                                   │ 📜 RECENT OUTPUT
                                   │ │ Tests: 12 passed

  ↑↓ move   ⏎ open   1-9 jump   n new   x kill   q quit
```

- 🟢 / 🔵 **live** sessions (attached / in the background) reopen exactly as you left them
- 💤 **saved** sessions were closed or are gone after a reboot. Opening one starts it again **in the same folder** and **types the last command** for you, so `Enter` continues it
- The right panel shows the selected session's folder, last command, windows and what's on screen
- Saving needs the Kronikus prompt (bash or fish). It writes to `~/.local/state/kronikus/tmux/`
- Keys: `↑↓` or `j`/`k` move, `⏎` open, `1-9` jump to that row, `n` new session (asks for a name), `x` kill a live session or forget a saved one, `q` quit
- A saved session comes back in your default shell, so a fish command saved from a fish session is retyped in bash if bash is your default
- Pure bash, no fzf or other tools

The tmux config uses the Neon Night colors and makes the mouse work like a normal terminal:
**drag to select, let go and it's copied** to the system clipboard. Double-click copies a word and triple-click copies a line.
Hold `Shift` while dragging to use Ghostty's own selection instead.
New windows and splits open in the current folder.

# dev_configs

Personal configs for the dev tools I use, mainly terminals.

| Folder | What's inside |
| --- | --- |
| `ghostty/` | [Ghostty](https://ghostty.org) terminal config (👻 Neon Night theme) |
| `shell/` | 🥽 Kronikus prompt for bash and fish: avatar, name, folder, git branch, command timing |

## 👻 Ghostty

```sh
mkdir -p ~/.config/ghostty
cp ghostty/config.ghostty ~/.config/ghostty/config.ghostty
```

Reload inside Ghostty with `Ctrl+Shift+,` (or open a new window).
The config uses the [Lilex](https://github.com/mishamyrt/Lilex) font, so install it or change `font-family`.

## 🥽 Kronikus prompt (bash + fish)

What it looks like:

```
[pic] Kronikus is back            ← once per new terminal
      Tuesday 20 Oct · 19:21

╭─ 🥽 Kronikus  in 📂 ~/code/app  on ⎇ main
╰─❯ npm test
...
✅ npm test · ⏱ 3.4s · 🕒 14:02:11
```

- Greets you with a tiny round profile picture (`shell/kronikus-avatar.png`) when a terminal opens. This needs Ghostty or kitty. Other terminals show the emoji instead
- Shows the avatar, name, current folder and git branch
- After each command, prints what ran, ✅ or ❌ with the exit code, how long it took and when it finished
- Plays a short spinner when a slow command (2s or more) finishes
- The arrow turns red when the last command failed
- Pure bash with no extra tools. It reads the git branch from `.git/HEAD`, so it adds no lag

### Setup

Copy the files (same for both shells):

```sh
mkdir -p ~/.config/kronikus
cp shell/kronikus-prompt.bash ~/.config/kronikus/prompt.bash
cp shell/kronikus-prompt.fish ~/.config/kronikus/prompt.fish
cp shell/kronikus-avatar.png  ~/.config/kronikus/avatar.png
```

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
```

fish: the same names, set like `set -g KRONIKUS_AVATAR 🥽`.

# dev_configs

Personal configs for the dev tools I use, mainly terminals.

| Folder | What's inside |
| --- | --- |
| `ghostty/` | [Ghostty](https://ghostty.org) terminal config with 👻 Neon themes: 🌙 Night (dark) and ☀️ Day (light), following the desktop |
| `shell/` | 🥽 Kronikus prompt for bash and fish: avatar, name, folder, git (with starship icons), command timing |
| `tmux/` | 👻 tmux config (clickable bottom bar, mouse select = copy), `gterminal`, a session picker that brings you back where you were, `ktips` (shortcuts + tips), `ktheme` (theme picker) and `ktour` (hands-on tour) |

**New here?** Install everything (the sections below), open a new terminal and press `⏎` when it asks
*"First time here?"*. That starts 🎓 `ktour`, a 5-minute hands-on tour. You can run `ktour` again any time.

## 👻 Ghostty

```sh
mkdir -p ~/.config/ghostty/themes
cp ghostty/config.ghostty ~/.config/ghostty/config.ghostty
cp ghostty/themes/* ~/.config/ghostty/themes/
```

Reload inside Ghostty with `Ctrl+Shift+,` (or open a new window).
The config uses the [Lilex](https://github.com/mishamyrt/Lilex) font, so install it or change `font-family`.

🌗 **Light & dark.** `theme = light:Neon Day,dark:Neon Night` makes Ghostty follow your desktop:
☀️ Neon Day (lavender white, deep rose / mint / violet) when it's light, 🌙 Neon Night (deep navy, pastel neon) when it's dark.
It switches on its own when the desktop does. The prompt, tmux, gterminal and ktips only use the 16 terminal colors, so they follow along.

🎨 **Other themes.** Run `ktheme` (or click 🎨 in the tmux bar) to pick another one, see [ktheme](#-ktheme-theme-picker) below.
It writes `~/.config/ghostty/theme.ghostty`, which the `config-file = ?theme.ghostty` line pulls in, so `config.ghostty` itself never changes.

📋 **Select = copy.** Anything you select with the mouse goes straight to the clipboard (`copy-on-select = clipboard`), so you can paste it anywhere with `Ctrl+V` / `Ctrl+Shift+V`.

## 🥽 Kronikus prompt (bash + fish)

What it looks like:

```
[pic] Kronikus is back            ← once per new terminal (not inside tmux)
      Tuesday 20 Oct · 19:21
      💡 cd - jumps back to the folder you were in before

╭─ 🥽 Kronikus  in 📂 ~/code/app  on  main !? ⇡1
╰─❯ npm test
...
✅ npm test · ⏱ 3.4s · 🕒 14:02:11
```

- Greets you with a tiny round profile picture (`shell/kronikus-avatar.png`) when a terminal opens. This needs Ghostty or kitty. Other terminals show the emoji instead
- 💡 Adds a random tip under the greeting (a different one each time), if `ktips` is installed (see tmux below)
- 👋 The very first terminal asks *"First time here?"* instead, and `⏎` starts the tour (`ktour`). It asks only once
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
export KRONIKUS_TIPS=1            # 0 hides the tip under the greeting
export KRONIKUS_PICTURE=~/.config/kronikus/avatar.png
export KRONIKUS_STARSHIP=~/.config/kronikus/starship.toml  # starship config for the git part
```

fish: the same names, set like `set -g KRONIKUS_AVATAR 🥽`.

## 👻 tmux + gterminal

```sh
cp tmux/tmux.conf ~/.tmux.conf
mkdir -p ~/.local/bin
cp tmux/gterminal tmux/ktips tmux/ktheme tmux/ktour ~/.local/bin/
```

If tmux is already running, reload it with `tmux source ~/.tmux.conf`.

### 🖱️ Clickable bottom bar

```
 👻 work  ✎  ◀  1 🐚 bash   2 📝 nvim   3 🐟 fish   ▶  ＋ ▾        🎨 ❓ │ 📂 app · 🕒 14:02
```

| Click | Does |
| --- | --- |
| `👻 work` (session name) | opens `gterminal` to switch, reopen or start a session |
| `✎` | renames the session (also `prefix + $`, or `r` in gterminal) |
| a window (`1 🐚 bash`) | switches to it. Scroll the wheel over the bar to flip through windows. Right-click any tab for ✎ rename, ◀ ▶ move, ＋ new after, ✕ close |
| `◀` / `▶` | previous / next terminal (wraps around) |
| `＋` | new terminal in the current folder |
| `▾` | menu: 🐚 bash, 🐟 fish, ↔ split side, ↕ split down, 👻 sessions, 🎨 theme, ✎ rename session, 🎓 tour, ❓ help |
| `🎨` | theme picker (also `prefix + T`) |
| `❓` | help & tips (also `prefix + ?`) |

Each window shows an icon for what runs in it (🐚 bash, 🐟 fish, 📝 editor, 🟩 node, 🐍 python, 🌿 git, 🔐 ssh, 🤖 claude, 🎓 the tour, 🔧 anything else).

✎ **Renaming keeps your place.** Renaming a session (any way: ✎, `prefix + $`, gterminal `r`) moves its saved folder + last command to the new name, so gterminal never shows a stale 💤 copy under the old one.

### ❓ ktips: shortcuts + tips

Click `❓`, press `prefix + ?` inside tmux, press `?` in gterminal or type `ktips` anywhere:

```
  ❓ help & tips

  🖱️  BOTTOM BAR (tmux)
    👻 session      switch, reopen or start sessions (gterminal)
    ✎               rename the session
    1 🐚 bash       click to switch · scroll the wheel to flip through
    ◀ ▶             previous / next terminal
    ＋              new terminal in this folder
    ...
  ⌨️  KEYS press Ctrl+b, let go, then:
    c    new window              1-9    go to window
    ...
  📋 COPY & PASTE
    ...
  💡 TIP 16/50
    Drag the line between two splits with the mouse to resize them

  n next tip   p previous   t tour   a all tmux keys   q close
```

- About 60 tips on the bottom bar, tmux, gterminal, Ghostty, bash/fish and git
- `ktips --one` prints one random tip, never the same twice in a row. The Kronikus greeting uses it, so every new terminal teaches you something
- If you change the tmux prefix, the help and tips show your prefix instead of `Ctrl+b`
- To add your own tips, add lines to the `tips=(...)` list at the top of `ktips`

### 🎨 ktheme: theme picker

Click `🎨`, press `prefix + T` or type `ktheme`:

```
  🎨 theme   🌗 desktop is light → ☀️ side

  ❯ 👻 Neon         ☀️ Neon Day               🌙 Neon Night            ✓ auto
    🐱 Catppuccin   ☀️ Catppuccin Latte       🌙 Catppuccin Mocha
    🌹 Rose Pine    ☀️ Rose Pine Dawn         🌙 Rose Pine
    🗼 Tokyo Night  ☀️ TokyoNight Day         🌙 TokyoNight
    …               (Gruvbox, Nord, Everforest, Kanagawa, GitHub, Solarized, Dracula)

  ● ● ● ● ● ●   ● ● ● ● ● ●   ❯ prompt dim

  ↑↓ preview   ⏎ keep (auto)   d dark   l light   esc cancel
```

- Moving through the list **previews each theme live** in every Ghostty window (it reloads Ghostty with `SIGUSR2`)
- `⏎` keeps it in **auto**: light or dark follows your desktop. `d` / `l` keep only the dark / light side. `esc` puts back what you had
- Any of Ghostty's 460+ themes works from the command line: `ktheme "Rose Pine"`, `ktheme "light:Nord Light,dark:Nord"`. `ktheme --list` shows all names, and a name Ghostty doesn't know is refused, so the config never breaks
- Needs Ghostty 1.2+ for the live reload. Older versions: press `Ctrl+Shift+,` after picking

### 🎓 ktour: hands-on tour

Type `ktour`, pick ▾ → 🎓 tour in the bar, or press `t` on the ❓ help screen:

```
  🎓 tour   ▰▰▰▰▱▱▱▱▱▱▱▱▱▱▱▱▱   🪟 Terminals · 1/4

  Click ＋ in the bottom bar to open a new terminal.
  It opens in the same folder as this one, and you land in it right away.

  Then click the 🎓 tab in the bottom bar to come back here.

  Keys: Ctrl+b then c opens one too.

  ⏳ waiting for you…  ⏎ skips

  ⏎ next   ← back   m chapters   q quit
```

- **Hands-on**: most steps watch tmux and move on by themselves once you've done the thing (opened a terminal, clicked ◀ ▶, split, zoomed, copied a word, renamed the session, opened gterminal / the theme picker / help). `⏎` skips any step
- **8 chapters**: 🖱️ the bottom bar, 🪟 terminals, ↔️ splits, 📋 copy & paste, 👻 sessions, 🎨 themes, 🐚 prompt & shell, ❓ help. The menu lets you take the full tour or one chapter, and ticks off ✓ the ones you've done
- **First run**: the Kronikus greeting asks once, on the very first terminal. Outside tmux, the tour opens a `tour` tmux session for itself
- Run inside an existing tab, it calls that tab "tour" while it runs and puts the old name back after

### 👻 gterminal

Type `gterminal` in any terminal (or press `prefix + s` / click the session name inside tmux):

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

  ↑↓ move   ⏎ open   1-9 jump   n new   r rename   x kill   ? help   q quit
```

- 🟢 / 🔵 **live** sessions (attached / in the background) reopen exactly as you left them
- 💤 **saved** sessions were closed or are gone after a reboot. Opening one starts it again **in the same folder** and **types the last command** for you, so `Enter` continues it
- The right panel shows the selected session's folder, last command, windows and what's on screen
- Saving needs the Kronikus prompt (bash or fish). It writes to `~/.local/state/kronikus/tmux/`
- Keys: `↑↓` or `j`/`k` move, `⏎` open, `1-9` jump to that row, `n` new session (asks for a name), `r` rename (live or saved), `x` kill a live session or forget a saved one, `?` help & tips, `q` quit
- A saved session comes back in your default shell, so a fish command saved from a fish session is retyped in bash if bash is your default
- Pure bash, no fzf or other tools

The tmux config only uses the 16 terminal colors (no fixed hex), so it takes on whatever theme Ghostty has, light or dark, and changes with it.
It also makes the mouse work like a normal terminal:
**press, drag over the text and let go, and it's copied** to the system clipboard (the highlight disappears when you let go, that's the copy). Double-click copies a word and triple-click copies a line, no dragging needed.
Hold `Shift` while dragging to use Ghostty's own selection instead.
New windows and splits open in the current folder.

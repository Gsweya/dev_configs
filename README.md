# dev_configs

Personal configs for the dev tools I use, mainly terminals.

| Folder | What's inside |
| --- | --- |
| `ghostty/` | [Ghostty](https://ghostty.org) terminal config with 👻 Neon themes: 🌙 Night (dark) and ☀️ Day (light), following the desktop, all 187 [Monkeytype](https://monkeytype.com) themes, and readable "Solid" versions of 10 popular themes |
| `shell/` | 🥽 Kronikus prompt for bash and fish: avatar, name, folder, git (with starship icons), command timing |
| `tmux/` | 👻 tmux config (clickable tab bar on top, mouse select = copy), `gterminal`, a session picker that brings you back where you were, `ktips` (shortcuts + tips), `ktheme` (theme picker), `ktour` (hands-on tour), `ksettings` (⚙ settings, fonts, 6 bar skins), `kbox` (⌨ command box) and `knotify` (🔔 finished commands) |
| `editors/` | 🧩 all the Ghostty themes for [Zed](https://zed.dev), VS Code, Cursor and Neovim, with the same names and colors |

**New here?** Install everything (the sections below), open a new terminal and press `⏎` when it asks
*"First time here?"*. That starts 🎓 `ktour`, a 5-minute hands-on tour. You can run `ktour` again any time.

## 👻 Ghostty

```sh
mkdir -p ~/.config/ghostty/themes
cp ghostty/config.ghostty ~/.config/ghostty/config.ghostty
cp ghostty/themes/* ~/.config/ghostty/themes/
```

Reload inside Ghostty with `Ctrl+Shift+,` (or open a new window).
The config uses the [Lilex](https://github.com/mishamyrt/Lilex) font, so install it, or pick another one in ⚙ settings → [🔤 Font](#-fonts-and-emoji).

🌗 **Light & dark.** `theme = light:Neon Day,dark:Neon Night` makes Ghostty follow your desktop:
☀️ Neon Day (lavender white, deep rose / mint / violet) when it's light, 🌙 Neon Night (deep navy, calm rose / mint / violet) when it's dark.
It switches on its own when the desktop does. The prompt, tmux, gterminal and ktips only use the 16 terminal colors, so they follow along.

🎨 **Other themes.** Run `ktheme` (or click 🎨 in the tmux bar) to pick another one, see [ktheme](#-ktheme-theme-picker) below.
It writes `~/.config/ghostty/theme.ghostty`, which the `config-file = ?theme.ghostty` line pulls in, so `config.ghostty` itself never changes.

⌨️ **Monkeytype themes.** All 187 themes from [Monkeytype](https://github.com/monkeytypegame/monkeytype) (GPL-3.0) are in `ghostty/themes/`, named like `MT serika dark`. `ghostty/monkeytype-themes` makes them from Monkeytype's own color list, and runs again to pick up new ones.

A Monkeytype theme has roles, not the 16 colors a terminal needs, so:

| Monkeytype | Terminal |
| --- | --- |
| `bg`, `caret`, `subAlt` | background, cursor, the surface under the bar's chips: exact |
| `text`, `main`, `error` | text, the one accent, red: exact unless unreadable (below 4.5:1, 3:1, 3:1) |
| `sub` | comments and quiet text: exact, or lifted to 4.5:1 if fainter |
| green, yellow, blue, cyan | not in Monkeytype: made here at a calm lightness, so `ls` and git diffs keep their meaning |

Effects a theme does in CSS, like an animated gradient, have no place in a terminal. A few themes put light text on a mid-tone background that no white can make readable, and those get dark text.

The look comes from there too: the theme's accent only marks what's active, everything else stays in the quiet color, active items are flat chips, and keys in the screens' footers look like Monkeytype's key hints.

✅ **Readable colors.** Neon and the Solid themes are made by `ghostty/tune-themes`, which keeps each theme's background and hues and fixes how light and how saturated each color is:

| | On dark | On light |
| --- | --- | --- |
| Plain text | 9-13:1 | 8-13:1 |
| Keyword colors, all about equally loud | 6-8.5:1 | 4.8-7:1 |
| Comments and other quiet text | 4.6:1 | 4.6:1 |
| Selection against the background, a solid block | 2:1 | 2:1 |
| Text on the selection | 6:1 or more | 6:1 or more |

Similar keyword colors are also kept apart, so blue and cyan stay two colors. `ghostty/tune-themes --check` prints the numbers.
For comparison, plain TokyoNight has its comments at 1.9:1 and Rose Pine Dawn its yellow at 2.1:1.

`minimum-contrast` stays at a low 1.5 on purpose. Ghostty doesn't lift a color under the limit, it jumps to pure white or black, so a higher value turns grey comments into the loudest text on screen. `faint-opacity = 0.75` keeps dim text readable.

### 🔤 Fonts and emoji

Open ▾ → 🔤 font in the tmux bar, or type `ksettings font`:

```
  🔤 FONT
  ❯ Font          JetBrains Mono                   ← → try the next one · ⏎ type a name
    Size          13 pt config.ghostty's
    Emoji         Ghostty's (Noto Color Emoji) 🎨 🦀 ✅

  preview
    0O 1lI {} => != -> ===    main  🎨 🦀 ✅ 👻
```

- **Font**: `←` `→` go through every monospace font you have installed (`fc-list :spacing=mono`), and each one shows **live** in every Ghostty window. `⏎` types a name; a font that isn't installed is refused
- **Size** in points, live too. Windows you zoomed with `Ctrl+=` keep their own size
- **Emoji**: Ghostty's own pick (Noto Color Emoji on Linux), or any other emoji font you have, like Twemoji. Noto Emoji is the plain black-and-white one. A new emoji font you put in `~/.local/share/fonts` shows up here by itself
- Saved in `~/.config/ghostty/kronikus.ghostty`, so `config.ghostty` keeps Lilex as the default. Going back to it (or to 13 pt) takes the line out again
- The Nerd Font glyphs (the bar's round chips, git's ``) come from Ghostty itself, so they work with any font

🧊 **Google's Noto 3D emoji.** These are the new 3D-looking emoji Google is bringing to Android and Pixel. They aren't out as a font you can download yet; for now they're only on Emojipedia. An unofficial `.ttf` is passed around (from a keyboard app's Telegram channel). It isn't from Google, so it's your call. Once you have an emoji font file, the steps are the same:

```sh
mkdir -p ~/.local/share/fonts && cp Noto3D.ttf ~/.local/share/fonts/ && fc-cache -f
```

Then pick it in ⚙ settings → Emoji. Emoji are 2 cells wide in any emoji font, so the bar and the screens keep their layout.

📋 **Select = copy.** Anything you select with the mouse goes straight to the clipboard (`copy-on-select = clipboard`), so you can paste it anywhere with `Ctrl+V` / `Ctrl+Shift+V`.

## 🧩 Code colors: Zed, VS Code, Cursor, Neovim and more

A terminal theme only recolors what's drawn in the 16 terminal colors. Editors and pagers bring their own colors for code, so `ktheme` takes those along: pick a theme once and keywords, strings and comments change everywhere.

| Where | How it follows |
| --- | --- |
| `ls`, `git`, `grep`, nano, tmux, the prompt | already in the 16 colors |
| `bat` | `--theme=ansi` in its config |
| fish | colors what you type in the 16 colors. bash can't color what you type at all |
| Neovim | watches the theme file, so it changes while open, previews included |
| Zed, VS Code, Cursor | `ktheme` sets their theme when you keep one (⏎): it replaces what was set there |
| Claude Code | ANSI mode (`auto` draws code in fixed colors no theme can reach). Left alone if you picked another mode in `/theme` |

Ghostty's own themes (`ktheme --list`) have no editor version, so those leave the editors as they are. Other programs with their own themes, like JetBrains, don't follow.

Every Ghostty theme also works in the editors under the same name, all 208: Neon, Solid and `MT serika dark` and friends.

```sh
mkdir -p ~/.config/zed/themes ~/.config/bat ~/.config/nvim/lua
cp editors/zed/*.json ~/.config/zed/themes/
code --install-extension editors/kronikus-themes.vsix --force
cursor --install-extension editors/kronikus-themes.vsix --force
cp editors/bat/config ~/.config/bat/config
cp -r editors/nvim/lua/kronikus ~/.config/nvim/lua/
```

Neovim needs [catppuccin](https://github.com/catppuccin/nvim), which keeps every plugin styled, with the colors on top of it:

```lua
{
  "catppuccin/nvim", name = "catppuccin", lazy = false, priority = 1000,
  config = function(_, opts) require("kronikus").setup(opts) end,
}
```

The Flatpak build of Zed keeps its config elsewhere: copy to `~/.var/app/dev.zed.Zed/config/zed/themes/` for that one.

Zed loads new themes on its own, VS Code after `Developer: Reload Window`. You can also pick one by hand with `Ctrl+K` `Ctrl+T`, until the next `ktheme`.

🌗 **Light & dark.** With a 🌗 theme Zed and Neovim follow the desktop like Ghostty does. VS Code, Cursor and Claude Code get the side in use when you pick it. To make those follow too:

```jsonc
// VS Code, Cursor: settings.json
"window.autoDetectColorScheme": true,
"workbench.preferredLightColorTheme": "Neon Day",
"workbench.preferredDarkColorTheme": "Neon Night"
```

`editors/make-themes` writes all of them from `ghostty/themes/`, so run it after those change. The colors go like this:

| In the editor | Ghostty color |
| --- | --- |
| Keywords | palette 5, the accent |
| Strings, numbers | palette 2, 3 |
| Functions and tags, types | palette 4, 6 |
| Comments, line numbers, anything inactive | palette 8, the quiet color |
| Errors and deleted lines | palette 1. Nothing else is red, so red always means trouble |
| Integrated terminal | the 16 colors, unchanged |

Code is read all day, so a syntax color fainter than 4.5:1 is lifted to it, with the same hue. The accent stays exact on the screens around the code, where it only marks what's active, as in the tmux bar. If lifting brings two colors together they're turned apart, and a theme whose accent is as pale as its text gets bold keywords. A few Monkeytype themes have a mid-tone background, where 4.5:1 would wash every color out to near white: those stay colored at 3.4-4.4:1.

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
- The arrow turns red when the last command failed. Its look is yours: pick a sign like `$`, `#` or `λ` and a color in ⚙ settings (`$` shows as `#` when you're root)
- Pure bash otherwise. Outside a repo nothing extra runs, and inside one starship adds about 15ms
- Inside tmux it saves the folder and last command of each session for `gterminal`, shows the last command under the top bar, and marks each prompt so you can jump between commands
- 🔔 Tells you when a slow command finishes while you aren't looking (see [knotify](#-knotify-finished-commands))
- ⚙ settings reach shells that are already open, at their next prompt. Only the greeting waits for a new terminal

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

The easy way is ⚙ `ksettings` (see the tmux section): it saves to `~/.config/kronikus/settings`.
You can also set them yourself above the `source` line; a variable set there wins over the settings file.

bash:

```sh
export KRONIKUS_NAME="Kronikus"   # display name
export KRONIKUS_AVATAR="🥽"       # small profile icon (any emoji)
export KRONIKUS_ANIM=1            # 0 turns off the finish spinner
export KRONIKUS_ANIM_MIN=2        # seconds before the spinner plays
export KRONIKUS_GREET=1           # 0 turns off the picture greeting
export KRONIKUS_TIPS=1            # 0 hides the tip under the greeting
export KRONIKUS_ASK_TAB=1         # 0: new tmux tabs don't ask for a name
export KRONIKUS_SIGN="❯"          # the sign before your command, like $ or #
export KRONIKUS_SIGN_COLOR=magenta  # magenta, cyan, green, yellow, blue or text
export KRONIKUS_LAST=1            # 0: no last command in the tmux bar
export KRONIKUS_NOTIFY=away       # away, always or off
export KRONIKUS_NOTIFY_MIN=5      # seconds that count as a slow command
export KRONIKUS_PICTURE=~/.config/kronikus/avatar.png
export KRONIKUS_STARSHIP=~/.config/kronikus/starship.toml  # starship config for the git part
```

fish: the same names, set like `set -g KRONIKUS_AVATAR 🥽`.

## 👻 tmux + gterminal

```sh
cp tmux/tmux.conf ~/.tmux.conf
mkdir -p ~/.local/bin
cp tmux/gterminal tmux/ktips tmux/ktheme tmux/ktour tmux/ksettings tmux/kbox tmux/knotify ~/.local/bin/
```

If tmux is already running, reload it with `tmux source ~/.tmux.conf`.

### 🖱️ Clickable top bar

```
 🥽 Kronikus ›  👻 work  ✎  │ ◀   1 🐚 bash   2 📝 nvim   3 🐟 fish  ▶ │ ＋ ▾      🎨  ❓  │ 📂 app   🕒 14:02 
 ❯ npm test  ✅ · ⏱ 3.4s · 🕒 14:02:11                                                         ▲ ▼ │ ⌨ box 
```

On the far left is **you**: the same avatar and name as the greeting. Click it to open ⚙ settings (below) and change them; the bar updates right away.
Thin `│` lines split the bar into groups, and ◀ ▶ are round buttons so they're easy to spot.
tmux can't draw pictures in its bar, so it's the emoji avatar here, not the photo. The name hides on windows narrower than 120 columns.

The bar sits at the **top**, like browser tabs. The line under it shows the last command of the terminal you're in, what it did, how long it took and when it ended (`⏳ running` while it runs). Each split keeps its own. Long commands are cut to fit.
The session name, the current tab and the clock are flat rounded chips (Nerd Font glyphs, built into Ghostty), the accent color only marks what's active, and the other tabs take the same width so nothing moves when you switch.
The 📂 folder only shows on windows wider than 140 columns, so tabs and buttons keep their room. Long tab names are cut at 14 characters.
Prefer it at the bottom, or no last-command line? Both are in ⚙ settings.

| Click | Does |
| --- | --- |
| `🥽 Kronikus` | ⚙ settings: avatar, name, picture, greeting, tips, see-through, bar position, cursor (also `prefix + S`) |
| `👻 work` (session name) | opens `gterminal` to switch, reopen or start a session |
| `✎` | renames the session (also `prefix + $`, or `r` in gterminal) |
| a window (`1 🐚 bash`) | switches to it. Scroll the wheel over the bar to flip through windows. Right-click any tab for ✎ rename, ◀ ▶ move, ＋ new after, ✕ close |
| `◀` / `▶` | previous / next terminal (wraps around) |
| `＋` | new terminal in the current folder. It asks for a tab name first: type one, or `⏎` to keep the automatic one (the running program) |
| `▾` | menu: 🐚 bash, 🐟 fish, ↔ split side, ↕ split down, 👻 sessions, 🎨 theme, ⚙ settings, 🔤 font, ⌨ command box, ✎ rename session, 🎓 tour, ❓ help |
| `🎨` | theme picker (also `prefix + T`) |
| `❓` | help & tips (also `prefix + ?`) |
| `❯ npm test` | jumps to that command in the scrollback. Press `q` or `esc` to go back |
| `▲` / `▼` | previous / next command in the scrollback (also `Alt+↑` / `Alt+↓`). Vim and other full-screen programs keep those keys |
| `⌨ box` | opens or closes the [command box](#-kbox-command-box) (also `prefix + b`, or ▾) |

Each window shows an icon for what runs in it (🐚 bash, 🐟 fish, 📝 editor, 🟩 node, 🐍 python, 🌿 git, 🔐 ssh, 🤖 claude, 🎓 the tour, ⌨️ the command box, 🔧 anything else).

### 🖌 Skins and icons

⚙ settings → **Skin** changes how the whole bar looks, live, and **Icons** picks what the icons are drawn with. Every skin keeps the same buttons in the same places, so clicks, the tour and the tips still work:

```
neon       🥽 Kronikus ›  👻 work  ✎  │ ◀   1 🐚 bash    2 📝 nvim  ▶ │ ＋ ▾      🎨  ❓  │  🕒 14:02 
omarchy     work    1: bash  2: nvim                           󰏘     14:02 🥽
powerline   🥽 Kronikus  👻 work  ✎ ◀   1 🐚 bash    2 📝 nvim  ▶  ＋ ▾          🎨 ❓   🕒 14:02 
bubbles    🥽 Kronikus  👻 work  ✎  ◀  1 🐚 bash   2 📝 nvim  ▶  ＋  ▾     🎨  ❓  🕒 14:02 
minimal    🥽 Kronikus  👻 work ✎  ◀  1 🐚 bash  2 📝 nvim  ▶  ＋ ▾              🎨  ❓  app · 14:02
retro      🥽 Kronikus [👻 work] ✎ [◀]  1:🐚 bash [2:📝 nvim] [▶] [＋][▾]        [🎨][❓] [🕒 14:02]
```

| Skin | Look |
| --- | --- |
| `neon` | the default: rounded chips for what's active, other tabs as wide as a chip so nothing moves |
| `omarchy` | like [Omarchy](https://omarchy.org)'s tmux: a solid accent block for the session, plain `1:name` tabs, the mode tmux is in (`COPY`, `PREFIX`, `ZOOM`) on the right, the active split's border lit. Best with Icons → nerd |
| `powerline` | you and the session as arrow segments, the current tab and the clock as accent arrows |
| `bubbles` | every tab and button a pill, the active ones filled with the accent |
| `minimal` | words only, no chips. The current tab is in the accent, its name underlined |
| `retro` | `[brackets]` around what's active and plain ASCII lines between splits |

| Icons | Draws with |
| --- | --- |
| `emoji` | 🐚 📝 🎨 ❓ 📂 🕒 (the default) |
| `nerd` | Nerd Font glyphs:      󰏘    , like Omarchy and most status bars. Built into Ghostty |
| `text` | no pictures: `◀ ▶ + ▾ ◐ ?` and the tab names alone |

All of them only use the theme's 16 colors, so any theme works with any skin. The choice goes to `~/.config/kronikus/tmux.conf`, and ksettings reloads the tmux config to apply it.

✎ **Renaming keeps your place.** Renaming a session (any way: ✎, `prefix + $`, gterminal `r`) moves its saved folder + last command to the new name, so gterminal never shows a stale 💤 copy under the old one.

### ⌨ kbox: command box

An optional box under the terminal to write or paste a command in. Click `⌨ box`, press `Alt+i` or `prefix + b`, or type `kbox`:

```
╭─ 🥽 Kronikus in 📂 ~/code/app
╰─❯ npm test
──────────────────────────────────────────────────────────────────────────
⌨ runs in bash · ~/code/app        ⏎ run · Alt+⏎ type only · Alt+i jump · Ctrl+d close
❯ npm test
```

| Key | Does |
| --- | --- |
| `⏎` | runs it in the terminal above, and you stay in the box for the next one |
| `Alt+⏎` | types it in the terminal without running it, and takes you there to edit it |
| `Alt+i` | jumps between the terminal and the box. Opens the box if it's closed, and works inside any program |
| `↑` `↓` `Ctrl+R` | your earlier box commands and your bash history |
| `Tab` | completes files and commands, from the folder of the terminal above |
| `Ctrl+D` | closes the box |

- Pasting several lines keeps them together as one command until you press `⏎`
- It runs in the terminal you last came from, and its title line tells you which one. The text goes in as if you typed it, so if a program like vim is running there, vim gets it
- Each tab has its own box, a real tmux pane: click it, or drag its border to make it taller. When its terminal closes, the box goes too
- Box commands are saved in `~/.local/state/kronikus/kbox_history`
- While you type in the box, the tab keeps the name of its terminal
- ⚡ **Without making a session first**: gterminal's ⚡ quick terminal opens tmux with the box already open. Set ⚙ settings → **Opens** to `⚡ quick terminal + ⌨ box` and every new Ghostty window starts that way (see [gterminal](#-gterminal))

### 🔔 knotify: finished commands

When a slow command finishes and you aren't looking at it, you get a desktop notification:

```
❌ Failed (1) · 2 server
npm test · ⏱ 3m12s · 📂 app
```

- "Not looking" means another tab or split, another app in front of Ghostty, or tmux detached. Outside tmux there's no way to tell, so it always notifies
- A command that finishes in another tab also puts ✅ or ❌ on that tab until you open it
- ⚙ settings → **Notify**: `when you are not looking`, `always` or `off`. **After**: what counts as slow, 5 seconds by default, or `every command`
- Editors, pagers, `ssh` and the like are skipped, because you end those yourself
- Uses `notify-send`, so it needs a desktop that shows notifications. Ghostty's own `notify-on-command-finish` can't see commands inside tmux
- In bash, a command that starts with `(` isn't tracked at all: no ✅ line, no last command and no notification

### ❓ ktips: shortcuts + tips

Click `❓`, press `prefix + ?` inside tmux, press `?` in gterminal or type `ktips` anywhere:

```
  ❓ help & tips

  🖱️  TOP BAR (tmux)
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

- About 60 tips on the top bar, tmux, gterminal, Ghostty, bash/fish and git
- `ktips --one` prints one random tip, never the same twice in a row. The Kronikus greeting uses it, so every new terminal teaches you something
- If you change the tmux prefix, the help and tips show your prefix instead of `Ctrl+b`
- To add your own tips, add lines to the `tips=(...)` list at the top of `ktips`

### 🎨 ktheme: theme picker

Click `🎨`, press `prefix + T` or type `ktheme`:

```
  🎨 theme   198 · all
  / ser▌

  ❯  serika dark                                     ● ● ●
     serika                                          ● ● ●
     …

  ╰─❯ git commit -m "fix the parser"  # a comment  ❌ 1
  const total = sum(items, 42)  // keywords, names, numbers

   tab  all    ↑↓  preview    ⏎  keep    esc  cancel
```

- Like Monkeytype's own list, **every row is painted in that theme**, with a dot each for its accent, quiet and text color
- **Type to search.** `tab` shows all, only dark or only light themes. `esc` clears the search, then cancels and puts back what you had
- Moving through the list **previews each theme live** in every Ghostty window (it reloads Ghostty with `SIGUSR2`). Holding an arrow key previews where you stop
- The 🌗 rows at the end are Neon and the Solid themes, which follow your desktop. `⏎` keeps that, `Ctrl+D` / `Ctrl+L` keep only the dark / light side
- Any of Ghostty's 460+ themes works from the command line: `ktheme "MT serika dark"`, `ktheme "light:Nord Light,dark:Nord"`. `ktheme --list` shows all names, and a name Ghostty doesn't know is refused, so the config never breaks
- Needs Ghostty 1.2+ for the live reload. Older versions: press `Ctrl+Shift+,` after picking

### ⚙ ksettings: settings

Click your avatar in the bar, press `prefix + S`, pick ▾ → ⚙ settings or type `ksettings`:

```
  ⚙ settings   saved as you go

  👤 PROFILE
  ❯ Avatar        🥽                               ← → pick · ⏎ type your own
    Name          Kronikus
    Picture       ~/.config/kronikus/avatar.png ✓

  👋 NEW TERMINAL
    Opens         ⚡ quick terminal + ⌨ box
    Greeting      ● on
    Tip           ● on
    Spinner       ● on
    Ask tab name  ● on

  🎨 LOOK
    Theme         ☀️ Neon Day  🌙 Neon Night
    Skin          omarchy 2/6
    Icons         🐚 emoji   nerd  Aa text
    See-through   93%
    Bar           top

  🔤 FONT
    Font          Lilex config.ghostty's
    Size          13 pt config.ghostty's
    Emoji         Ghostty's (Noto Color Emoji) 🎨 🦀 ✅

  📍 CURSOR
    Shape         │  _  █  ●   bar
    Size          ▮▮▮▯ bold 3 px
    Blink         ● on
    Color         █ the theme's

  ❯ PROMPT
    Sign          ❯  $  #  ›  ➜  λ  ▶  %
    Sign color    ● magenta

  ⏱ COMMANDS
    Last command  ● on
    Notify        🔔 when you are not looking
    After         commands of 5s or more

  🎓 HELP
    Tour
    Shortcuts

  preview
    0O 1lI {} => != -> ===    main  🎨 🦀 ✅ 👻
    🥽 Kronikus is back
    ╭─ 🥽 Kronikus in 📂 ~/code/app
```

- Every change is **saved right away**, and the preview shows the greeting and prompt as you go
- Avatar: `←` `→` flip through a few emoji, `⏎` types any emoji you like. Name and picture: `⏎` to edit
- **Ask tab name**: every new tab (＋, ▾, `prefix + c`) asks `✎ name this tab (⏎ keeps bash):` before its first prompt. A name you type sticks; `⏎` or `Ctrl+C` keeps the automatic name. Splits, tabs you already named and sessions gterminal restores don't ask
- Profile and greeting go to `~/.config/kronikus/settings` (`KRONIKUS_*=value` lines), which the bash and fish prompts read. Avatar and name change in the tmux bar at once; the greeting in new terminals
- **See-through** sets Ghostty's `background-opacity` (100% = solid) in `~/.config/ghostty/kronikus.ghostty` and reloads Ghostty. Turn it up if windows behind Ghostty show through and clutter the bar
- **Opens**: what a new Ghostty window starts with. `🐚 a plain shell` (the default), `⚡ quick terminal + ⌨ box`, `⚡ quick terminal` without the box, or `👻 gterminal` to pick a session (`q` there gives you a plain shell). It sets Ghostty's `command` in `~/.config/ghostty/kronikus.ghostty`, to `gterminal --start …`. If tmux is missing or anything fails, you get the plain shell, so a window always opens
- **Bar** puts the tmux bar on top or at the bottom (`~/.config/kronikus/tmux.conf`, read by the tmux config)
- **Skin** and **Icons**: see [Skins and icons](#-skins-and-icons). **Font**, **Size** and **Emoji**: see [Fonts and emoji](#-fonts-and-emoji)
- **Cursor**: `←` `→` pick the shape: `│` bar, `_` underline, `█` block or `●` dot. **Size** sets how thick a bar / underline is (1, 2, 3 or 5 px) or how big the dot is; a block always fills its cell. **Blink** turns blinking on or off. You see the real cursor change after the preview prompt
  - Saved in `~/.config/ghostty/kronikus.ghostty` (Ghostty reloads at once) and as tmux's `cursor-style` in `~/.config/kronikus/tmux.conf`, because tmux would otherwise put a block back after programs like vim
  - Ghostty has no round cursor, so the **dot** is a small custom shader (`~/.config/ghostty/shaders/kronikus-cursor.glsl`, written by ksettings): Ghostty's block is made invisible and the shader draws a dot in its place, a ring when the window isn't focused. When a program asks for a bar or underline (vim's insert mode), the shader draws that instead
  - It also sets `shell-integration-features = no-cursor`, otherwise Ghostty's shell integration turns the cursor back into a bar at every prompt
  - **Color**: `←` `→` go through the theme's color, the color of the text, rose, amber, mint, sky and violet. `⏎` takes any `#rrggbb`. On a block cursor, the letter underneath takes the background color
- **Sign**: the sign before your command. `←` `→` pick one, `⏎` types your own. **Sign color** uses the terminal colors, so it follows the theme. The arrow still turns red when a command fails
- **Last command** shows or hides the line under the bar. **Notify** and **After**: see [knotify](#-knotify-finished-commands)
- **Theme**, **Tour** and **Shortcuts** open ktheme, ktour and ktips

### 🎓 ktour: hands-on tour

Type `ktour`, pick ▾ → 🎓 tour in the bar, or press `t` on the ❓ help screen:

```
  🎓 tour   ▰▰▰▰▱▱▱▱▱▱▱▱▱▱▱▱▱   🪟 Terminals · 1/4

  Click ＋ in the top bar to open a new terminal.
  It opens in the same folder as this one, and you land in it right away.

  Then click the 🎓 tab in the top bar to come back here.

  Keys: Ctrl+b then c opens one too.

  ⏳ waiting for you…  ⏎ skips

  ⏎ next   ← back   m chapters   q quit
```

- **Hands-on**: most steps watch tmux and move on by themselves once you've done the thing (opened a terminal, clicked ◀ ▶, split, zoomed, copied a word, renamed the session, opened gterminal / the theme picker / help). `⏎` skips any step
- **8 chapters**: 🖱️ the top bar, 🪟 terminals, ↔️ splits, 📋 copy & paste, 👻 sessions, 🎨 themes, 🐚 prompt & shell, ❓ help. The menu lets you take the full tour or one chapter, and ticks off ✓ the ones you've done
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
    ⚡ quick          🪟 1 ⚡     │ ❯  npm test
    💤 notes          saved       │
    ✨ new session                 │ 🪟 WINDOWS
    ⚡ quick terminal              │
                                   │ ▸ 1 📝 editor     nvim · ~/code/app
                                   │   2 🟩 server     node · ~/code/app/api
                                   │
                                   │ 📜 RECENT OUTPUT
                                   │ │ Tests: 12 passed

  ↑↓ move   ⏎ open   1-9 jump   n new   r rename   x kill   ? help   q quit
```

- 🟢 / 🔵 **live** sessions (attached / in the background) reopen exactly as you left them
- ⚡ **quick terminal** opens tmux right away with the [⌨ box](#-kbox-command-box) open, for when you just want a terminal: no name to type, and **nothing is saved**. It's called `quick` (`quick2`, … if that's taken) and has ⚡ in the bar
  - It ends when the window that opened it closes (or detaches), like a plain terminal. Switching to another session doesn't end it
  - Rename it (✎, `r` here) and it becomes a normal session: saved, and kept when the window closes
  - The first terminal in it greets you like a new Ghostty window (the emoji avatar, since tmux can't show the picture) and doesn't ask for a tab name
  - ⚙ settings → **Opens** can make every new Ghostty window a quick terminal
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

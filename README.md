# helpful-unix-like-shell-scripts

Helpful Linux and macOS shell scripts for sysadmins, developers and the forgetful.

The `clean` command script previously located [clean-command-history](https://github.com/robertlarocca/clean-command-history) is now part of this repository. Less for me to maintain and just makes sense. It's **helpful** and a Unix-like shell script. 🙂

-   bash_aliases.sh
-   caffeinate.sh
-   clean.sh
-   git-sync.sh
-   swupdate.sh
-   theme-helper.sh
-   whatsmyip.sh
-   zsh_aliases.sh

## Install Script

Install the `bash_aliases`, `zsh_aliases`, and others scripts using the included `INSTALL` script with:

```shell
./INSTALL
```

## macOS Support

When using the default `zsh` shell on newer macOS releases. You will likely, need to add the following code snippet to the hidden `~/.zshrc` file.

```shell
# Include zsh_aliases if available.
if [[ -f "$HOME/.zsh_aliases" ]]; then
	source "$HOME/.zsh_aliases"
fi
```

Here's my **custom** `~/.zshrc` file, which includes some other helpful aliases and `zsh` settings: automatic completion, some basic color support, use `nano` or `pico` as the default text editor, some `ls` aliases found in Ubuntu, etc.

```shell
# System-wide profile for interactive zsh(1) login shells.

# See zshbuiltins(1) and zshoptions(1) for more details.

zstyle ":completion:*" completer _complete _ignored
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit; compinit

# Enable default text editor
export EDITOR="nano"
export VISUAL="$EDITOR"

# Enable color support for ls and other commands.
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias grep="grep --color=auto"
alias ls="ls --color=auto"

# More handy aliases for the ls command.
alias l="ls -CF"
alias la="ls -A"
alias ll="ls -AlhF"

# Include zsh_aliases if available.
if [[ -f "$HOME/.zsh_aliases" ]]; then
	source "$HOME/.zsh_aliases"
fi
```

On macOS, If you want these scripts to execute using `zsh` instead of `bash`, must change the shabang from `#!/usr/bin/env bash` to `#!/usr/bin/env zsh` for each script. This extra step is **not** currently required. However; likely to prevent issues, should Apple remove their legacy version of `bash` from the operating system.

### OpenWrt and LEDE Support

On OpenWrt based devices and similar, you may need to change the shabang from `#!/usr/bin/env bash` to `#!/usr/bin/env sh` for each script, or whatever shell is supported on the device. Like the changes outlined above for macOS, force these scripts to execute using `sh` the default shell for the operating system.

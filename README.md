# helpful-linux-macos-shell-scripts

Helpful Linux and macOS shell scripts for sysadmins, developers and the forgetful.

The `clean.sh` command script previously located [clean-command-history](https://github.com/robertlarocca/clean-command-history) is now part of this repository. Less for me to maintain and just makes sense. It's **helpful** and a Unix-like shell script. 🙂

- bash_aliases.sh
- zsh_aliases.sh
- caffeinate.sh
- clean.sh
- git-sync.sh
- swupdate.sh
- theme-helper.sh
- whatsmyip.sh

## Install

Install the `bash_aliases`, `zsh_aliases`, and other included shell scripts using:

```shell
./INSTALL
```

## Reminder

When using the default `zsh` shell on newer macOS versions. You will likely, need to add the following code snippet to the hidden `~/.zshrc` file.

```shell
# Include zsh_aliases if available.
if [[ -f "$HOME/.zsh_aliases" ]]; then
	source "$HOME/.zsh_aliases"
fi
```

Here's my **complete** hidden `~/.zshrc` file, which includes some other helpful aliases and `zsh` shell settings, auto completion, `ls` and `grep` color support, `nano` (aka pico) is the default text editor, etc.

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

If you want all these scripts on macOS to be executed using `zsh` instead of `bash`, must change the shabang from `#!/usr/bin/env bash` to `#!/usr/bin/env zsh` in each script. This extra step is *not* necessary, however should Apple ever remove their legacy `bash` version from macOS, it will prevent you from having issues.

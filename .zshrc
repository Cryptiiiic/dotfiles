export SAVEHIST=100000000000000000
export HISTSIZE=100000000000000000
export HISTFILE=${HOME}/.zsh_history
export PROCURSUS=/opt/procursus
export PATH=${PROCURSUS}/bin:${PROCURSUS}/libexec/gnubin:${PROCURSUS}/local/bin:${HOME}/.local/bin:${PATH}
export GPG_TTY=$(tty)
export PS1='%n@%m %1~ %# '
alias vi="nvim"
alias vim="nvim"
alias cdu="cd-gitroot"
alias pls="sudo"
alias cr="/Applications/checkra1n.app/Contents/MacOS/checkra1n"
alias cr_revert="cr --force-revert"
typeset -g ZSH_AUTOSUGGEST_STRATEGY=(history completion match_prev_cmd)
setopt auto_cd HIST_FIND_NO_DUPS HIST_IGNORE_ALL_DUPS APPEND_HISTORY INC_APPEND_HISTORY SHARE_HISTORY appendhistory sharehistory incappendhistory
disable log
if [[ "$(locale LC_CTYPE)" == "UTF-8" ]]; then
    setopt COMBINING_CHARS
fi

function clone() {
    git clone ssh://git@github.com/$@.git
}

function rclone() {
    git clone --recursive ssh://git@github.com/$@.git
}

function bm() {
    curl -sLLO $(echo $@ |rev|cut -d/ -f1 --complement|rev)/BuildManifest.plist
}

function bm_dc() {
    /usr/libexec/PlistBuddy -c "Print BuildIdentities:$1" BuildManifest.plist | grep -i --text 'DeviceClass' | sort | uniq | gawk '{ print $3 }'
}

function bm_va() {
    /usr/libexec/PlistBuddy -c "Print BuildIdentities:$1" BuildManifest.plist | grep -i --text 'Variant ' | sort | uniq | gawk '{ print $4 }'
}

function bm_dl() {
    i="expr 0+0"
    idx="expr 0+0"
    for i ({0..32})
    do
        out=$(bm_dc $i)
        out1=$(bm_va $i)
        if [[ "$out" == "$2" && "$out1" == "Erase" ]]
        then
            idx=$i
            break
        fi
    done
    pzb -g $(/usr/libexec/PlistBuddy -c "Print BuildIdentities:$idx:Manifest:$1:Info:Path" BuildManifest.plist) $3 | grep -A1000 'getting'
    return 0
}

function bm_dl_u() {
    i="expr 0+0"
    idx="expr 0+0"
    for i ({0..32})
    do
        out=$(bm_dc $i)
        out1=$(bm_va $i)
        if [[ "$out" == "$2" && "$out1" == "Upgrade" ]]
        then
            idx=$i
            break
        fi
    done
    pzb -g $(/usr/libexec/PlistBuddy -c "Print BuildIdentities:$idx:Manifest:$1:Info:Path" BuildManifest.plist) $3 | grep -A1000 'getting'
    return 0
}

function repoclear() {
    export DIR=$(mktemp -d ${TMPDIR}/XXXX)
    cp -RpP .idea ${DIR}/
    git add -A
    git stash
    fd -I -H -d 1 -x gitcomp {} \; '\..*|.*'
    cp -RpP ${DIR}/.idea ./ 2> /dev/null
    rm -rf ${DIR}
    unset DIR
}

function transfer() {
    rsync -P -rave "ssh" $@
}

function cle() {
    open -na "CLion.app" --args "$@"
}

# https://github.com/saagarjha/dotfiles/blob/2235902ccf916361489367cbaa145970db684a31/.bashrc#L143
# function cd() {
# 	# Set the current directory to the 0th history item
# 	cd_history[0]=$PWD
# 	if [[ $1 == -h ]]; then
# 		for i in ${!cd_history[@]}; do
# 			echo $i: "${cd_history[$i]}"
# 		done
# 		return
# 	elif [[ $1 =~ ^-[0-9]+ ]]; then
# 		builtin cd "${cd_history[${1//-}]}" || # Remove the argument's dash
# 		return
# 	else
# 		builtin cd "$@" || return # Bail if cd fails
# 	fi
# 	# cd_history = ["", $OLDPWD, cd_history[1:]]
# 	cd_history=("" "$OLDPWD" "${cd_history[@]:1:${#cd_history[@]}}")
# }


### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic
autoload -Uz select-word-style && select-word-style bash
autoload -U colors && colors
unsetopt case_glob
setopt globdots
setopt extendedglob
setopt autocd
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust \
    zdharma-continuum/zinit-annex-submods \
    zdharma-continuum/history-search-multi-word

# zinit self-update
# zinit update --parallel $(expr $(nproc))

### End of Zinit's installer chunk
load=light
zinit $load willghatch/zsh-saneopt
# zinit $load mafredri/zsh-async
zinit $load rupa/z
zinit $load sindresorhus/pure
zinit ice nocompile:! pick:c.zsh atpull:%atclone atclone:'dircolors -b LS_COLORS > c.zsh'
zinit $load trapd00r/LS_COLORS
zinit ice silent wait:1 atload:_zsh_autosuggest_start
zinit $load zsh-users/zsh-autosuggestions
zinit ice blockf; zinit $load zsh-users/zsh-completions
zinit ice silent wait:1; zinit $load mollifier/cd-gitroot
zinit ice silent wait:1; zinit $load supercrabtree/k
zinit ice silent wait!1 atload"ZINIT[COMPINIT_OPTS]=-C; zpcompinit"
zinit $load zdharma/fast-syntax-highlighting
zinit $load changyuheng/zsh-interactive-cd

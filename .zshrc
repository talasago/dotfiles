ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh
PROMPT='%{%f%b%k%}$(build_prompt)
> '

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias tma='tmux a -t'
alias tmn='tmux new -s'
alias tm='tmux'

alias vi='vim'
alias ..='cd ..'
alias h='history'

alias dck='docker'
alias dckc='docker-compose'


vim_version=`vim --version | head -1 | sed 's/^.*\ \([0-9]\)\.\([0-9]\)\ .*$/\1\2/'`
alias less='/usr/share/vim/vim${vim_version}/macros/less.sh'

alias g='git'
alias gst='git status'
alias gbr='git branch'
alias gbrm='git branch -m'
alias gbrd='git branch -d'
alias gbrD='git branch -D'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gadu='git add -u'
alias gadup='git add -u -p'
alias gcom='git commit '
alias gmg='git merge --no-ff'
alias gmgff='git merge --ff'
alias gcp='git cherry-pick'
alias glog1='git log -1'
alias glog2='git log -2'
alias glog3='git log -3'
alias glogo='git log --oneline'
alias glogn='git log --name-status --oneline'
alias gfirstcom='git commit --allow-empty -m \"Initial commit\"'
alias gpl='git pull'
alias gps='git push'
alias gad='git add'
alias gdif='git diff'
alias gdift='git difftool'
alias ggrep='git grep'

# termのcnt+rの逆順検索
stty stop undef

# macの場合
if [ "$(uname)" = "Darwin" ]; then

  # コマンド履歴に重複を記録しない
  setopt hist_ignore_dups
  alias l.='ls -dG .*'
  alias ll='ls -lG'
  alias ls='ls -G'
  alias ld='ls -ldG */'
  alias sed='gsed'
  #source /usr/local/etc/bash_completion.d/git-completion.bash
  #source /usr/local/etc/bash_completion.d/git-prompt.sh
  alias find='gfind'
  #export PS1='\[\033[32m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[31m\]$(__git_ps1)\[\033[00m\]\n\$ '
  # tmux自動起動
  #count=`ps aux | grep tmux | grep -v grep | wc -l`
  #if test $count -eq 0; then
  #  echo `tm`
  #elif test $count -eq 1; then
  #  echo `tm a`
  #fi
  #complete -C '/usr/local/bin/aws_completer' aws
  #complete -C '/usr/local/bin/aws2_completer' aws2
  function share_history {
     history -a
     history -c
     history -r
  }

  PROMPT_COMMAND='share_history'
  #shopt -u histappend
  #. $(brew --prefix)/etc/bash_completion
  # Added by serverless binary installer


  # nodeenv
  #export PATH="$HOME/.nodenv/bin:$PATH"
  #eval "$(nodenv init -)"
else
  alias l.='ls -d .* --color=auto'
  alias ll='ls -l --color=auto'
  alias ls='ls --color=auto'
  alias tmux='tmux -f "$TMUX_CONF"'
  export PS1='\[\033[32m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[31m\]\[\033[00m\]\n\$ '
fi

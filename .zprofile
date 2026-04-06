insert_path=""
export PYENV_ROOT="$HOME/.pyenv/"
insert_path="$insert_path:$HOME/.nodebrew/current/bin/"
insert_path="$insert_path:$HOME/.serverless/bin/"
insert_path="$insert_path:$HOME/.rbenv/bin"
insert_path="$insert_path:$HOME/.rbenv/shims"
insert_path="$insert_path:$HOME/.local/bin"
insert_path="$insert_path:$HOME/.nodenv/bin/"
export PATH="$insert_path:$PATH"

# awscliv2用 ペーじゃを起動しない
export AWS_PAGER=""


# for nvm(Node.js enviroment manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

if command -v rbenv 1>/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi

if command -v nodenv 1>/dev/null 2>&1; then
  eval "$(nodenv init -)"
fi

# 仮想環境をpipenvしたディレクトリ配下に作成する
export PIPENV_VENV_IN_PROJECT=true


if [[ "$(uname)" = "Darwin" ]]; then
  # Set PATH, MANPATH, etc., for Homebrew.
  eval "$(/opt/homebrew/bin/brew shellenv)"
  export PATH="/usr/local/git/bin:$PATH"

  source ~/.orbstack/shell/init.zsh 2>/dev/null || :
fi

source "$HOME/.zprofile.local" 2>/dev/null || :

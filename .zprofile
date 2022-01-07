insert_path=""
export PYENV_ROOT="$HOME/.pyenv/"
#insert_path="$HOME/.pyenv/bin/"
#insert_path="$insert_path:$HOME/sls/node_modules/.bin/"
insert_path="$insert_path:$HOME/.nodebrew/current/bin/"
insert_path="$insert_path:$HOME/.serverless/bin/"
insert_path="$insert_path:$HOME/.local/share/kyrat/bin/"
#insert_path="$insert_path:$HOME/.nodenv/bin/"

#export PATH="$PATH:$insert_path"

export PATH="$insert_path:$PATH"


# awscliv2用 ペーじゃを起動しない
export AWS_PAGER=""

#if command -v pyenv 1>/dev/null 2>&1; then
#  eval "$(pyenv init -)"
#fi
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# 仮想環境をpipenvしたディレクトリ配下に作成する
export PIPENV_VENV_IN_PROJECT=true

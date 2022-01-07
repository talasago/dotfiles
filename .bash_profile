if [[ -f ~/.bashrc ]]; then
  . ~/.bashrc
fi
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export PATH="$HOME/sls/node_modules/.bin/:$PATH"

# Added by serverless binary installer
export PATH="$HOME/.serverless/bin:$PATH"
#export GST_PLUGIN_PATH=$HOME/work/42_devcamp/amazon-kinesis-video-streams-producer-sdk-cpp/kinesis-video-native-build
export PATH=$PATH:~/.local/share/kyrat/bin

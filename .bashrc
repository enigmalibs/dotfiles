#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Add the .NET Global Tools directory to the PATH
if [ -d "$HOME/.dotnet/tools" ] ; then
    PATH="$HOME/.dotnet/tools:$PATH"
fi

alias mgcb-editor='/home/jo/.dotnet/tools/mgcb-editor'

alias ls='eza -l --group-directories-first --icons'
alias lsa='eza -la --group-directories-first --icons'
alias cat='bat'
alias ..='cd ..'
# alias claude="claude --model opus --settings '{\"ultracode\": true}'"

# alias ls='ls --color=auto'
# alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.dotnet:$PATH"

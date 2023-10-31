#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
#PS1='[\u@\h \W]\$ '

export PS1='\[\e[30;47m\] \u \[\e[37;46m\]\[\e[30m\] \W \[\e[36;49m\]\[\e[0m\] '
$(echo neofetch)

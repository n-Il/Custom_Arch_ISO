#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#PS1='[\u@\h \W]\$ '
#PS1='[notmyname@\h\W]\$ '
PS1='$ '

export EDITOR=vim

#export XMODIFIERS=@im=ibus
HISTSIZE=1000
HISTFILESIZE=2000

alias ls='ls --color=auto'
alias update='sudo pacman -Syu'
alias pythondocs='firefox https://docs.python.org/3/'
alias javadocs='firefox https://docs.oracle.com/en/java/javase/21/docs/api/index.html'
alias cdocs='firefox https://www.gnu.org/software/gnu-c-manual/gnu-c-manual.html'
alias cdocs2='firefox https://devdocs.io/c/'
alias haskeldocs='firefox https://hoogle.haskell.org/'
alias rustdocs='firefox https://doc.rust-lang.org/std/index.html'

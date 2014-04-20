# Add to the path variable named by $1 the component $2.  $3 must be
# "append" or "prepend" to indicate where the component is added.

function addpath ()
{
 # Don't add directory if it doesn't exist...
 #
    if [ -d "$2" ]; then
        eval value=\"\$$1\"
        case "$value" in
	    *:$2:*|*:$2|$2:*|$2)
	        result="$value"
	        ;;
	    "")
		result="$2"
		;;
	    *)
		case "$3" in
		    p*)
			result="$2:${value}"
			;;
		    *)
			result="${value}:$2"
			;;
		esac
	esac

	export "$1"="$result"
	unset result value
    fi
}

# convenience routine which appends a string to a path.
function append ()
{
    addpath "$1" "$2" append
}

# convenience routine which prepends a string to a path.
function prepend ()
{
    addpath "$1" "$2" prepend
}

# Remove from the path variable named by $1 the component $2.
function rempath ()
{
    eval dirs=\"\$$1\"

    PIFS=${IFS}
    IFS=:

    for dir in ${dirs}; do
      if [ ! -z "${dir}" ]; then
        if [ ${dir} != "$2" ]; then
           if [ -z "${result}" ]; then
              result=${dir}
           else
              result=${result}:${dir}
           fi
        fi
      fi
      
    done
    export "$1"="$result"
    unset dir dirs result

    IFS=${PIFS}
}

function xtitle ()
{

    case $TERM in
        xterm | rxvt)
	    echo -ne "\033]30;$HOSTNAME\007\033]31;$PWD\007"
            echo -ne "\033]0;$*\007" ;;
        *)  ;;
    esac
}

function fastprompt()
{
    unset PROMPT_COMMAND
    PROMPT_COMMAND=fastprompt
	
	history -a
    case $TERM in
        *)
            PS1="\u@\h-> " ;;
    esac
}

function cd()
{
        if [[ $TERM = xterm ]]; then
                builtin cd "$@" && xtitle $HOSTNAME: $PWD
        else
                builtin cd "$@"
        fi
}

function xx()
{
    echo -ne "\033]30;`hostname | sed -e "s/^.*\(.\{20\}\)$/\1/"`\007\033]31;$PWD\007"

}

# ~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=
# =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~

PATH=/usr/local/bin:/bin:/usr/bin:/usr/sbin:/sbin

if [[ $OSTYPE = cygwin ]]; then
	prepend PATH "/cygdrive/c/Program Files/apache-maven-3.2.1/bin/"
	
	if [[ -d /cygdrive/c/jre16/bin ]]; then
		prepend PATH /cygdrive/c/jre16/bin
	fi
	alias caditool='java -jar `cygpath -w $HOME/bin/cadi-core.jar`'

fi

prepend PATH $HOME/bin
prepend PATH . 

export LD_LIBRARY_PATH
export MANPATH
export PATH

COMPREPLY=

export FIGNORE=.~1~:~
export HISTCONTROL=ignoreboth
HISTFILESIZE=400000000
HISTSIZE=10000

# no core files, thanks
ulimit -c 0

set -o notify
CDPATH=.:$HOME:$HOME/git:$HOME/git/auth

shopt -s cdable_vars
shopt -s checkhash
shopt -s checkwinsize
shopt -s sourcepath
shopt -s histappend histreedit
shopt -s cmdhist

if [ -x /usr/bin/dircolors ]; then
    alias ls='ls -F --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
else
    alias ls='ls -F'
fi

#
# Aliases we want to share...
alias grpe='grep'
alias h='history'
alias j='jobs -l'
alias l='ls -l'
alias ls-ltr='ls -ltr'

alias lz='ls -lSr'
alias m='more'
alias path='echo -e ${PATH//:/\\n}'
alias psg='ps -ef | grep'
alias tf='tail -f'
alias up='cd ..;pwd'

if [ $OSTYPE = linux ]; then
    alias ups='ps -ef'
elsif [ $OSTYPE = solaris ];
    alias ups='/usr/ucb/ps -auxww'
elsif [ $OSTYPE = cygwin]; 
    alias ups='ps -ef'	
else
    alias ups='ps'	
fi

test -s ~/.aliases && . ~/.aliases
test -s ~/.bashrc_local && . ~/.bashrc_local

xtitle $HOSTNAME
     
#
# This is kind of goofy. To check for interactive logins, you generally test the
# value of PS1 -- therefore, I need to set this at the very end, just in case..
#
if [ "$PS1" ]; then
    fastprompt
fi


# Local Variables:
# mode:shell-script
# sh-shell:bash
# End:

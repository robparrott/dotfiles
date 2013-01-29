
#-----------------------------------
# Source global definitions (if any)
#-----------------------------------

if [ -f /etc/bashrc ]; then
        . /etc/bashrc   # --> Read /etc/bashrc, if present.
fi
if [ -f /etc/bash.bashrc ]; then
        . /etc/bash.bashrc   # --> Read /etc/bash.bashrc, if present.
fi

if [ -f $HOME/.bashrc ]; then
        . $HOME/.bashrc   # --> Read /etc/bash.bashrc, if present.
fi





#-------------------------------------------------------------
# Run screen to make us happy!!!!
#-------------------------------------------------------------
_init_run_screen () {

  TTY=`/usr/bin/tty`
  if [ "$TTY" != "not a tty" -a "$TERM" != "screen" -a "$SHLVL" -eq 1 -a -n "$SSH_CLIENT" ]; then
    screen -t `hostname` -x -RR remote
  fi

}

#------------------------------
# Setup EDITOR 
#------------------------------
_init_setup_editor () {
  if [ -x /usr/bin/editor ]; then
    EDITOR=editor
  elif [ -x /usr/bin/xemacs ]; then
    EDITOR=xemacs
  elif [ -x /usr/bin/emacs ]; then
    EDITOR=emacs
  elif [ -x /usr/bin/vim ]; then
    EDITOR=vim
  else
    EDITOR=vi
  fi

  export EDITOR
}


#---------------------
# SSH Keychain
#----------------------

_init_setup_keychain () {

  CERTFILES=" seas gridadmin "

  KEYCHAIN=
  [ -x ~/usr/bin/keychain  ] && KEYCHAIN=~/usr/bin/keychain
  [ -z $KEYCHAIN ] && [ -x /usr/bin/keychain  ] && KEYCHAIN=/usr/bin/keychain
  if [ -n $KEYCHAIN ] ; then
 
    #
    # If there's already a ssh-agent running, then run keychain.
    #
    if [ ! "" = "$SSH_AGENT_PID" ]; then
      echo "Keychain: Found no SSH_AGENT_PID, so running keychain."

      $KEYCHAIN $CERTFILES && source ~/.keychain/$HOSTNAME-sh

    else

       #
       #  Otherwise offer to run keychain if no SSH_AUTH_SOCK is set
       #
       if [ -z $SSH_AUTH_SOCK ]; then
          echo "Keychain: Found no SSH_AUTH_SOCK, so running keychain."
          $KEYCHAIN $CERTFILES && source ~/.keychain/$HOSTNAME-sh
       fi

    fi
  fi

  unset CERTFILES KEYCHAIN
}

#----------------------------
# BASH completion
#----------------------------

_init_bash_completion () {

  # Check for bash (and that we haven't already been sourced).
  [ -z "$BASH_VERSION" -o -n "$BASH_COMPLETION" ] && return

  # Check for recent enough version of bash.
  bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}

  # Set the path
  #BASH_COMPLETION="${BASH_COMPLETION:-/etc/bash_completion}"
  BASH_COMPLETION=~/.completion/bash_completion
  BASH_COMPLETION_DIR=~/.completion/bash_completion.d/

  # Check for interactive shell.
  if [ -n "$PS1" ]; then
    if [ $bmajor -eq 2 -a $bminor '>' 04 ] || [ $bmajor -gt 2 ]; then
      if [ -r  $BASH_COMPLETION ]; then
        # Source completion code.
        . $BASH_COMPLETION
      fi
    fi
  fi
  unset bash bminor bmajor
}


#----------------------------
# Bash interactive settings
#----------------------------

_init_bash_settings () {

  # Make bash check it's window size after a process completes
  shopt -s checkwinsize

  ulimit -S -c 0          # Don't want any coredumps
  set -o notify
  set -o noclobber
  #set -o ignoreeof
  set -o nounset
  #set -o xtrace          # useful for debuging

  # Enable options:
  shopt -s cdspell                         # check spelling on directory changes
  shopt -s cdable_vars
  shopt -s checkhash
  shopt -s checkwinsize                    # Make bash check it's window size after a process completes
  shopt -s mailwarn
  shopt -s sourcepath
  shopt -s no_empty_cmd_completion         # bash>=2.04 only
  shopt -s cmdhist
  shopt -s histappend histreedit histverify
  shopt -s dotglob
  shopt -s extglob                         # necessary for programmable completion
  set +o nounset                           # otherwise some completions will fail

  # Disable options:
  shopt -u mailwarn
  unset MAILCHECK                          # I don't want my shell to warn me of incoming mail


  export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
  export HISTCONTROL=ignoreboth
  export HISTIGNORE="&:bg:fg:ll:h"


}


#----------------------------
#  Setup Shell vars
#---------------------------

_init_setup_shell_vars () {

  EMAIL=robparrott@gmail.com
  _init_setup_editor

}
  
#-----------------------
# Colors
#-----------------------

# Define some colors first:
#red='\e[0;31m'
#RED='\e[1;31m'
#blue='\e[0;34m'
#BLUE='\e[1;34m'
#cyan='\e[0;36m'
#CYAN='\e[1;36m'
#NC='\e[0m'              # No Color

red='\x1b[0;31m'
RED='\x1b[1;31m'
blue='\x1b[0;34m'
BLUE='\x1b[1;34m'
cyan='\x1b[0;36m'
CYAN='\x1b[1;36m'
NC='\x1b[0m'              # No Color 

# --> Nice. Has the same effect as using "ansi.sys" in DOS.

#----------------------------
#  Set Prompt
#---------------------------

_init_set_prompt () {

  PS1='\h:\w \u\$ '

  PROMPT="\u@\h \W> "
#  PS1=$PROMPT

}

#----------------------------
#  Aliases and such
#---------------------------

_init_aliases () {

  #
  #  Conveniences 
  #
  alias dotfiles="ls -ldF .[a-zA-Z0-9]*"
  alias j="jobs -l"
  alias k9='kill -9'
  alias pk9='pkill -9'


  #
  #  Color ls 
  #
  if [ x$OS = xLinux ]; then
    export LS_OPTIONS='--color=auto'
    eval `dircolors`
    alias ls='ls $LS_OPTIONS'
  fi
}

#----------------------------
#  Greeting
#----------------------------

# Looks best on a black background.....
function greetme()
{
    LOAD=$(uptime | sed -e 's/.*load aver.*: *//' | awk '{print $1}' | sed 's/,//')
    echo -e "${CYAN}BASH ${RED}${BASH_VERSION%.*}${CYAN} on ${RED}`hostname`${NC}"
    echo -e "${CYAN}BASH Completion is ${RED}$BASH_COMPLETION_ON${NC}"
    echo -e "${CYAN}DISPLAY on ${RED}$DISPLAY${NC}"
    echo -e "${CYAN}Load is ${RED}$LOAD${NC}"
    date
}


# ---------------------------------
#
# Useful utility functions
#
# --------------------------------


#
# Create a sequence from m to n
#
seq () {
      local lower upper output;
      lower=$1 upper=$2;
      while [ $lower -le $upper ];
      do  
          output="$output $lower";
          lower=$[ $lower + 1 ];
      done;
      echo $output
  }

#
# Repeat n times the argument
#
repeat () {
      local count="$1" i;
      shift;
      for i in $(seq 1 "$count");
      do
          eval "$@";
      done
  }



#######################################
#######################################
##
##  MAIN
##
##
#######################################
#######################################

_init_run_screen
_init_setup_shell_vars
_init_setup_keychain
_init_bash_completion
_init_bash_settings
_init_set_prompt
_init_aliases

greetme




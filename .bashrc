#-----------------------------------
#  
#  Setup stuff you want for every shell,
#   including scripts
#
#-----------------------------------


#-----------------------------------
# Source global definitions (if any)
#-----------------------------------


if [ -f /etc/bashrc ]; then
        . /etc/bashrc   # --> Read /etc/bashrc, if present.
fi

if [ -f /etc/bash.bashrc ]; then
        . /etc/bash.bashrc   # --> Read /etc/bash.bashrc, if present.
fi

#--------------------------
#
# Setup custom paths
#
#--------------------------

_init_setup_path () {

  #
  # Add /usr/local/bin as usual
  #
  if [ -d /usr/local ]; then
      PATH=$PATH:/usr/local/bin
  fi

  #
  # Fink paths
  # 
  if [ -f /sw/bin/init.sh ] ; then
     . /sw/bin/init.sh
  fi

  #
  # If We're using HomeBrew on the mac, then put /usr/local/bin first
  #
  if [ -d /usr/local/Cellar ]; then
       PATH=/usr/local/bin:$PATH
  fi

  #
  # Make sure that our local bin dir precedes others
  #
  PATH=~/usr/bin~/bin::$PATH

  export PATH

}

#-------------------------------------------
#
#  Use our own ssh-agent stuff from keychain
#
#--------------------------------------------

_init_keychain_sshadd () {

  if [ -f ~/.keychain/${HOSTNAME}-sh  ]; then
     source ~/.keychain/${HOSTNAME}-sh
  fi

}


#-------------------------------
#
# Manage modules
#
#--------------------------------

_init_modules () {

  if [ -d /opt/modules ]; then 

     . /opt/modules/Modules/init/bash
     module load null

  fi
}


#--------------------------
#--------------------------
#
#  MAIN
#
#--------------------------
#--------------------------

_init_setup_path
_init_keychain_sshadd
_init_modules



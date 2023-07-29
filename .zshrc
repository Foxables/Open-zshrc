#FOXABLES
# If you come from bash you might have to change your $PATH.
ME=$(whoami)
# export PATH=$HOME/bin:/usr/local/bin:$PATH
export GPG_TTY=$(tty)

export ZSH="/Users/$ME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

CMD_TIMER_COLOR="magenta"
CMD_TIMER="true"

plugins=(git rails ruby gem emoji encode64 git-extras)

source $ZSH/oh-my-zsh.sh


#############################################
# Aliases
#############################################

# General
alias 7zip="~/Scripts/7zz"
alias hist="history -i"

# IaC
alias terraform="~/Applications/terraform"
alias tfp="~/Applications/terraform plan"
alias tfi="~/Applications/terraform init"
alias tfa="~/Applications/terraform apply"
alias tfd="~/Applications/terraform destroy"

# SVC
alias gc="git commit -s"
alias gp="git push"
alias gs="git stash"
alias gsp="git stash pop"
alias gip="git pull"
alias gco="git checkout"
alias gfo="git fetch origin"
alias gsync="git pull origin/master"
alias gitfucked="git rm -rf . --cached"

#############################################
# Functions
#############################################
function gits() {
  if [[ ! -z "$1" ]] && [[ ! -z "$2" ]] && [[ -z "$3" ]];
  then
    if [[ "$1" == "delete" ]] || [[ "$1" == "d" ]];
    then
      git branch -D "$2" && git push origin -D "$2"
    elif [[ "$1" == "tag" ]] || [[ "$1" == "t" ]];
    then
      git tag "$2" && git push origin "$2"
    fi
  elif [[ ! -z "$1" ]] && [[ ! -z "$2" ]] && [[ ! -z "$3" ]];
  then
    if [[ "$1" == "new" ]] || [[ "$1" == "n" ]];
    then
      gs && gco "$2" && gip && gco -b "$3" && gsp
    fi
  fi
}

function checkForOpenZSHRCUpdate() {
  local FOXABLES_PATH=$(head -n 1 "$HOME/.foxables-zshrc.path")
  local FOXABLES_UPDATED=$(tail -n 1 "$HOME/.foxables-zshrc.path")
  local NOW=$(date +%s)
  local EXPIRE=$(expr $FOXABLES_UPDATED + 604800)
  if [[ $NOW -lt $EXPIRE ]];
  then
    return
  fi

  stat=$(git -C "$FOXABLES_PATH" fetch origin 2>&1)
  if [[ ! -z "$stat" ]];
  then
    read -p "A new update for Foxables Open-ZSHRC is available. Would you like to update? [y/N] " -n 1 -r

    if [[ $REPLY =~ ^[Yy]$ ]];
    then
      git -C "$FOXABLES_PATH" pull origin master
      echo "Updated! Please run 'source ~/.zshrc' again."
    else
      echo "$FOXABLES_PATH" > "$HOME/.foxables-zshrc.path"
      echo "$NOW" >> "$HOME/.foxables-zshrc.path"
    fi
  fi
}

function getCMDTimerMagnitudeModifier() {
  if [[ "$CMD_TIMER_MAGNITUDE" == "ms" ]];
  then
  # Milisecond, or 1 thousandth of a second.
    echo 1000000
    return
  elif [[ "$CMD_TIMER_MAGNITUDE" == "us" ]] || [[ "$CMD_TIMER_MAGNITUDE" == "µs" ]];
  then
  # Microsecond, or 1 millionth of a second.
    echo 1000
    return
  fi
  # Default is Nanosecond, or 1 billionth of a second.
  echo 1
}

function systime() {
  local time=$(date $@)
  if [[ "${time: -1}" == "N" ]];
  then
    local gtime=$(gdate $@ 2>&1)
    if [[ ! "$gtime" =~ "not found" ]];
    then
      echo "$gtime"
      return
    else
      echo "${time:0:-1}000000000"
      return
    fi
  fi

  echo "$time"
}

function formatFromNS() {
  local delta=$1
  # Days
  p1=$(expr $delta / 1000000000 / 60 / 60 / 24)
  # Hours
  p2=$(expr $delta / 1000000000 / 60 / 60 % 24)
  # Minutes
  p3=$(expr $delta / 1000000000 / 60 % 60 % 24)
  # Seconds
  p4=$(expr $delta % 10000000000 / 1000000000)
  # Miliseconds
  p5=$(expr $delta % 1000000000 / 1000 / 1000 % 1000)
  # Microseconds
  p6=$(expr $delta % 1000000000 / 1000 % 1000)
  # Nanoseconds
  p7=$(expr $delta % 1000000000 % 1000)

  opt=""
  count=0
  vals=($p1 $p2 $p3 $p4 $p5 $p6 $p7)
  for i in "${vals[@]}"
  do
    if [[ $i -gt 0 ]];
    then
      if [[ -z "$opt" ]];
      then
        opt="$i"
      else
        opt="$opt $i"
      fi
      if [[ $count -eq 0 ]];
      then
        opt="${opt}d"
      elif [[ $count -eq 1 ]];
      then
        opt="${opt}h"
      elif [[ $count -eq 2 ]];
      then
        opt="${opt}m"
      elif [[ $count -eq 3 ]];
      then
        opt="${opt}s"
      elif [[ $count -eq 4 ]];
      then
        opt="${opt}ms"
      elif [[ $count -eq 5 ]];
      then
        opt="${opt}µs"
      elif [[ $count -eq 6 ]];
      then
        opt="${opt}ns"
      fi
    fi

    count=$((count+1))
  done
  echo "$opt"
}

function preexec() {
  if [[ -z "$CMD_TIMER" ]] || [[ "$CMD_TIMER" != "true" ]];
  then
    return
  fi

  cur=$(systime +%s%0N)
  if [[ "$cur" =~ "not found" ]] || [[ "${cur: -1}" == "N" ]];
  then
    timerStart=0
    return
  fi

  timerStart=$cur
}

function precmd() {
  if [[ -z "$CMD_TIMER" ]] || [[ "$CMD_TIMER" != "true" ]];
  then
    if [[ ! -z "$RPROMPT" ]];
    then
      export RPROMPT=""
      unset timerStart
    fi
    return
  fi

  if [ $timerStart ] && [ $timerStart -ne 0 ]; then
    cur=$(systime +%s%0N)
    delta=$(($cur-$timerStart))

    elapsedPretty=$(formatFromNS $delta)
    export RPROMPT="%F{$CMD_TIMER_COLOR}${elapsedPretty} %{$reset_color%}"
    unset timerStart
  else
    export RPROMPT="%F{$CMD_TIMER_COLOR}%{$reset_color%}"
  fi
}

# Disable mouse accelleration on mac.
defaults write .GlobalPreferences com.apple.mouse.scaling -1

# NVM
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion

checkForOpenZSHRCUpdate
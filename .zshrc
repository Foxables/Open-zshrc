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

DEFAULT_SSH_USER="root"
DEFAULT_SSH_KEY="~/.ssh/id_rsa"

plugins=(git rails ruby gem emoji encode64 git-extras)

source $ZSH/oh-my-zsh.sh


#############################################
# Aliases
#############################################

# General
alias 7zip="~/Scripts/7zz"
alias hist="history -i"
alias k="kubectl"
alias d="docker"
alias dc="docker-compose"
alias py="python3"


# IaC
alias terraform="~/Applications/terraform"
alias tfp="~/Applications/terraform plan"
alias tfi="~/Applications/terraform init"
alias tfa="~/Applications/terraform apply"
alias tfd="~/Applications/terraform destroy"

# SVC
alias ga="git add"
alias gc="git commit -s"
alias gp="git push"
alias gs="git stash"
alias gsp="git stash pop"
alias gip="git pull"
alias gco="git checkout"
alias gfo="git fetch origin"
alias gsync="git pull origin/master"
alias gitfucked="git rm -rf . --cached"
alias gitbig="git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | sed -n 's/^blob //p' | sort -r --numeric-sort --key=2 | cut -c 1-12,41- | $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest | head";
alias gitbigall="git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | sed -n 's/^blob //p' | sort -r --numeric-sort --key=2 | cut -c 1-12,41- | $(command -v gnumfmt || echo numfmt) --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest";
alias gprune="git branch --v | grep "\[gone\]" | awk '{print $1}' | xargs git branch -D"

#############################################
# Functions
#############################################
function gits() {
  if [[ ! -z "$1" ]] && [[ ! -z "$2" ]] && [[ -z "$3" ]];
  then
    if [[ "$1" == "delete" ]] || [[ "$1" == "d" ]];
    then
      git branch -D "$2" && git push origin -d "$2"
    elif [[ "$1" == "tag" ]] || [[ "$1" == "t" ]];
    then
      git tag "$2" && git push origin "$2"
    elif [[ "$1" == "switch" ]] || [[ "$1" == "s" ]];
    then
      gco "$2" && gip -f
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
  if [[ ! -z "$stat" ]] && [[ ! "$stat" =~ "fatal" ]] && [[ ! "$stat" =~ "not found" ]];
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
      # Mac OS X, if gdate is not installed you can't get nanoseconds.
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

function c() {
  # SSH Connections.
  local USER="$DEFAULT_SSH_USER"
  FALLBACK_USERS=( ec2-user ubnt ubuntu root $(whoami) )

  if [[ -z "$1" ]];
  then
    echo "Usage: c <host> [user] [key]"
    exit 1
  fi
  local HOST="$1"

  if [[ ! -z "$2" ]];
  then
    USER="$2"
  fi

  local KEY=""
  if [[ ! -z "$DEFAULT_SSH_KEY" ]] && [[ -f "$DEFAULT_SSH_KEY" ]];
  then
    KEY="-i '$DEFAULT_SSH_KEY'"
  fi

  if [[ ! -z "$3" ]] && [[ -f "$3" ]];
  then
    KEY="-i $3"
  fi

  local RES=$(ssh $USER@"$HOST" $KEY "uname -mrs")
  if [[ "$RES" =~ "Permission denied" ]];
  then
    for i in "${FALLBACK_USERS[@]}"
    do
      RES=$(ssh $i@"$HOST" $KEY "uname -mrs")
      if [[ ! "$RES" =~ "Permission denied" ]];
      then
        USER="$i"
        break
      fi
    done
  fi
  ssh $USER@"$HOST" $KEY
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
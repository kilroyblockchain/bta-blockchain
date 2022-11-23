#!/bin/bash

C_RESET='\033[0m'
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_YELLOW='\033[1;33m'

# println echos string
println() {
  echo -e "$1"
}

# errorln echos i red color
errorln() {
  println "${C_RED}${1}${C_RESET}"
}

# successln echos in green color
successln() {
  println "${C_GREEN}${1}${C_RESET}"
}

# infoln echos in blue color
infoln() {
  println "${C_BLUE}${1}${C_RESET}"
}

# warnln echos in yellow color
warnln() {
  println "${C_YELLOW}${1}${C_RESET}"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    errorln "---------------------------------------------------------------------------"
    errorln "---------------------------------------------------------------------------"
    errorln "$2"
    errorln "---------------------------------------------------------------------------"
    errorln "---------------------------------------------------------------------------"
    exit 1
  fi
}

successResult(){
    if [ $1 -ne 0 ]; then
    errorln "$2"
  fi
}

export errorln
export successln
export infoln
export warnln


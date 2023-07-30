#!/bin/bash

#####################
# Auto Variables, best not to change unless you know what you're doing here.
#####################
PWD=$(pwd)
REPO=""
DRY_RUN=false
LOG_FILE="$PWD/install.log" # Set to empty string to disable logging.

#####################
# Error Codes
#####################
GIT_NOT_INSTALLED=3
UNABLE_TO_CLONE=2
ALREADY_INSTALLED=4
SUCCESS=0

#####################
# CONSTANTS
#####################
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

#####################
# Functions.
#####################
function cloneRepo() {
    reportStep "Cloning repo..."
    if [[ $DRY_RUN ]];
    then
        reportStep "Dry run, skipping clone."
        return
    fi
    RES=$(git clone git@github.com:Foxables/Open-zshrc.git "$PWD/$REPO" 2>&1)
    if [[ "$RES" == *"fatal"* ]];
    then
        reportStep "Failed to clone repo."
        reportStep "$RES"
        reportStep "Please clone the repository manually to continue."
        reportError "Failed to clone repo." $UNABLE_TO_CLONE
    elif [[ "$RES" == *"already exists"* ]];
    then
        reportStep "Repo already exists."
    elif [[ "$RES" == *"not found"* ]];
    then
        reportError "Command not found, please install git to continue or perform a manual installation per the documentation here: https://github.com/Foxables/Open-zshrc/" $GIT_NOT_INSTALLED
    else
        reportStep "Cloned repo."
    fi
}

function cloneRepoIfWeAreNotInARepo() {
    if [[ ! -z "$REPO" ]];
    then
        createRepoDirIfNotExists
        cloneRepo
    fi
}

function checkIfWeAreInTheRepo() {
    reportStep "Are we in a repo?"

    if [[ ! -d "$PWD/.git" ]];
    then
        reportStep "No, we are not in a repo."
        REPO="open-zshrc"
        return
    fi

    reportStep "Yes! We are in a repo."
}

function createRepoDirIfNotExists() {
    reportStep "Creating repo directory if it does not exist."
    if [[ ! -d "$PWD/$REPO" ]];
    then
        mkdir -p "$PWD/$REPO"
        reportStep "Repo directory has been created!"
    fi
}

function scanExistingZSHRC() {
    reportStep "Scanning existing ~/.zshrc"
    if [[ -e "$HOME/.zshrc" ]];
    then
        reportStep "Found existing ~/.zshrc"
        lnOne=$(head -n 1 "$HOME/.zshrc")
        if [[ "$lnOne" == "#FOXABLES" ]];
        then
            reportStep "Existing ~/.zshrc is a foxables zshrc."
            reportError "Already installed." $ALREADY_INSTALLED
        fi
    fi
}

function backupExistingZSHRC() {
    reportStep "Backing up ~/.zshrc to ~/.zshrc.bak"
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
}

function actuallyDoTheInstall() {
    reportStep "Installing..."
    local link$(ln -s "$PWD/$REPO/.zshrc" "$HOME/.zshrc")
    appendToFile "$PWD/$REPO" "$HOME/.foxables-zshrc.path"
    appendToFile $(date +%s) "$HOME/.foxables-zshrc.path"
    reportSuccess
}

function reportStep() {
    local datetime=$(date +"%Y-%m-%d %T")
    echo "[$datetime] $1"

    if [[ ! -z "$LOG_FILE" ]];
    then
        appendToFile "[$datetime] $1" "$LOG_FILE"
    fi
}

function reportSuccess() {
    reportStep "Installed! Please run 'source ~/.zshrc' to apply changes."
    echo -e "${GREEN}Installed! Please run 'source ~/.zshrc' to apply changes.${NC}"
    exit $SUCCESS
}

function reportError() {
    reportStep "Error: $1"
    echo -e "${RED}Error: $1${NC}" >&2
    exit $2
}

function appendToFile () {
    if [[ ! -e "$2" ]];
    then
        touch "$2"
    fi

    echo "$1" >> "$2"
}

function main() {
    reportStep "Starting installation..."
    checkIfWeAreInTheRepo
    cloneRepoIfWeAreNotInARepo
    scanExistingZSHRC
    backupExistingZSHRC
    actuallyDoTheInstall
}

#####################
# Main
#####################
main "$@"

    # EOF;

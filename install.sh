#!/bin/bash
PWD=$(pwd)
if [[ -e "$HOME/.zshrc" ]];
then
    lnOne=$(head -n 1 "$HOME/.zshrc")
    if [[ "$lnOne" == "#FOXABLES" ]];
    then
        echo "Already installed."
        exit 0
    fi

    echo "Backing up ~/.zshrc to ~/.zshrc.bak"
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi

ln -s "$PWD/.zshrc" "$HOME/.zshrc"
echo "$PWD" > "$HOME/.foxables-zshrc.path"
echo $(date +%s) >> "$HOME/.foxables-zshrc.path"
echo "Installed! Please run 'source ~/.zshrc' to apply changes."
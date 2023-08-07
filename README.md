## Foxables Open .ZSHRC

### Automated Installation
1. Run the command  
    `curl -s https://raw.githubusercontent.com/Foxables/Open-zshrc/master/install.sh > install.sh && bash install.sh`
1. Eat Cake!

### Manual Installation
Simply clone this repo, and then run `bash install.sh`.

Please feel free to use this to your hearts content. It will continue to be maintained and the zshrc file will automatically check  if there's updates from the repo.

### Dependencies / Requirements
In order to install and maintain the Foxables' Open .zshrc, you must;
- Be running a POSIX / Unix based Environment such as Linux, Ubuntu, MacOS.
- Have cURL CLI installed. (See: https://everything.curl.dev/get)
- Have Git installed. (See: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- Be running ZSH as your shell environment. (See: https://www.linuxuprising.com/2021/01/how-to-change-default-shell-in-linux.html)
- Have Oh-My-Zsh! installed. (See: https://ohmyz.sh/)

#### Mac OSX Compatibility
- If you want Milisecond, Microsecond, and Nanosecond scale CMD Times in Mac OSX, you need to have `gdate` installed. Use the Homebrew command `brew install coreutils`

If you like this and want to support Foxables, please share our blog [Foxables.IO](https://foxables.io).

## Customisations
Simply create the directory `zshrc.d` in your `$ZSH` path, and add each customisation to a bash file. If this directory exists, then Foxables Open-ZSHRC will automatically load in your customisations.

***Powered By Paws Defacing Keyboards***
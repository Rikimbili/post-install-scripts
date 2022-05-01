#!/usr/bin/bash

# Console colors
ERROR='\033[1;31m'
SUCCESS='\033[1;32m'
WARNING='\033[1;33m'
CLEAR='\033[0m'

# Variable declarations
fnm_fish_config="fnm env --use-on-cd | source"
starship_fish_config="starship init fish | source"
starship_config_url="https://gitcdn.xyz/cdn/Rikimbili/post-install-scripts/main/config/starship.toml"

sudo apt update && sudo apt upgrade -y
sudo apt install build-essential fish neofetch htop git curl unzip python3 python3-pip -y

# Set up fish with starship and fnm. Proceed with fish set up only if fish is installed
if command -v fish &> /dev/null ; then
    fish_dir=`which fish`
    fish_setup_errored=false
    
    if ! grep -q "$fish_dir" /etc/shells ; then # Add fish to /etc/shells if not already present
        echo $fish_dir >> /etc/shells
    fi
    test "$SHELL" != "$fish_dir" && chsh -s $fish_dir # Set fish as default shell if not already set

    # Install starship or fnm if not already installed
    ! command -v starship &> /dev/null && curl -sS https://starship.rs/install.sh | sh
    ! command -v fnm &> /dev/null && curl -fsSL https://fnm.vercel.app/install | bash
    source ~/.bashrc # Reload .bashrc


    # Add fish configs if not already present
    if ! grep -q "$starship_fish_config" ~/.config/fish/config.fish ; then
        echo "${starship_fish_config} # Initializes the starship shell prompt" >> ~/.config/fish/config.fish
    fi
    if ! grep -q "$fnm_fish_config" ~/.config/fish/config.fish; then
        echo "${fnm_fish_config} # Allows fnm to auto-change node version based on directory" >> ~/.config/fish/config.fish
    fi

    # Check if starship.toml file exists to prevent overwriting any existing config.
    if ! test -f ~/.config/starship.toml ; then
        mkdir -p ~/.config
        curl $starship_config_url -o ~/.config/starship.toml
    fi

    if $fish_setup_errored = true ; then
        echo -e "\n${WARNING}Fish setup completed with errors.${CLEAR}\n"
    else 
        echo -e "\n${SUCCESS}Fish setup completed successfully.${CLEAR}\n"
    fi
else
    echo -e "\n${ERROR}Cannot proceed because fish was not installed properly.${CLEAR}\n"
fi

echo -e "${SUCCESS}All operations done.${CLEAR}\nDon't forget to log out and back in for some changes to apply.\n"

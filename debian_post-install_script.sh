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
sudo apt install build-essential fish neovim neofetch htop git unzip python3 python3-pip -y

# Set up fish with various packages
fish_setup_errored=false
if command -v fish &> /dev/null ; then
    fish_dir=`which fish`
    
    # Add fish to /etc/shells if not already present
    if ! grep -q "$fish_dir" /etc/shells ; then
        echo $fish_dir >> /etc/shells
    fi
    # Set fish as default user shell if not already set
    [ "$SHELL" != "$fish_dir" ] && { sudo chsh -s $fish_dir $(whoami) || fish_setup_errored=true ; }

    # Install packages and set them up for fish
    ! command -v starship &> /dev/null && { curl -sS https://starship.rs/install.sh | sh || fish_setup_errored=true ; }
    ! command -v fnm &> /dev/null && { curl -fsSL https://fnm.vercel.app/install | bash || fish_setup_errored=true ; }
    ! command -v fisher &> /dev/null && { curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && { fisher install jorgebucaran/fisher || fish_setup_errored=true ; } ; }
    source ~/.bashrc # Reload .bashrc
    fish -c source ~/.config/fish/conf.d/fnm.fish # Reload fnm.fish with fish

    # Add fish configs if not already present
    if ! grep -q "$starship_fish_config" ~/.config/fish/config.fish ; then
        echo "${starship_fish_config} # Initializes the starship shell prompt" >> ~/.config/fish/config.fish
    fi
    if ! grep -q "$fnm_fish_config" ~/.config/fish/config.fish; then
        echo "${fnm_fish_config} # Allows fnm to auto-change node version based on directory" >> ~/.config/fish/config.fish
    fi

    # Check if starship.toml file exists to prevent overwriting any existing config.
    if ! [ -f ~/.config/starship.toml ] ; then
        mkdir -p ~/.config
        curl $starship_config_url -o ~/.config/starship.toml
    fi

    if [ $fish_setup_errored = true ] ; then
        echo -e "\n${WARNING}Fish setup completed with errors.${CLEAR}\n"
    else 
        echo -e "\n${SUCCESS}Fish setup completed successfully.${CLEAR}\n"
    fi
else
    echo -e "\n${ERROR}Cannot proceed because fish was not installed properly.${CLEAR}\n"
fi
if [ $fish_setup_errored = true ] ; then
    echo -e "${WARNING}Some operations completed with errors.${CLEAR}\n"
else
    echo -e "${SUCCESS}All operations done.${CLEAR}\nDon't forget to log out and log back in for some changes to apply."
fi
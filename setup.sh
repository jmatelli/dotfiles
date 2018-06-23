#!/bin/bash

# SETUP NEW MACHINE

apt-get update -y
apt-get upgrade -y

# misc packages
apt-get -y install software-properties-common
apt-add-repository -y ppa:webupd8team/java

apt -y install curl
apt -y install gnome-tweak-tool gnome-shell-extensions
apt -y install paper-icon-theme
apt -y install p7zip-full
apt -y install python-dev python-pip python3-dev python3-pip
apt -y install oracle-java8-installer
apt -y install imagemagick
apt -y install cmake

# install git
apt-get install -y git

# install tmux
apt-get install -y tmux

# install zsh, oh my zsh and antigen
apt-get install -y zsh
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
curl -L git.io/antigen > ~/bin/antigen.zsh

# install neovim
apt-get install -y software-properties-common
apt-add-repository ppa:neovim-ppa/stable -y
apt-get update -y
apt-get install -y neovim
update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
update-alternatives --config vi --skip-auto
update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
update-alternatives --config vim --skip-auto
update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
update-alternatives --config editor --skip-auto

# install vim-plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# install nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
source ~/.bashrc
source ~/.zshrc
nvm install 8
nvm install 10

# install docker
apt-get install -y apt-transport-https ca-certificates software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -y
apt-get install -y docker-ce
docker run hello-world

# install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

# install postgresql
docker pull postgres:latest

# install redis
docker pull redis:latest

# install heroku
snap install heroku --classic

# install VS Code
cd ~/Downloads
curl -o vscode.deb -L https://go.microsoft.com/fwlink/?LinkID=760868
dpkg -i vscode.deb
apt-get install -f
echo ""
echo "Installing VS Code extensions as normal user"
echo ""
sudo -u tellijo code --install-extension mubaidr.vuejs-extension-pack
sudo -u tellijo code --install-extension dbaeumer.vscode-eslint
sudo -u tellijo code --install-extension eg2.tslint
sudo -u tellijo code --install-extension eamodio.gitlens
sudo -u tellijo code --install-extension PeterJausovec.vscode-docker
sudo -u tellijo code --install-extension esbenp.prettier-vscode
sudo -u tellijo code --install-extension Zignd.html-css-class-completion
sudo -u tellijo code --install-extension vsmobile.vscode-react-native
sudo -u tellijo code --install-extension kumar-harsh.graphql-for-vscode
sudo -u tellijo code --install-extension cssho.vscode-svgviewer
sudo -u tellijo code --install-extension Orta.vscode-jest
sudo -u tellijo code --install-extension sdras.night-owl
sudo -u tellijo code --install-extension sdras.vue-vscode-extensionpack
sudo -u tellijo code --install-extension sdras.vue-vscode-snippets
sudo -u tellijo code --install-extension formulahendry.auto-close-tag
sudo -u tellijo code --install-extension orta.vscode-react-native-storybooks

# symlink config files
cd ~/code/dotfiles
rm ~/.editorconfig
ls .editorconfig ~/.editorconfig
rm ~/.gitconfig
ls .gitconfig ~/.gitconfig
rm ~/.gitignore
ls .gitignore ~/.gitignore
rm ~/.nvimrc
ls .nvimrc ~/.nvimrc
rm ~/.vimrc
ls .nvimrc ~/.vimrc
rm ~/.tern-config
ls .tern-config ~/.tern-config
rm ~/.tmux.conf
ls .tmux.conf ~/.tmux.conf
rm ~/.zshrc
ls .zshrc ~/.zshrc

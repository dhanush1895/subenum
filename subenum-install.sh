#!/bin/bash

#go
#notify 
#assetfinder
#amass
#subfinder
#findomain
#subls
#github-subd
#knockknock
#fuzz
#wordlist - all
#knockpy
#subbrute
#filter-resolved
#httpx
#nuclei 



RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

echo -e "\n${RED}Specify the VERSION of GO:\n\nEx:1.20.3 \nYou can check from -> 'https://go.dev/doc/install'\nGOVERSION>>>\c${RESET}" && read GOVERSION

sudo apt-get -y update
sudo apt-get -y upgrade

sudo add-apt-repository -y ppa:apt-fast/stable < /dev/null
sudo echo debconf apt-fast/maxdownloads string 16 | debconf-set-selections
sudo echo debconf apt-fast/dlflag boolean true | debconf-set-selections
sudo echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections
sudo apt install -y apt-fast
sudo apt-fast install -y python-pip 
sudo apt-fast install -y postgresql-contrib
sudo apt-fast install -y apt-transport-https
sudo apt-fast install -y libcurl4-openssl-dev
sudo apt-fast install -y libssl-dev
sudo apt-fast install -y jq
sudo apt-fast install -y ruby-full
sudo apt-fast install -y libcurl4-openssl-dev libxml2 libxml2-dev libxslt1-dev ruby-dev build-essential libgmp-dev zlib1g-dev
sudo apt-fast install -y build-essential libssl-dev libffi-dev python-dev
sudo apt-fast install -y python-setuptools
sudo apt-fast install -y libldns-dev
sudo apt-fast install -y python3-pip
sudo apt-fast install -y python-dnspython
sudo apt-fast install -y git
sudo apt-fast install -y npm
sudo apt-fast install -y nmap phantomjs 
sudo apt-fast install -y gem
sudo apt-fast install -y perl 
sudo apt-fast install -y parallel
sudo pip3 install jsbeautifier
sudo apt install -y figlet
sudo apt install -y tor
sudo apt-get install git -y
sudo apt-get install unzip -y
echo ""
echo ""
sar 1 1 >/dev/null

mkdir -p ~/tools
cd ~/tools

GOSCRIPT(){
            #!/bin/bash
            # shellcheck disable=SC2016
            #set -e
            #VERSION="1.20.1"

            [ -z "$GOROOT" ] && GOROOT="$HOME/.go"
            [ -z "$GOPATH" ] && GOPATH="$HOME/go"

            OS="$(uname -s)"
            ARCH="$(uname -m)"

            case $OS in
                "Linux")
                    case $ARCH in
                    "x86_64")
                        ARCH=amd64
                        ;;
                    "aarch64")
                        ARCH=arm64
                        ;;
                    "armv6" | "armv7l")
                        ARCH=armv6l
                        ;;
                    "armv8")
                        ARCH=arm64
                        ;;
                    .*386.*)
                        ARCH=386
                        ;;
                    esac
                    PLATFORM="linux-$ARCH"
                ;;
                "Darwin")
                      case $ARCH in
                      "x86_64")
                          ARCH=amd64
                          ;;
                      "arm64")
                          ARCH=arm64
                          ;;
                      esac
                    PLATFORM="darwin-$ARCH"
                ;;
            esac

            print_help() {
                echo "Usage: bash goinstall.sh OPTIONS"
                echo -e "\nOPTIONS:"
                echo -e "  --remove\tRemove currently installed version"
                echo -e "  --version\tSpecify a version number to install"
            }

            if [ -z "$PLATFORM" ]; then
                echo "Your operating system is not supported by the script."
                exit 1
            fi

            if [ -n "$($SHELL -c 'echo $ZSH_VERSION')" ]; then
                shell_profile="$HOME/.zshrc"
            elif [ -n "$($SHELL -c 'echo $BASH_VERSION')" ]; then
                shell_profile="$HOME/.bashrc"
            elif [ -n "$($SHELL -c 'echo $FISH_VERSION')" ]; then
                shell="fish"
                if [ -d "$XDG_CONFIG_HOME" ]; then
                    shell_profile="$XDG_CONFIG_HOME/fish/config.fish"
                else
                    shell_profile="$HOME/.config/fish/config.fish"
                fi
            fi

            if [ "$1" == "--remove" ]; then
                rm -rf "$GOROOT"
                if [ "$OS" == "Darwin" ]; then
                    if [ "$shell" == "fish" ]; then
                        sed -i "" '/# GoLang/d' "$shell_profile"
                        sed -i "" '/set GOROOT/d' "$shell_profile"
                        sed -i "" '/set GOPATH/d' "$shell_profile"
                        sed -i "" '/set PATH $GOPATH\/bin $GOROOT\/bin $PATH/d' "$shell_profile"
                    else
                        sed -i "" '/# GoLang/d' "$shell_profile"
                        sed -i "" '/export GOROOT/d' "$shell_profile"
                        sed -i "" '/$GOROOT\/bin/d' "$shell_profile"
                        sed -i "" '/export GOPATH/d' "$shell_profile"
                        sed -i "" '/$GOPATH\/bin/d' "$shell_profile"
                    fi
                else
                    if [ "$shell" == "fish" ]; then
                        sed -i '/# GoLang/d' "$shell_profile"
                        sed -i '/set GOROOT/d' "$shell_profile"
                        sed -i '/set GOPATH/d' "$shell_profile"
                        sed -i '/set PATH $GOPATH\/bin $GOROOT\/bin $PATH/d' "$shell_profile"
                    else
                        sed -i '/# GoLang/d' "$shell_profile"
                        sed -i '/export GOROOT/d' "$shell_profile"
                        sed -i '/$GOROOT\/bin/d' "$shell_profile"
                        sed -i '/export GOPATH/d' "$shell_profile"
                        sed -i '/$GOPATH\/bin/d' "$shell_profile"
                    fi
                fi
                echo "Go removed."
                exit 0
            elif [ "$1" == "--help" ]; then
                print_help
                exit 0
            elif [ "$1" == "--version" ]; then
                if [ -z "$2" ]; then # Check if --version has a second positional parameter
                    echo "Please provide a version number for: $1"
                else
                    GOVERSION=$2
                fi
            elif [ ! -z "$1" ]; then
                echo "Unrecognized option: $1"
                exit 1
            fi

            PACKAGE_NAME="go$GOVERSION.$PLATFORM.tar.gz"
            TEMP_DIRECTORY=$(mktemp -d)

            echo "Downloading $PACKAGE_NAME ..."
            if hash wget 2>/dev/null; then
                wget https://storage.googleapis.com/golang/$PACKAGE_NAME -O "$TEMP_DIRECTORY/go.tar.gz"
            else
                curl -o "$TEMP_DIRECTORY/go.tar.gz" https://storage.googleapis.com/golang/$PACKAGE_NAME
            fi

            if [ $? -ne 0 ]; then
                echo "Download failed! Exiting."
                exit 1
            fi

            echo "Extracting File..."
            mkdir -p "$GOROOT"

            tar -C "$GOROOT" --strip-components=1 -xzf "$TEMP_DIRECTORY/go.tar.gz"

            echo "Configuring shell profile in: $shell_profile"
            touch "$shell_profile"
            if [ "$shell" == "fish" ]; then
                {
                    echo '# GoLang'
                    echo "set GOROOT '${GOROOT}'"
                    echo "set GOPATH '$GOPATH'"
                    echo 'set PATH $GOPATH/bin $GOROOT/bin $PATH'
                } >> "$shell_profile"
            else
                {
                    echo '# GoLang'
                    echo "export GOROOT=${GOROOT}"
                    echo 'export PATH=$GOROOT/bin:$PATH'
                    echo "export GOPATH=$GOPATH"
                    echo 'export PATH=$GOPATH/bin:$PATH'
                } >> "$shell_profile"
            fi

            mkdir -p "${GOPATH}/"{src,pkg,bin}
            echo -e "\nGo $GOVERSION was installed into $GOROOT.\nMake sure to relogin into your shell or run:"
            echo -e "\n\tsource $shell_profile\n\nto update your environment variables."
            echo "Tip: Opening a new terminal window usually just works. :)"
            rm -f "$TEMP_DIRECTORY/go.tar.gz"
}


GOINSTALL(){
    echo "${GREEN} [+] Installing Golang ${RESET}"
    if [[ ! -f /usr/bin/go ]];then
        cd ~
        #wget -q -O - https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh | bash
        GOSCRIPT
        export GOROOT=$HOME/.go
        export PATH=$GOROOT/bin:$PATH
        export GOPATH=$HOME/go
        echo 'export GOROOT=$HOME/.go' >> ~/.bash_profile
        echo 'export GOPATH=$HOME/go'   >> ~/.bash_profile          
        echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bash_profile
        source ~/.bash_profile 
    else 
        echo "${BLUE} Golang is already installed${RESET}"
    fi
    echo""
    echo "${BLUE} Done Install Golang ${RESET}"
    echo ""
    echo ""
    #sar 1 1 >/dev/null
}

GOINSTALL


echo "${BLUE} Installing anew ${RESET}"
GO111MODULE=on go install -v github.com/tomnomnom/anew@latest
echo "${BLUE}done${RESET}"
echo ""

echo "${BLUE} Installing notify & intercept ${RESET}"
GO111MODULE=on go install -v github.com/projectdiscovery/notify/cmd/notify@latest
GO111MODULE=on go install -v github.com/projectdiscovery/notify/cmd/intercept@latest
echo "${BLUE} done${RESET}"
echo ""


echo "${BLUE} Installing assetfinder${RESET}"
GO111MODULE=on go install -v github.com/tomnomnom/assetfinder@latest
echo "${BLUE} done${RESET}"
echo ""

echo "${BLUE}Installing Go version of github-subdomains scanning${RESET}"
GO111MODULE=on go install github.com/gwen001/github-subdomains@latest
echo "${BLUE}done${RESET}"

cd ~/tools

echo "${BLUE} Installing amass${RESET}"
go install -v github.com/owasp-amass/amass/v3/...@master
mkdir -p ~/.config/amass && cd ~/.config/amass && wget -q https://raw.githubusercontent.com/OWASP/Amass/master/examples/config.ini
cd ~/tools
echo "${BLUE}Amass done${RESET}"
echo ""

echo "${BLUE} Installing subfinder${RESET}"
GO111MODULE=on go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
echo "${BLUE}done${RESET}"
echo ""

# echo "${BLUE} Installing findomain${RESET}"
# cd ~/tools
# wget https://github.com/Findomain/Findomain/releases/download/8.2.1/findomain-linux.zip
# sudo chmod +x findomain-linux
# sudo mv findomain-linux /usr/bin/
# echo "${BLUE} Add your keys in the config file"
# echo "${BLUE} done${RESET}"
# echo ""
sar 1 1 >/dev/null


echo "${BLUE} Installing Sublister ${RESET}"
cd ~/tools
git clone https://github.com/aboul3la/Sublist3r.git
cd ~/tools/Sublist3r
sudo pip3 install -r requirements.txt
sudo apt-get install python3-requests
echo "${BLUE} done ${RESET}"
echo ""

echo "${BLUE} Installing knock2 or knockknock${RESET}"
go install -v github.com/harleo/knockknock@latest
echo "${BLUE} done${RESET}"
echo ""


echo "${BLUE} Installing ffuf${RESET}"
go install -v github.com/ffuf/ffuf@latest
echo "${BLUE} done${RESET}"
echo ""

echo "${BLUE}Installing subbrute${RESET}"
cd ~/tools
git clone https://github.com/TheRook/subbrute.git
echo "${BLUE}done${RESET}"

echo "${BLUE} Downloading knockpy${RESET}"
cd ~/tools/ && git clone https://github.com/guelfoweb/knock.git
cd knock
sudo apt install python3-virtualenv
sudo python3 setup.py install
virtualenv --python=python3 venv3
source venv3/bin/activate
pip3 install -r requirements.txt
echo "${BLUE} done${RESET}"
echo ""


echo "${BLUE} Installing filter-resolved${RESET}"
GO111MODULE=on go install -v github.com/tomnomnom/hacks/filter-resolved@install
echo "${BLUE} done${RESET}"
echo ""


echo "${BLUE} Installing httpx${RESET}"
GO111MODULE=on go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
echo "${BLUE} done${RESET}"
echo ""

echo "${BLUE} Installing nuclei${RESET}"
GO111MODULE=on go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
echo "${BLUE} done${RESET}"
echo ""

echo "${BLUE}Installing JSUBFINDER${RESET}"
GO111MODULE=on go install -v github.com/hiddengearz/jsubfinder@latest
wget https://raw.githubusercontent.com/hiddengearz/jsubfinder/master/.jsf_signatures.yaml && mv .jsf_signatures.yaml ~/.jsf_signatures.yaml
echo "${BLUE}done${RESET}"

echo "${BLUE}Installing crtpy${RESET}"
cd ~/tools && git clone https://github.com/YashGoti/crtsh.py.git
cd crtsh.py
mv crtsh.py crtsh
chmod +x crtsh
sudo cp crtsh /usr/bin/
echo "${BLUE}done${RESET}"

echo "${BLUE}Installing dnsvalidator${RESET}"
cd ~/tools && git clone https://github.com/vortexau/dnsvalidator.git
sudo pip3 install setuptools -y
cd dnsvalidator && sudo python3 setup.py install
echo "${BLUE}done${RESET}"

echo "${BLUE}Installing shuffledns${RESET}"
GO111MODULE=on go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
echo "${BLUE}done${RESET}"


echo "${BLUE} Installing massdns ${RESET}"
cd ~/tools
git clone https://github.com/blechschmidt/massdns.git 
cd ~/tools/massdns
make && sudo make install
echo "${BLUE} done ${RESET}"
echo ""

echo "${BLUE}Installing SD-GOO ${RESET}"
cd ~/tools
git clone https://github.com/darklotuskdb/sd-goo.git
cd sd-goo && chmod +x *.sh 
echo -e "USAGE : ./sd-goo.sh google.com | sort -u"
echo "${BLUE} done ${RESET}"
echo ""

echo "${BLUE}Installing CENT tool${RESET}"
cd ~/tools
GO111MODULE=on go install -v github.com/xm1k3/cent@latest
cent init
cent update
cent -p ~/cent-nuclei-templates -k
echo "${BLUE}done${RESET}"

echo "${BLUE}Installing ${RED}gobuster ${RESET}"
GO111MODULE=on go install github.com/OJ/gobuster/v3@latest
echo "${BLUE}done${RESET}"

echo "${BLUE}Installing ${RED}Waybackurls${RESET}"
GO111MODULE=on go install github.com/tomnomnom/hacks/waybackurls@latest
echo "${BLUE}done${RESET}"

echo "${BLUE}Installing ${RED}NAABU${RESET}"
sudo apt install -y libpcap-dev
GO111MODULE=on go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
echo "${BLUE}done${RESET}"

echo "${BLUE}Installing ${RED}Katana${RESET}"
GO111MODULE=on go install github.com/projectdiscovery/katana/cmd/katana@latest
echo "${BLUE}done${RESET}"

echo "${BLUE}Installing Aquatone${RESET}"
cd ~/tools
git clone https://github.com/scheib/chromium-latest-linux.git
cd chromium-latest-linux && chmod +x update-and-run.sh && ./update-and-run.sh
wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip ~/tools
unzip aquatone_linux_amd64_1*.zip 
rm LICENSE.txt README.md
sudo mv aquatone /usr/bin/
echo "${BLUE}Done${RESET}"

echo "${BLUE}Getting Fresh resolvers from trickest/resolvers${RESET}"
mkdir -p ~/tools/Wordlists/ && cd ~/tools/Wordlists
wget https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt -q -P ~/tools/Wordlists/
echo "${BLUE}Done${RESET}"

echo "${BLUE}Getting Fresh wordlists from trickest/wordlists${RESET}"
wget https://raw.githubusercontent.com/trickest/wordlists/main/inventory/subdomains.txt -q -P ~/tools/Wordlists/
#git clone https://github.com/trickest/wordlists.git ~/tools/Wordlists/trickest
echo "${BLUE}Done${RESET}"

echo -e "\n\n${GREEN}All Set${RESET}"

###

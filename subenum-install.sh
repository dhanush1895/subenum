#!/bin/bash

####This tools are going to be installed in your system!!!!
# GO 
# anew
# assetfinder
# github-sub
# gitlab-sub
# amass
# pdtm -all
# findomain
# sublister
# knockknock or knock2
# ffuf
# subbrute
# knockpy
# filter-resolved
# jsubfinder
# crtpy
# dnsvalidator
# massdns
# sd-goo
# gobuster
# waybackurls
# aquatone
# gf tool & gf patterns
# unfurl
# qsreplace
# meg
# cent
# trickest resolvers & subs-wordlist

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
BLINK=$(tput blink)
RESET=$(tput sgr0)

#echo -e "\n\n${RED}Specify the VERSION of AMASS:\n\nEx:3.21.2 \nYou can check from -> 'https://github.com/OWASP/Amass/releases'\nAMASS_VERSION>>>\c" && read AMASS_VERSION 
echo -e "\n${RED}Specify the VERSION of GO:\n\nEx:1.20.6 \nYou can check from -> 'https://go.dev/doc/install'\nGOVERSION>>>\c${RESET}" && read GOVERSION

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
sudo apt install -y libpcap-dev
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

            # if [ -d "$GOROOT" ]; then
            #     echo "The Go install directory ($GOROOT) already exists. Exiting."
            #     exit 1
            #     # break;;
            # fi

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
    #break
    echo""
    echo "${BLUE} Done Install Golang ${RESET}"
    echo ""
    echo ""
    #sar 1 1 >/dev/null
}

GOINSTALL


echo "${BLUE} Installing anew ${RESET}"
go install github.com/tomnomnom/anew@latest
echo "${BLUE}done${RESET}"
echo ""

echo "${BLUE} Installing assetfinder${RESET}"
go install github.com/tomnomnom/assetfinder@latest
echo "${BLUE} done${RESET}"
echo ""

echo "${BLUE}Installing Go version of github-subdomains scanning${RESET}"
go install github.com/gwen001/github-subdomains@latest
echo "${BLUE}done${RESET}"

echo "${BLUE}Installing Gitlab-subdomains scanning${RESET}"
go install github.com/gwen001/gitlab-subdomains@latest
echo "${BLUE}done${RESET}"

# AMASSDOWNLOAD(){
#     OS="$(uname -s)"
#     ARCH="$(uname -m)"

#     case $OS in
#         "Linux")
#             case $ARCH in
#             "x86_64")
#                 ARCH=amd64
#                 ;;
#             "aarch64")
#                 ARCH=arm64
#                 ;;
#             "armv6" | "armv7l")
#                 ARCH=armv6l
#                 ;;
#             "armv8")
#                 ARCH=arm64
#                 ;;
#             .*386.*)
#                 ARCH=386
#                 ;;
#             esac
#             PLATFORM="linux_$ARCH"
#         ;;
#         "Darwin")
#               case $ARCH in
#               "x86_64")
#                   ARCH=amd64
#                   ;;
#               "arm64")
#                   ARCH=arm64
#                   ;;
#               esac
#             PLATFORM="darwin_$ARCH"
#         ;;
#     esac

#     echo "${BLUE} Installing amass${RESET}"
#     cd ~ && echo -e "Downloading amass version ${AMASS_VERSION} ..." && wget -q https://github.com/OWASP/Amass/releases/download/v${AMASS_VERSION}/amass_${PLATFORM}.zip && unzip amass_${PLATFORM}.zip
#     sudo mv amass_linux_amd64/amass /usr/bin/
#     cd ~ && rm -rf amass_${PLATFORM}* amass_${PLATFORM}.zip*
#     mkdir -p ~/.config/amass && wget -q https://raw.githubusercontent.com/OWASP/Amass/master/examples/config.ini -P ~/.config/amass
#     echo "${BLUE}Amass done${RESET}"
#     echo ""

# }

# AMASSDOWNLOAD

cd ~/tools

echo "${BLUE} Installing amass${RESET}"
go install github.com/owasp-amass/amass/v4/...@master
mkdir -p ~/.config/amass && wget -q https://raw.githubusercontent.com/OWASP/Amass/master/examples/config.ini -P ~/.config/amass
cd ~/tools
echo "${BLUE}Amass done${RESET}"
echo ""


echo "${BLUE}Installing All Project Discovery Tools${RESET}"
go install github.com/projectdiscovery/pdtm/cmd/pdtm@latest
pdtm -ia
echo "${BLUE}Done${RESET}"

echo "${BLUE} Installing findomain${RESET}"
cd ~/tools
curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux.zip
unzip findomain-linux.zip
sudo chmod +x findomain
sudo mv findomain /usr/bin/findomain
rm findomain-linux.zip
echo "${RED} Add your keys in the config file"
echo "${BLUE}done${RESET}"
echo ""
sar 1 1 >/dev/null


echo "${BLUE} Installing Sublister ${RESET}"
cd ~/tools
git clone https://github.com/aboul3la/Sublist3r.git
cd ~/tools/Sublist3r
sudo pip3 install -r requirements.txt
sudo apt-get install python3-requests -y
echo "${BLUE} done ${RESET}"
echo ""

echo "${BLUE} Installing knock2 or knockknock${RESET}"
go install github.com/harleo/knockknock@latest
echo "${BLUE} done${RESET}"
echo ""


echo "${BLUE} Installing ffuf${RESET}"
go install github.com/ffuf/ffuf@latest
echo "${BLUE} done${RESET}"
echo ""

echo "${BLUE}Installing subbrute${RESET}"
cd ~/tools
git clone https://github.com/TheRook/subbrute.git
echo "${BLUE}done${RESET}"

echo "${BLUE} Downloading knockpy${RESET}"
cd ~/tools/ && git clone https://github.com/guelfoweb/knock.git
cd knock
sudo apt install python3-virtualenv -y
sudo python3 setup.py install
#virtualenv --python=python3 venv3
#source venv3/bin/activate
pip3 install -r requirements.txt
echo "${BLUE} done${RESET}"
echo ""


echo "${BLUE} Installing filter-resolved${RESET}"
go install github.com/tomnomnom/hacks/filter-resolved@install
echo "${BLUE} done${RESET}"
echo ""

echo "${BLUE}Installing JSUBFINDER${RESET}"
go install github.com/hiddengearz/jsubfinder@latest
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
sudo pip3 install setuptools
cd dnsvalidator && sudo python3 setup.py install
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

echo "${BLUE}Installing ${RED}gobuster ${RESET}"
go install github.com/OJ/gobuster/v3@latest
echo "${BLUE}done${RESET}"

echo "${BLUE}Installing ${RED}Waybackurls${RESET}"
go install github.com/tomnomnom/hacks/waybackurls@latest
echo "${BLUE}done${RESET}"

echo "${BLUE}Installing ${RED}fuzzing-templates${RESET}"
cd ~/
git clone https://github.com/projectdiscovery/fuzzing-templates.git
echo "${BLUE}done${RESET}"

echo "${BLUE}Installing Aquatone${RESET}"
cd ~/tools
git clone https://github.com/scheib/chromium-latest-linux.git
cd chromium-latest-linux && chmod +x update-and-run.sh && ./update-and-run.sh
wget https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip ~/tools
unzip aquatone_linux_amd64_1*.zip 
rm LICENSE.txt README.md
sudo mv -f aquatone /usr/bin/
echo "${BLUE}Done${RESET}"


echo "${BLUE}Installing tomnomnom tools${RESET}"
cd ~/tools
echo "Installing GF tool and GF patterns"
go install github.com/tomnomnom/gf@latest
echo 'source $GOPATH/src/github.com/tomnomnom/gf/gf-completion.bash' >> ~/.bashrc
echo 'source $GOPATH/src/github.com/tomnomnom/gf/gf-completion.bash' >> ~/.bash_profile
cp -r $GOPATH/src/github.com/tomnomnom/gf/examples ~/.gf
cd ~/tools && git clone https://github.com/emadshanab/Gf-Patterns-Collection.git 
cd ~/tools/Gf-Patterns-Collection
chmod +x set-all.sh
./set-all.sh 
echo "${BLUE}Done${RESET}"

echo "${BLUE}Installing unfurl${RESET}"
go install github.com/tomnomnom/unfurl@latest
echo "${BLUE}Done${RESET}"

echo "${BLUE}Installing qsreplace${RESET}"
go install github.com/tomnomnom/qsreplace@latest
echo "${BLUE}Done${RESET}"

echo "${BLUE}Installing meg${RESET}"
go install github.com/tomnomnom/meg@latest
echo "${BLUE}Done${RESET}"
echo "${BLUE}Few Tomnomnom tools were installed, feel free to add more in the script!!!${RESET}"

echo "${BLUE}Installing CENT tool${RESET}"
cd ~/tools
go install github.com/xm1k3/cent@latest
cent init
cent update
cent -p ~/cent-nuclei-templates -k
echo "${BLUE}done${RESET}"

echo "${BLUE}Installing regulator${RESET}"
cd ~/tools
git clone https://github.com/cramppet/regulator.git
cd ~/tools/regulator && pip3 install -r requirements.txt
echo "${BLUE}Done${RESET}"

echo "${BLUE}Installing Gau & GauPlus${RESET}"
go install github.com/lc/gau/v2/cmd/gau@latest
go install github.com/bp0lr/gauplus@latest
echo "${BLUE}Done${RESET}"

echo "${BLUE}Getting Fresh resolvers from trickest-resolvers${RESET}"
mkdir -p ~/tools/Wordlists/ && cd ~/tools/Wordlists
wget https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt -q -P ~/tools/Wordlists/
echo "${BLUE}Done${RESET}"

echo "${BLUE}Getting Fresh wordlists from trickest-wordlists${RESET}"
wget https://raw.githubusercontent.com/trickest/wordlists/main/inventory/subdomains.txt -q -P ~/tools/Wordlists/
#git clone https://github.com/trickest/wordlists.git ~/tools/Wordlists/trickest
echo "${BLUE}Done${RESET}"

echo "${RED} Make sure you set API keys in ~/.config/amass & ~/.config/subfinder & ~/.config/notify ${RESET}"
echo -e "\n\n${GREEN}All Set${RESET}"

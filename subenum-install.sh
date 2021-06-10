
# !/bin/bash/

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
#filter-resolved
#httpx
#nuclei 



RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

AMASS_VERSION=3.12.3

sudo apt-get -y update
sudo apt-get -y upgrade

sudo add-apt-repository -y ppa:apt-fast/stable < /dev/null
sudo echo debconf apt-fast/maxdownloads string 16 | debconf-set-selections
sudo echo debconf apt-fast/dlflag boolean true | debconf-set-selections
sudo echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections
sudo apt install -y apt-fast

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
pip3 install jsbeautifier
sudo apt install figlet

echo ""
echo ""
sar 1 1 >/dev/null

mkdir ~/tools
cd ~/tools

echo "${GREEN} [+] Installing Golang ${RESET}"
if [ ! -f /usr/bin/go ];then
    cd ~
    wget -q -O - https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh | bash
	export GOROOT=$HOME/.go
	export PATH=$GOROOT/bin:$PATH
	export GOPATH=$HOME/go
    echo 'export GOROOT=$HOME/.go' >> ~/.bash_profile
	
	echo 'export GOPATH=$HOME/go'	>> ~/.bash_profile			
	echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bash_profile
    source ~/.bash_profile 
else 
    echo "${BLUE} Golang is already installed${RESET}"
fi
    break
echo""
echo "${BLUE} Done Install Golang ${RESET}"
echo ""
echo ""
sar 1 1 >/dev/null

echo "${BLUE} installing notify & intercept ${RESET}"
GO111MODULE=on go get -v github.com/projectdiscovery/notify/cmd/notify
GO111MODULE=on go get -v github.com/projectdiscovery/notify/cmd/intercept
echo "${BLUE} done${RESET}"
echo ""


echo "${BLUE} installing assetfinder${RESET}"
go get -u github.com/tomnomnom/assetfinder
echo "${BLUE} done${RESET}"
echo ""


echo "${BLUE} installing amass${RESET}"
cd ~ && echo -e "Downloading amass version ${AMASS_VERSION} ..." && wget -q https://github.com/OWASP/Amass/releases/download/v${AMASS_VERSION}/amass_linux_amd64.zip && unzip amass_linux_amd64.zip
sudo mv amass_linux_amd64/amass /usr/bin/
cd ~ && rm -rf amass_linux_amd64* amass_linux_amd64.zip*
echo "${BLUE} done${RESET}"
echo ""


echo "${BLUE} installing subfinder${RESET}"
GO111MODULE=on go get -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder
echo "${BLUE} done${RESET}"
echo ""

echo "${BLUE} installing findomain${RESET}"
cd ~/tools
wget https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux
sudo chmod +x findomain-linux
sudo mv findomain-linux /usr/bin/findomain
echo "${BLUE} Add your keys in the config file"
echo "${BLUE} done${RESET}"
echo ""
sar 1 1 >/dev/null


echo "${BLUE} installing Sublister ${RESET}"
git clone https://github.com/aboul3la/Sublist3r.git
cd Sublist3r
sudo pip3 install -r requirements.txt
echo "${BLUE} done ${RESET}"
echo ""

echo "${BLUE} installing knock2${RESET}"
go get -u github.com/harleo/knockknock
echo "${BLUE} done${RESET}"
echo ""


echo "${BLUE} installing ffuf${RESET}"
go get -u github.com/ffuf/ffuf
echo "${BLUE} done${RESET}"
echo ""


echo "${BLUE} downloading knockpy${RESET}"
cd ~/tools/ && git clone https://github.com/guelfoweb/knock.git
cd knock
sudo apt install python3-virtualenv
sudo python3 setup.py install
virtualenv --python=python3 venv3
source venv3/bin/activate
pip3 install -r requirements.txt

echo "${BLUE} done${RESET}"
echo ""


echo "${BLUE} installing filter-resolved${RESET}"
go get github.com/tomnomnom/hacks/filter-resolved
echo "${BLUE} done${RESET}"
echo ""


echo "${BLUE} installing httpx${RESET}"
GO111MODULE=on go get -v github.com/projectdiscovery/httpx/cmd/httpx
echo "${BLUE} done${RESET}"
echo ""

echo "${BLUE} installing nuclei${RESET}"
GO111MODULE=on go get -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei
echo "${BLUE} done${RESET}"
echo ""

echo "${BLUE}Installing JSUBFINDER${RESET}"
go get -u github.com/hiddengearz/jsubfinder
wget https://raw.githubusercontent.com/hiddengearz/jsubfinder/master/.jsf_signatures.yaml && mv .jsf_signatures.yaml ~/.jsf_signatures.yaml
echo "${BLUE}done${RESET}"

echo "${BLUE}Installing crtpy"
cd ~/tools && git clone https://github.com/YashGoti/crtsh.py.git
cd crtsh.py
mv crtsh.py crtsh
chmod +x crtsh
sudo cp crtsh /usr/bin/
echo "${BLUE}done${RESET}"

echo "All Set"
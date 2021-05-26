#!/bin/bash
source ~/.bash_profile
echo "Before Running Script Replace some values in script at starting"

##########################################################################
#Change this home directory to Your's
HOME="/home/dhanush"

# Script to initiate the alias in bash file
shopt -s expand_aliases
alias subls="python3 ${HOME}/tools/Sublist3r/sublist3r.py"
alias github-subd="python3 ${HOME}/scripts/github-subdomains.py"
alias subbrute="python3 ${HOME}/tools/subbrute/subbrute.py"

#Tokens 
findomain_virustotal_token="XXXX" 
findomain_securitytrails_token="XXXX"
findomain_fb_token="XXXX"
gitT="XXXX"
##########################################################################

#Terminal Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

#Domain name input-string
echo "${RED}Enter domain name:${RESET}" && read host

#Folder Creation $results
echo "${BLUE}By Default 'results' dir will be created in${RESET} ${RED}${HOME}${RESET}"
if [[ -d ~/results ]]
then
        cd ~/results
        if [[ -d ~/results/$host ]]
        then
        	echo "${RED}${host} ${BLUE}Folder Already Exits${RESET}"
        else
        	cd ~/results && mkdir $host
        fi
else
        mkdir ~/results && cd ~/results
        if [[ -d ~/results/$host ]]
        then
        	echo "${RED}${host} Folder Already Exits${RESET}"
        else
        	mkdir ~/results/$host
        fi
fi

cd ~/results/$host

#Time Elapsed In Seconds CalculatioN---START
start=$(date +%s)

#V1.0
#amass
amass enum -d $host -config ~/.config/amass/config.ini -o domains_$host
echo "${RED}Amass Done${RESET}"

#assetfinder
assetfinder -subs-only $host | tee -a domains_$host
echo "${RED}Assetfinder Done${RESET}"

#subfinder
subfinder -d $host -all -silent | tee -a domains_$host
echo "${RED}Subfinder Done${RESET}"

#findomain
findomain -t $host -q | tee -a domains_$host
echo "${RED}Findomain Done${RESET}"

#Sublist3r
subls -d $host -o subls_$host.txt ; cat subls_$host.txt | tee -a domains_$host ; rm subls_$host.txt
echo "${RED}Sublist3r Done${RESET}"

#github-subdomains-search
github-subd -t $gitT -d $host -e | tee github_domains_${host} ; cat github_domains_${host} | tee -a domains_$host
echo "${RED}Github-subdomains-search Done${RESET}"

#filtering the domains
echo "${BLUE}Filtering Domains${RESET}"
sort -u domains_$host -o domains_$host
#cat domains_$host | filter-resolved | tee -a $host_domains.txt (optional)

# httpx live
echo "${RED}Filtering out live Domains${RESET}"
cat domains_$host | httpx -silent -threads 500 -o live_$host.txt
echo ""
echo ""

#Time Elapsed In Seconds Calculation---END 
end=$(date +%s)
runtime=$(python -c "print '%u:%02u' % ((${end} - ${start})/60, (${end} - ${start})%60)")
echo "${GREEN}Runtime/Duration: ${RED}$runtime${RESET} ${GREEN}(minutes:seconds)${RESET}"
echo ""

#Number of Domains & Sub-Domains
echo "${GREEN}The Total No of Sub-Domains Gathered:${RESET}${RED}$(cat domains_$host | wc -l)${RESET}"
echo ""

#Number of Live Sub-Domains
echo "${GREEN}The Total No of Live Sub-Domains:${RESET}${RED}$(cat live_$host.txt | wc -l)$RESET"
echo ""

echo "${GREEN}Done Enumerating All Sub-Domains for${RESET} ${RED}${host}${RESET}"
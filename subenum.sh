#!/bin/bash

source ~/.bash_profile

#Change this home directory to Your's
HOME="/home/dhanush"

# Script to initiate the alias in bash file
shopt -s expand_aliases
alias subls="sudo python3 ${HOME}/tools/Sublist3r/sublist3r.py"
alias github-subd="sudo python3 ${HOME}/scripts/github-subdomains.py"
alias subbrute="python3 ${HOME}/tools/subbrute/subbrute.py"

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
#amass enum -active -d $host -config ~/.config/amass/config.ini -o amassA_$host
#amass enum -passive -d $host -config ~/.config/amass/config.ini -o amassP_$host
#amass enum --active
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
subls -d $host -o subls_$host.txt && cat subls_$host.txt | tee -a domains_$host && rm subls_$host.txt
echo "${RED}Sublist3r Done${RESET}"

#github-subdomains-search
github-subd -t 224b061e1ac533e90728a1b5b800c932277d0ca7 -d $host -e | tee github_domains_${host} ; cat github_domains_${host} | tee -a domains_$host
#Search subdomains using github and httpx
#To search subdomains, httpx filter hosts by up status-code response (200)
echo "${GREEN}Do you want to get ${RED}title of github-subdomains?${RESET}"
select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
    case $yn in
        Yes ) echo "${GREEN}Doing github & httpx title${RESET}"; cat github_domains_${host} | httpx --title -o ~/results/github_httpx_$host_res.txt; echo "${BLUE}github_httpx_${host} done${RESET}"; break;;
        No ) exit;;
    esac
done
echo "${RED}Github-subdomains-search Done${RESET}"

# V1.1
#knockknock searchs/collects for internal website related URL's from one -target / -domain
cd ~/results/$host
knockknock -n $host -p
mv domains.txt related_$host_domains.txt
cat related_$host_domains.txt | grep '${host}' | tee -a domains_$host
echo "${RED}knockknock ${host} related_domains Done${RESET}"

#Using jhaddix All.txt to fuzz sub-domains
echo "${GREEN}Do you wish to do Brute force subdomains using ${RED}'FUFF & All.txt by jhaddix'${GREEN}?${RESET}"
select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
    case $yn in
        Yes ) echo "${GREEN}This may take a while approx.(15-30 minutes)${RESET}"; ffuf -t 100 -w ~/tools/Wordlists/subs_all.txt -u "https://FUZZ.${host}/" -v | grep "| URL |" | awk '{print $4}' | tee -a domains_$host; break;;
        No ) exit;;
    esac
done
echo "${RED}FUZZ Done${RESET}"

#Search subdomains in cert.sh
curl -s "https://crt.sh/?q=%25.${host}&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee -a domains_$host
echo "${RED}CRT.SH Sub-Domains scrapping Done${RESET}"

#Using Search Bufferover resolving domain
curl -s "https://dns.bufferover.run/dns?q=.${host}" | jq -r .FDNS_A[] | sed -s 's/,/\n/g' | tee -a domains_$host
echo "${RED}DNS.Bufferover.run scrapping Done${RESET}"

#Subbrute 
echo "${GREEN}Do you wish to do Brute force subdomains using ${RED}'Subbrute'${GREEN}?${RESET}"
select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
    case $yn in
        Yes ) echo "${GREEN}This may take a while approx.(15-30 minutes)${RESET}"; subbrute $host -p -r ~/tools/subbrute/resolvers.txt | sed -r 's/./\n/g' | grep "*${host}*" | tee -a domains_$host; break;;
        No ) exit;;
    esac
done

#CHAOS Project Discovery without API Key 
echo "${GREEN}Do you want to download subdomains using ${RED}'CHAOS'${RESET} ${GREEN}if available!?${RESET}"
select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
    case $yn in
        Yes ) echo "${BLUE}It's Better to do manual Download ${host} zip file${RESET}"; wget "http://chaos-data.projectdiscovery.io/index.json" -O ~/results/chaos-data.json; cat chaos-data.json | grep "URL" | sed 's/"URL": "//;s/",//' | grep "${host}"; break;;
        No ) exit;;
    esac
done


# knockpy v5.1.0
knockpy $host -o ~/results/$host
echo "Just Open another terminal and Search & Enter the json file name located @results/${host} here ( with .json):" && read jsonfile
knockpy --csv ~/results/$jsonfile
echo "Just Open another terminal and Search & Enter the csv file name here ( with .csv):" && read csvfile
cat ~/results/$csvfile | sed -s 's/;/ /g' | awk '{print $2}' | tee -a domains_$host

#filtering the domains
echo "${BLUE}Filtering Domains${RESET}"
sort -u domains_$host -o domains_$host
#cat domains_$host | filter-resolved | tee -a $host_domains.txt

# httpx live
echo "${RED}Filtering out live Domains${RESET}"
cat domains_$host | httpx -silent -threads 500 | tee live_$host.txt
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


#Search Subdomain using Gospider #gathers other domains present in $host site also
#gospider -d 0 -s "https://${host}" -c 5 -t 100 -d 5 --blacklist jpg,jpeg,gif,css,tif,tiff,png,ttf,woff,woff2,ico,pdf,svg,txt | grep -Eo '(http|https)://[^/"]+' | anew

#Search subdomains using jldc 
# Not working properly 
#curl -s "https://jldc.me/anubis/subdomains/${host}" | grep -Po "((http|https):\/\/)?(([\w.-])\.([\w])\.([A-z]))\w+" | anew

#Using Altdns on domains_${host} list to find permuted possible subdomains
#altdns -i 
# altdns word list 
# https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/shubs-subdomains.txt

#Extract .js Subdomains Using haktrails
#echo "${host}" | haktrails subdomains | httpx -silent | getJS --complete | anew JS
#echo "${host}" | haktrails subdomains | httpx -silent | getJS --complete | tojson | anew JS1

#Search .json subdomain using assetfinder & waybackurls
#assetfinder $host | waybackurls | grep -E "\.json(?:onp?)?$" | anew
 #also implent for domains_$host above
 #assetfinder domains_$host | waybackurls | grep -E "\.json(?:onp?)?$" | anew

#SonarDNS extract subdomains
#wget https://opendata.rapid7.com/sonar.fdns_v2/2021-02-26-1614298023-fdns_a.json.gz ; gunzip 2021-02-26-1614298023-fdns_a.json.gz ; cat 2021-02-26-1614298023-fdns_a.json | grep ".DOMAIN.com" | jq .name | tr '" " "' " / " | tee -a sonar

#recon automation simple. OFJAAAH.sh
#amass enum -d $1 -o amass1 ; chaos -d $1 -o chaos1 -silent ; assetfinder $1 >> assetfinder1 ; subfinder -d $1 -o subfinder1 ; findomain -t $1 -q -u findomain1 ;python3 /root/PENTESTER/github-search/github-subdomains.py -t YOURTOKEN -d $1 >> github ; cat assetfinder1 subfinder1 chaos1 amass1 findomain1 subfinder1 github >> hosts ; subfinder -dL hosts -o full -timeout 10 -silent ; httpx -l hosts -silent -threads 9000 -timeout 30 | anew domains ; rm -rf amass1 chaos1 assetfinder1 subfinder1 findomain1  github

#Using recon.dev and gospider crawler subdomains 
#we need recon.dev api
#curl "https://recon.dev/api/search?key=apiKEY&domain=paypal.com" |jq -r '.[].rawDomains[]' | sed 's/ //g' | anew |httpx -silent | xargs -P3 -I@ gospider -d 0 -s @ -c 5 -t 100 -d 5 --blacklist jpg,jpeg,gif,css,tif,tiff,png,ttf,woff,woff2,ico,pdf,svg,txt | grep -Eo '(http|https)://[^/"]+' | anew

#PSQL - search subdomain using cert.sh
#Make use of pgsql cli of crt.sh, replace all comma to new lines and grep just twitch text domains with anew to confirm unique outputs
#psql -A -F; -f querycrt -h http://crt.sh -p 5432 -U guest certwatch 2>/dev/null | tr ', ' '\n' | grep twitch | anew

#Find subdomains and Secrets with jsubfinder
#original command --- cat subdomsains.txt | httpx --silent | jsubfinder -s
#cat domains_${host} | httpx --silent | jsubfinder -s
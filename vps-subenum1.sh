#!/bin/bash
#source ~/.bash_profile

#Change this home directory to Your's
HOME="/home/ubuntu/"

# Script to initiate the alias in bash file
shopt -s expand_aliases
alias subls="python3 ${HOME}/tools/Sublist3r/sublist3r.py"
alias github-subd="python3 ${HOME}/subenum/github-subdomains.py"
alias subbrute="python3 ${HOME}/tools/Sublist3r/subbrute/subbrute.py"

##Subdomain bruteforcer list 
Wordlist="${HOME}/all_1cr_28L_subdomains.txt"
AMSCON="${HOME}/subenum/config.ini"
SUBFCON="${HOME}/subenum/config.yaml"
RESOLVWORDLIST="${HOME}/resolvers-valid-all.txt"
#Tokens 
findomain_virustotal_token="00a52c2630d8f66be0cc67db14cff05369befbb85c677f97fb9d153ce348c9a5" 
findomain_securitytrails_token="XkTqjWdzWaLB7mDYbEJo2c22xqYMYNhZ"
findomain_fb_token="106063464919303|_dRMJvP6RMXtSx2mWkdAEMYJMMk"
gitT="224b061e1ac533e90728a1b5b800c932277d0ca7"
knockpyvirusapi="00a52c2630d8f66be0cc67db14cff05369befbb85c677f97fb9d153ce348c9a5"
SUBSNOTIFYURL="https://discord.com/api/webhooks/850956102756597831/p5wdk4lI0r3cmLIcaaiC_-7x6P8DBhx3vXIpQU3eXGM7UEVkfyQnnX8o6NNm374yoaej"

#First implement amass & subfinder config 

#Terminal Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

#Banner
Banner(){
    figlet Subenum
}
Banner
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
echo "Doing sub-domain's scan for ${host}" | notify -silent -discord -discord-webhook-url "${SUBSNOTIFYURL}"

#V1.0

#getting resolver's valid one's
DNSresolve(){
echo "${BLUE}Getting valid resolver's from public-dns.info, This may take some time${RESET}" 
dnsvalidator -tL https://public-dns.info/nameservers.txt --silent | tee -a $RESOLVWORDLIST
clear
}
if [[ -f "$RESOLVWORDLIST" ]]
then
        echo "${RED}Resolver's ${GREEN}file already existed${RESET}"
else
        DNSresolve
fi
#amass
amassActive(){
    amass enum -active -d $host -o amassA_$host -silent -brute
}
amassPassive1(){
    amass enum -passive -d $host -o amassP_$host -silent 
}
amass_A_P_comb(){
    cat amassA_$host amassP_$host | tee -a domains_$host
    rm -rf amassA_$host amassP_$host
}
amassPassive2(){
    amass enum -passive -d $host -o amassP1_$host -silent
    cat amassP1_$host | tee -a domains_$host
    rm -rf amassP1_$host
}
echo "Do you want to enum domains using active(Bruteforce Method) & passive method ?, If No by Default it will do passive scan!, If Nothing selected within 5 secs it will do Both!"
TMOUT=5
select yn in "Yes'A&P'" "No'P'";do
    case $yn in
        Yes ) echo "Enumerating Domains using Active & Passive"; amassActive; amassPassive1; amass_A_P_comb; break;;
        No ) echo "Enumerating Domains using Passive resources"; amassPassive2; break;;
    esac
done

if [ -z "$yn" ] ; then 
echo "Doing scan automatically amass"
amassActive
amassPassive1
amass_A_P_comb
fi
clear
echo "${RED}Amass Done${RESET}"
echo ""
#assetfinder
echo "Doing assetfinder scan ..."
assetfinder -subs-only $host | tee -a domains_$host
clear
echo "${RED}Assetfinder Done${RESET}"

#subfinder
echo "Doing subfinder scan ..."
subfinder -d $host -all -silent -t 20 -config $SUBFCON | tee -a domains_$host
clear
echo "${RED}Subfinder Done${RESET}"

#findomain
echo "Doing findomain scan ..."
findomain -t $host -q | tee -a domains_$host
clear
echo "${RED}Findomain Done${RESET}"

#Sublist3r
echo "Doing sublist3r scan ..."
subls -d $host -o subls_$host.txt ; cat subls_$host.txt | tee -a domains_$host
rm -rf subls_$host.txt
clear
echo "${RED}Sublist3r Done${RESET}"

#github-subdomains-search
echo "Doing github-subdomains scan ..."
github-subd -t $gitT -d $host -e | tee -a domains_$host
clear
echo "${RED}Github-subdomains-search Done${RESET}"

# V1.1

#knockknock searchs/collects for internal website related URL's from one -target / -domain
echo "Doing knockknock scan ..."
knockknock -n $host -p
mv domains.txt related_$host_domains.txt
cat related_$host_domains.txt | grep '${host}' | tee -a domains_$host
rm -rf related_$host_domains.txt
clear
echo "${RED}knockknock ${host} related_domains Done${RESET}"

#Search subdomains in cert.sh
echo "${RED}Doing crt.sh scan ...${RESET}"
curl -s "https://crt.sh/?q=%25.${host}&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee -a domains_$host
#crtpy uses recurisive func
crtsh -d $host -r | tee -a domains_$host
clear
echo "${RED}CRT.SH Sub-Domains scrapping Done${RESET}"

#Using Search Bufferover resolving domain
echo "${RED}Doing bufferover scan ...${RESET}"
curl -s "https://dns.bufferover.run/dns?q=.${host}" | jq -r .FDNS_A[] | sed -s 's/,/\n/g' | tee -a domains_$host
clear
echo "${RED}DNS.Bufferover.run scrapping Done${RESET}"


#Web.archive.org subdomains scrapping
echo "${RED}Doing web.archive scan ...${RESET}"
curl -sk "http://web.archive.org/cdx/search/cdx?url=*.${host}&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u | tee -a domains_$host
clear
echo "${RED}Web.archive.org subdomains scrapping Done${RESET}"

# knockpy v5.1.0
knockpytool(){
    knockpy --set apikey-virustotal=$knockpyvirusapi
    knockpy $host > knockpy_$host.txt
    cat knockpy_$host.txt | awk '{print $9}' | sort -u | grep "${host}" | tee -a domains_$host
    #cat knockpy_$host.txt | sed 's/ /\n/g' | sort -u | grep "${host}" | tee -a domains_$host
    #jq 'keys[]' | sed 's/"//g'
    #cat ~/results/$host/$csvfile | sed -s 's/;/ /g' | awk '{print $2}' | tee -a domains_$host
}
echo "${BLUE}Doing knockpy scan ...${RESET}"
knockpytool
clear
echo "${RED}knockpy Done${RESET}"

#sonarsearch using https://sonar.omnisint.io
echo "${BLUE}Doing sonar search ...${RESET}"
curl -s "https://sonar.omnisint.io/subdomains/${host}" | jq '.[]' | sed -s 's/"//g' | tee -a domains_$host
clear
echo "${RED}sonar search done${RESET}"

# #Using jhaddix All.txt to fuzz sub-domains
# fuzzDomain(){
#     echo "${GREEN}Doing fuzz scan ...${RESET}"
#     echo "${GREEN}This may take a while approx.(15-30 minutes), Based on Internet Speed${RESET}"; 
#     ffuf -w $Wordlist -u "https://FUZZ.${host}/" -v | grep "| URL |" | awk '{print $4}' | tee -a domains_$host
# }
# echo "${GREEN}Do you wish to do Brute force subdomains using ${RED}'FUFF & All.txt by jhaddix'${GREEN}?\nIf nothing selected within ${RED}5 secs${RESET} ${GREEN}it will do automatically!${RESET}"
# TMOUT=5
# select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
#     case $yn in
#         Yes ) fuzzDomain; break;;
#         No ) break;;
#     esac
# done
# if [ -z "$yn" ] ; then
#     fuzzDomain
# fi
# clear
# echo "${RED}FUZZing  Done${RESET}"

#Find subdomains with jsubfinder
echo "${BLUE}Doing jsubfinder ...${RESET}"
sort -u domains_$host -o domains_$host
jsubfinder -f domains_$host -crawl -o jsub_$host -g | tee -a domains_$host
clear
#Find Secrets with jsubfinder
# jsubfinder -f domains_$host -s -c 50 -crawl -o jsub_$host -g | tee -a domains_$host
echo "${RED}jsubfinder Done${RESET}"

#Before using shuffledns we have to get valid resolvers for dns resolving
echo "${RED}Doing shuffledns ...${RESET}"
shuffledns -d $host -list results/$host/domains_$host -silent -r $RESOLVWORDLIST -strict-wildcard -massdns ~/tools/massdns/bin/massdns -w $Wordlist -directory ~/ -o ~/results/$host/shuffldns_$host
cat shuffldns_$host | tee -a domains_$host
clear
echo "${RED}shuffldns Done${RESET}"

#filtering the domains
echo "${BLUE}Filtering & Resolving Domains${RESET}"
sort -u domains_$host -o domains_$host
cat domains_$host | filter-resolved -c 25 >> resolved_$host.txt
echo "Filtering & Resolving Done"
echo ""

# httpx live
echo "${RED}Filtering out live Domains${RESET}"
httpx -silent -l ~/results/$host/resolved_$host.txt -o ~/results/$host/live_$host.txt
echo "HTTPX Done"
echo ""

# #httpx title
# domainshttpxtitle(){
#     echo "${RED}Doing domainshttpxtitle scan ...${RESET} "
#     httpx -l domains_$host --title -o title_$host.txt -silent -follow-redirects -follow-host-redirects -random-agent -retries 3
# }

# echo -e "${GREEN}Do you want to get ${RED}title of subdomains?\nIf nothing selected within ${RED}5 secs${RESET} ${GREEN}it will do automatically!${RESET}"
# TMOUT=5
# select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
#     case $yn in
#         Yes ) domainshttpxtitle ; break;;
#         No ) break;;
#     esac
# done
# if [ -z "$yn" ] ; then 
#     domainshttpxtitle
# fi
# echo "${BLUE} Title of subdomains done${RESET}"


##################

nucleiScanSUBS(){
#updates nuclei templates
nuclei -ut -silent 

#nuclei scan for sub tkovr's
echo "Nuclei Sub-Domain Takeover scan for ${host}..." | notify -silent -discord -discord-webhook-url "${SUBSNOTIFYURL}"
nuclei -l live_$host.txt -t ~/nuclei-templates/takeovers/ -silent -o nuclei_substkovr_$host
cat nuclei_substkovr_$host | awk '{print $3,$4,$5,$6}' | notify -silent -discord -discord-webhook-url "${SUBSNOTIFYURL}"
}

echo -e "${GREEN}Do you want to ${RED} Scan for Subdomain Takeover's?\nIf nothing selected within ${RED}5 secs${RESET} ${GREEN}it will do automatically!${RESET}"
TMOUT=5
select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
    case $yn in
        Yes ) nucleiScanSUBS ; break;;
        No ) break;;
    esac
done
if [ -z "$yn" ] ; then 
    nucleiScanSUBS
fi

echo "${BLUE} Nuclei Sub-Domain Takeover Scan Done${RESET}" | notify -silent -discord -discord-webhook-url "${SUBSNOTIFYURL}"

clear

#Time Elapsed In Seconds Calculation---END 
end=$(date +%s)
runtime=$(python -c "print '%u:%02u' % ((${end} - ${start})/60, (${end} - ${start})%60)")
echo "${GREEN}Runtime: ${RED}$runtime${RESET} ${GREEN}(minutes:seconds)${RESET}" | notify -silent -discord -discord-webhook-url "${SUBSNOTIFYURL}"
echo ""

#Number of Sub-Domains
echo "${GREEN}The Total No of Sub-Domains Gathered:${RESET}${RED}$(cat domains_$host | wc -l)${RESET}" | notify -silent -discord -discord-webhook-url "${SUBSNOTIFYURL}"
echo ""

#Number of resolved domains
echo "${GREEN}The Total No of Resolved Domain's :${RESET}${RED}$(cat resolved_$host.txt | wc -l)${RESET}" | notify -silent -discord -discord-webhook-url "${SUBSNOTIFYURL}"
echo ""
#Number of Live Sub-Domains
echo "${GREEN}The Total No of Live Sub-Domains:${RESET}${RED}$(cat live_$host.txt | wc -l)$RESET" | notify -silent -discord -discord-webhook-url "${SUBSNOTIFYURL}"
echo ""
#Number of Sub-Domain Takeover's
echo "${GREEN}No of Sub-Domains Takeover possible :${RESET}${RED}$(cat nuclei_substkovr_$host | wc -l)${RESET}" | notify -silent -discord -discord-webhook-url "${SUBSNOTIFYURL}"
echo ""

#Done statement for $host
echo "${GREEN}Done Enumerating All Sub-Domains for${RESET} ${RED}${host}${RESET}" | notify -silent -discord -discord-webhook-url "${SUBSNOTIFYURL}"

#Visual Tree Graph
tree ~/results/$host/ -Q -v | notify -silent -discord -discord-webhook-url "${SUBSNOTIFYURL}"
echo " "
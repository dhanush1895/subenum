#!/bin/bash
#source ~/.bash_profile

#Change this home directory to Your's
HOME="/home/ubuntu/"

# Script to initiate the alias in bash file
shopt -s expand_aliases
alias subls="python3 ${HOME}/tools/Sublist3r/sublist3r.py"
alias github-subd="python3 ${HOME}/subenum/github-subdomains.py"
alias subbrute="python3 ${HOME}/tools/Sublist3r/subbrute/subbrute.py"

#First implement amass & subfinder config 

##Shortcut's
Wordlist="${HOME}/all_1cr_28L_subdomains.txt"
AMSCON="${HOME}/subenum/config.ini"
SUBFCON="${HOME}/subenum/config.yaml" #subfinder config will automatically look for .config default directory.
RESOLVWORDLIST="${HOME}/resolvers-valid-all.txt"

#Tokens 
findomain_virustotal_token="xxx" 
findomain_securitytrails_token="xxx"
findomain_fb_token="xxx"
gitT="xxx"
knockpyvirusapi="xxx"
SUBSNOTIFYURL="https://discord.com/api/webhooks/xxxx"

#########################################################################################
#Dont change anything beyond this Line, Expect the select case statement's 
#########################################################################################


#Terminal Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

#Banner
Banner(){
    figlet Subenum-all_tools
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
echo "Doing sub-domain's scan for ${host}" | notify -silent -discord-webhook-url "${SUBSNOTIFYURL}"


#V1.0

#amass
amassActive(){
    amass enum -active -d $host -config $AMSCON -o amassA_$host -silent -brute -w $Wordlist
    amass enum -active -d $host -w $Wordlist -o amassA1_$host -silent -brute
}
amassPassive1(){
    amass enum -passive -d $host -config $AMSCON -o amassP_$host -silent 
}
amass_A_P_comb(){
    cat amassA_$host amassA1_$host amassP_$host | tee -a domains_$host
    rm -rf amassA_$host amassA1_$host amassP_$host
}
amassPassive2(){
    amass enum -passive -d $host -config $AMSCON -o amassP1_$host -silent
    cat amassP1_$host | tee -a domains_$host
}
echo "Do you want to enum domains using active(Bruteforce Method) & passive method ?, If Nothing selected within 5 secs it will do the Uncommented statement in script!"
TMOUT=2
select yn in "Yes'A&P'" "No'P'";do
	case $yn in
		Yes ) echo "Enumerating Domains using Active & Passive"; amassActive; amassPassive1; amass_A_P_comb; break;;
		No ) echo "Enumerating Domains using Passive resources"; amassPassive2; break;;
	esac
done

if [ -z "$yn" ] ; then 
clear
echo "Doing scan automatically amass"
#amassActive
#amassPassive1
#amass_A_P_comb
amassPassive2
fi

echo "${RED}Amass Done${RESET}"

#assetfinder
echo "Doing assetfinder scan ..."
assetfinder -subs-only $host | tee -a domains_$host
echo "${RED}Assetfinder Done${RESET}"

#subfinder
echo "Doing subfinder scan ..."
subfinder -d $host -all -silent -config $SUBFCON | tee -a domains_$host
echo "${RED}Subfinder Done${RESET}"

#findomain
echo "Doing findomain scan ..."
findomain -t $host -q | tee -a domains_$host
echo "${RED}Findomain Done${RESET}"

#Sublist3r
echo "Doing sublist3r scan ..."
subls -d $host -o subls_$host.txt ; cat subls_$host.txt | tee -a domains_$host && rm -rf subls_$host.txt
echo "${RED}Sublist3r Done${RESET}"

#github-subdomains-search
echo "Doing github-subdomains scan ..."
github-subd -t $gitT -d $host -e | tee -a domains_$host
echo "${RED}Github-subdomains-search Done${RESET}"

# V1.1

#knockknock searchs/collects for internal website related URL's from one -target / -domain
cd ~/results/$host
echo "Doing knockknock scan ..."
knockknock -n $host -p
mv domains.txt related_$host_domains.txt
cat related_$host_domains.txt | grep '${host}' | tee -a domains_$host
rm -rf related_$host_domains.txt
echo "${RED}knockknock ${host} related_domains Done${RESET}"

#Search subdomains in cert.sh
echo "${RED}Doing crt.sh scan ...${RESET}"
curl -s "https://crt.sh/?q=%25.${host}&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee -a domains_$host
#crtpy uses recursive func
crtsh -d $host -r | tee -a domains_$host
echo "${RED}CRT.SH Sub-Domains scrapping Done${RESET}"

#Using Search Bufferover resolving domain
echo "${RED}Doing bufferover scan ...${RESET}"
curl -s "https://dns.bufferover.run/dns?q=.${host}" | jq -r .FDNS_A[] | sed -s 's/,/\n/g' | tee -a domains_$host
echo "${RED}DNS.Bufferover.run scrapping Done${RESET}"


#Web.archive.org subdomains scrapping
echo "${RED}Doing web.archive scan ...${RESET}"
curl -sk "http://web.archive.org/cdx/search/cdx?url=*.${host}&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u | tee -a domains_$host
echo "${RED}Web.archive.org subdomains scrapping Done${RESET}"

# knockpy v5.1.0
knockpytool(){
    knockpy --set apikey-virustotal=$knockpyvirusapi
    cd ~/results/$host/
    knockpy $host > knockpy_$host.txt
    cat knockpy_$host.txt | awk '{print $9}' | sort -u | grep "${host}"
}
echo "Doing knockpy scan..."
knockpytool
echo "${RED}knockpy Done${RESET}"


#Find subdomains with jsubfinder
cd ~/results/$host
sort -u domains_$host -o domains_$host
jsubfinder -f domains_$host -crawl -c 20 -o jsub_$host -g | tee -a domains_$host
echo "${RED}jsubfinder Done${RESET}"

#sonarsearch using https://sonar.omnisint.io
echo "${RED}Doing sonar search ...${RESET}"
curl -s "https://sonar.omnisint.io/subdomains/${host}" | jq '.[]' | sed -s 's/"//g' | tee -a domains_$host
echo "${RED}sonar search done${RESET}"

#filtering the domains
echo "${BLUE}Filtering Domains${RESET}"
sort -u domains_$host -o domains_$host
cat domains_$host | filter-resolved -c 10 >> resolved_$host.txt
echo ""
echo ""

# httpx live
echo "${RED}Filtering out live Domains${RESET}"
httpx -l ~/results/$host/resolved_$host.txt -o ~/results/$host/live_$host.txt
echo "HTTPX Done"
echo ""


##################
#Sub Domain Takeover scan using Nuclei
nucleiScanSUBS(){
#updates nuclei templates
nuclei -ut -silent 

cd ~/results/$host
#nuclei scan for sub tkovr's
echo "Nuclei Sub-Domain Takeover scan for ${host}..." | notify -silent -discord-webhook-url "${SUBSNOTIFYURL}"
nuclei -l live_$host.txt -t ~/nuclei-templates/takeovers/ -silent -o nuclei_substkovr_$host

cat nuclei_substkovr_$host | awk '{print $3,$4,$5,$6}' | notify -silent -discord-webhook-url "${SUBSNOTIFYURL}"
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
echo "${BLUE} Nuclei Sub-Domain Takeover Scan Done${RESET}" | notify -silent -discord-webhook-url "${SUBSNOTIFYURL}"

clear

#Time Elapsed In Seconds Calculation---END 
end=$(date +%s)
runtime=$(python -c "print '%u:%02u' % ((${end} - ${start})/60, (${end} - ${start})%60)")
echo "${GREEN}Runtime: ${RED}$runtime${RESET} ${GREEN}(minutes:seconds)${RESET}" | notify -silent -discord-webhook-url "${SUBSNOTIFYURL}"
echo ""

#Number of Sub-Domains
echo "${GREEN}The Total No of Sub-Domains Gathered:${RESET}${RED}$(cat domains_$host | wc -l)${RESET}" | notify -silent -discord-webhook-url "${SUBSNOTIFYURL}"
echo ""

#Number of resolved domains
echo "${GREEN}The Total No of Resolved Domain's :${RESET}${RED}$(cat resolved_$host.txt | wc -l)${RESET}" | notify -silent -discord-webhook-url "${SUBSNOTIFYURL}"
echo ""
#Number of Live Sub-Domains
echo "${GREEN}The Total No of Live Sub-Domains:${RESET}${RED}$(cat live_$host.txt | wc -l)$RESET" | notify -silent -discord-webhook-url "${SUBSNOTIFYURL}"
echo ""
#Number of Sub-Domain Takeover's
echo "${GREEN}No of Sub-Domains Takeover possible :${RESET}${RED}$(cat nuclei_substkovr_$host | wc -l)${RESET}" | notify -silent -discord-webhook-url "${SUBSNOTIFYURL}"
echo ""

#Done statement for $host
echo "${GREEN}Done Enumerating All Sub-Domains for${RESET} ${RED}${host}${RESET}" | notify -silent -discord-webhook-url "${SUBSNOTIFYURL}"

#Visual Tree Graph
tree ~/results/$host/ -Q -v | notify -silent -discord-webhook-url "${SUBSNOTIFYURL}"
echo " "

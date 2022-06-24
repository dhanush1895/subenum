#!/bin/bash
source ~/.bash_profile

#Change this home directory to Your's
HOME="/home/dhanush"

# Script to initiate the alias in bash file
shopt -s expand_aliases
alias subls="python3 ${HOME}/tools/Sublist3r/sublist3r.py"
alias github-subd="python3 ${HOME}/scripts/github-subdomains.py"
alias subbrute="python3 ${HOME}/tools/subbrute/subbrute.py"

##Subdomain bruteforcer list 
Wordlist="${HOME}/tools/Wordlists/assetnote/all_1cr_28L_subdomains.txt"
AMSCON="${HOME}/.config/amass/config.ini"
#SUBFCON="${HOME}/subenum/config.yaml"
RESOLVWORDLIST="${HOME}/tools/Wordlists/resolvers-valid-all.txt"
#Tokens 
findomain_virustotal_token="VIRUSTOKEN" 
findomain_securitytrails_token="SECURITYTRAILSTOKEN"
findomain_fb_token="FBTOKEN"
gitT="GITHUBTOKEN"
knockpyvirusapi="VIRUSTOKEN"

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
echo "${RED}---------------------------------------------${RESET}" | tee -a notfi.txt 
echo "${GREEN}Doing sub-domain's scan for ${host}${RESET}" | tee -a notfi.txt

#V1.0

#amass
amassActive(){
    amass enum -active -d $host -o amassA_$host -silent -brute
}
amassPassive1(){
    amass enum -passive -d $host -config $AMSCON -o amassP_$host -silent 
}
amass_A_P_comb(){
    cat amassA_$host amassP_$host | tee -a domains_$host
    rm -rf amassA_$host amassP_$host
}
amassPassive2(){
    amass enum -passive -d $host -config $AMSCON -o amassP1_$host -silent
    cat amassP1_$host | tee -a domains_$host
    rm -rf amassP1_$host
}
echo "${GREEN}Do you want to enum domains using active(Bruteforce Method) & passive method ?\n If No by Default it will do passive scan!,\n If Nothing selected within 5 secs it will do Both!${RESET}"
TMOUT=5
select yn in "Yes" "No";do
	case $yn in
		Yes ) echo "Enumerating Domains using Active & Passive"; amassActive; amassPassive1; amass_A_P_comb; break;;
		No ) echo "Enumerating Domains using Passive resources"; amassPassive2; break;;
	esac
done

if [ -z "$yn" ] ; then 
echo "${GREEN}Doing scan automatically amass${RESET}"
amassActive
amassPassive1
amass_A_P_comb
fi

echo "${RED}Amass Done${RESET}"
echo ""

#assetfinder
echo "${GREEN}Doing assetfinder scan ...${RESET}"
assetfinder -subs-only $host | tee -a domains_$host

echo "${RED}Assetfinder Done${RESET}"

#subfinder
echo "${GREEN}Doing subfinder scan ...${RESET}"
subfinder -d $host -all -silent | tee -a domains_$host

echo "${RED}Subfinder Done${RESET}"

#findomain
echo "${GREEN}Doing findomain scan ...${RESET}"
findomain -t $host -q | tee -a domains_$host

echo "${RED}Findomain Done${RESET}"

#Sublist3r
echo "${GREEN}Doing sublist3r scan ...${RESET}"
subls -d $host -o subls_$host.txt ; cat subls_$host.txt | tee -a domains_$host && rm -rf subls_$host.txt

echo "${RED}Sublist3r Done${RESET}"

#github-subdomains-search
echo "${GREEN}Doing github-subdomains scan ...${RESET}"
github-subd -t $gitT -d $host -e | tee -a domains_$host

echo "${RED}Github-subdomains-search Done${RESET}"

# V1.1

#Search subdomains in cert.sh
echo "${RED}Doing crt.sh scan ...${RESET}"
curl -s "https://crt.sh/?q=%25.${host}&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee -a domains_$host
#crtpy uses recurisive func
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
    echo "${BLUE}Doing knockpy scan ...${RESET}"
    knockpy --set apikey-virustotal=$knockpyvirusapi
    knockpy $host > knockpy_$host.txt
    cat knockpy_$host.txt | awk '{print $9}' | sort -u | grep "${host}" | tee -a domains_$host
    rm -rf knockpy_$host.txt
    echo "${RED}knockpy Done${RESET}"
}

knockpytool



#Using jhaddix All.txt to fuzz sub-domains
fuzzDomain(){
    echo "${GREEN}Doing fuzz scan ...${RESET}"
    echo "${GREEN}This may take a while approx.${RED}(15-30 minutes), ${GREEN}Based on Internet Speed${RESET}"; 
    ffuf -w $Wordlist -u "https://FUZZ.${host}/" -v -mc all | grep "| URL |" | awk '{print $4}' | tee -a domains_$host
    echo "${RED}FUZZing  Done${RESET}"
}

echo "${GREEN}Do you wish to do Brute force subdomains using ${RED}'FUFF & All.txt by jhaddix'${GREEN}?\nIf nothing selected within ${RED}30 secs${RESET} ${GREEN}it will do automatically!${RESET}"
TMOUT=30
select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; 
do
    case $yn in
        Yes ) fuzzDomain; break;;
        No ) break;;
    esac
done
if [ -z "$yn" ] ; then
    fuzzDomain
fi
echo "${RED}FUZZ Done${RESET}"

#knockknock searchs/collects for internal website related URL's from one -target / -domain
KNOCKKNOCKSCAN(){
echo "${GREEN}Doing knockknock scan ...${RESET}"
knockknock -n $host -p
if [[ -f ~/results/$host/domains.txt ]]
    then
        cat domains.txt | grep '${host}' | tee -a domains_$host
        rm -rf domains.txt
fi
echo "${RED}knockknock ${host} related_domains Done${RESET}"
}

echo "${GREEN}Do you wish to run knockknock scan ? \n If nothing selected within ${RED}5 secs${RESET} ${GREEN}It will do automatically!${RESET}"
TMOUT=5
select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
    case $yn in
        Yes ) KNOCKKNOCKSCAN; break;;
        No ) break;;
    esac
done

if [ -z "$yn" ] ; then
    KNOCKKNOCKSCAN
fi

#filtering the domains
echo "${BLUE}Filtering & Resolving Domains${RESET}"
sort -u domains_$host -o domains_$host
echo "Filtering & Resolving Done"
echo ""

# httpx live
HTTPX(){
    echo " ${RED}HTTPX${RESET} ${GREEN}started${RESET}"
    httpx -silent -l ~/results/$host/domains_$host -o ~/results/$host/live_$host.txt -silent 
    echo "${RED}HTTPX${RESET} ${GREEN}Done${RESET}"
    echo ""
}
HTTPX

nucleiScanSUBS(){
    #updates nuclei && templates
    nuclei -update -silent && nuclei -ut -silent 
    #nuclei scan for sub tkovr's
    echo "Nuclei Sub-Domain Takeover scan for ${host}..." | tee -a notfi.txt
    nuclei -l ~/results/$host/live_$host.txt -t ~/nuclei-templates/takeovers/ -silent -o nuclei_substkovr_$host
    echo "Possible SubDomain Takeovers :-" | tee -a notfi.txt 
    cat nuclei_substkovr_$host | awk '{print $3,$4,$5,$6}' | tee -a notfi.txt 
    echo "${BLUE} Nuclei Sub-Domain Takeover Scan Done${RESET}" | tee -a notfi.txt 
}

echo -e "${GREEN}Do you want to ${RED} Scan for Subdomain Takeover's?\nIf nothing selected within ${RED}15 secs${RESET} ${GREEN}it will do automatically!${RESET}"
TMOUT=15
select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
    case $yn in
        Yes ) nucleiScanSUBS ; break;;
        No ) break;;
    esac
done
if [ -z "$yn" ] ; then 
    nucleiScanSUBS
fi

clear
#Time Elapsed In Seconds Calculation---END 
end=$(date +%s)
runtime=$(python -c "print '%u:%02u' % ((${end} - ${start})/60, (${end} - ${start})%60)")
echo "${GREEN}Runtime: ${RED}$runtime${RESET} ${GREEN}(minutes:seconds)${RESET}" | tee -a notfi.txt
echo ""

#Number of Sub-Domains
echo "${GREEN}The Total No of Sub-Domains Gathered:${RESET}${RED}$(cat domains_$host | wc -l)${RESET}" | tee -a notfi.txt
echo ""
#Number of resolved domains
echo "${GREEN}The Total No of Resolved Domain's :${RESET}${RED}$(cat resolved_$host | wc -l)${RESET}" | tee -a notfi.txt
echo ""
#Number of Live Sub-Domains
echo "${GREEN}The Total No of Live Sub-Domains:${RESET}${RED}$(cat live_$host.txt | wc -l)$RESET" | tee -a notfi.txt
echo ""
#Number of Sub-Domain Takeover's
echo "${GREEN}No of Sub-Domains Takeover possible :${RESET}${RED}$(cat nuclei_substkovr_$host | wc -l)${RESET}" | tee -a notfi.txt
echo ""

#Done statement for $host
echo "${GREEN}Done Enumerating All Sub-Domains for${RESET} ${RED}${host}${RESET}" | tee -a notfi.txt
echo ""
# Send Details to Discord Server (Implement Notify in your environment and set provider config file)
notify -data ~/results/$host/notfi.txt -bulk -silent

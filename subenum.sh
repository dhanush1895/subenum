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
echo "Doing sub-domain's scan for ${host}" | notify -silent -discord-webhook-url "${SUBSNOTIFYURL}"
#V1.0

#getting resolver's valid one's
DNSresolve(){
echo "Getting valid resolver's from public-dns.info, This may take some time" 
cd $HOME
dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 100 --silent | tee -a resolvers-valid-all.txt
}
DNSresolve
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

echo "${RED}Amass Done${RESET}"

#assetfinder
echo "Doing assetfinder scan ..."
assetfinder -subs-only $host | tee -a domains_$host
echo "${RED}Assetfinder Done${RESET}"

#subfinder
echo "Doing subfinder scan ..."
subfinder -d $host -all -silent -t 60 -config $SUBFCON | tee -a domains_$host
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

#Using jhaddix All.txt to fuzz sub-domains
fuzzDomain(){
    echo "${GREEN}Doing fuzz scan ...${RESET}"
    echo "${GREEN}This may take a while approx.(15-30 minutes), Based on Internet Speed${RESET}"; 
    ffuf -t 100 -w $Wordlist -u "https://FUZZ.${host}/" -v | grep "| URL |" | awk '{print $4}' | tee -a domains_$host
}
echo "${GREEN}Do you wish to do Brute force subdomains using ${RED}'FUFF & All.txt by jhaddix'${GREEN}?\nIf nothing selected within ${RED}5 secs${RESET} ${GREEN}it will do automatically!${RESET}"
TMOUT=5
select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
    case $yn in
        Yes ) fuzzDomain; break;;
        No ) break;;
    esac
done
if [ -z "$yn" ] ; then
    fuzzDomain
fi
echo "${RED}FUZZing  Done${RESET}"

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
    knockpy --set apikey-virustotal=$knockpyvirusapi
    cd ~/results/$host/
    knockpy $host > knockpy_$host.txt
    cat knockpy_$host.txt | awk '{print $9}' | sort -u | grep "${host}"
    #cat knockpy_$host.txt | sed 's/ /\n/g' | sort -u | grep "${host}" | tee -a domains_$host
    #jq 'keys[]' | sed 's/"//g'
    #cat ~/results/$host/$csvfile | sed -s 's/;/ /g' | awk '{print $2}' | tee -a domains_$host
}
echo "Doing knockpy scan..."
knockpytool
echo "${RED}knockpy Done${RESET}"


#Find subdomains with jsubfinder
cd ~/results/$host
sort -u domains_$host -o domains_$host
#Find Secrets with jsubfinder
# jsubfinder -f domains_$host -s -c 50 -crawl -o jsub_$host -g | tee -a domains_$host
jsubfinder -f domains_$host -c 50 -crawl -o jsub_$host -g | tee -a domains_$host
echo "${RED}jsubfinder Done${RESET}"

#sonarsearch using https://sonar.omnisint.io
echo "${RED}Doing sonar search ...${RESET}"
curl -s "https://sonar.omnisint.io/subdomains/${host}" | jq '.[]' | sed -s 's/"//g' | tee -a domains_$host
echo "${RED}sonar search done${RESET}"

#filtering the domains
echo "${BLUE}Filtering Domains${RESET}"
sort -u domains_$host -o domains_$host
cat domains_$host | filter-resolved -c 100 >> resolved_$host.txt
echo ""
echo ""

# httpx live
echo "${RED}Filtering out live Domains${RESET}"
httpx -silent -threads 500 -l ~/results/$host/resolved_$host.txt -o ~/results/$host/live_$host.txt
echo "HTTPX Done"
echo ""

#httpx title
domainshttpxtitle(){
    echo "${RED}Doing domainshttpxtitle scan ...${RESET} "
    httpx -l domains_$host --title -o title_$host.txt -silent -threads 500 -mc 200  -follow-redirects -follow-host-redirects -random-agent -retries 3
}

echo -e "${GREEN}Do you want to get ${RED}title of subdomains?\nIf nothing selected within ${RED}5 secs${RESET} ${GREEN}it will do automatically!${RESET}"
TMOUT=5
select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
    case $yn in
        Yes ) domainshttpxtitle ; break;;
        No ) break;;
    esac
done
if [ -z "$yn" ] ; then 
    domainshttpxtitle
fi
echo "${BLUE} Title of subdomains done${RESET}"


##################

nucleiScanSUBS(){
#updates nuclei templates
nuclei -ut -silent 

cd ~/results/$host
#nuclei scan for sub tkovr's
echo "Nuclei Sub-Domain Takeover scan for ${host}..." | notify -silent -discord-webhook-url "${SUBSNOTIFYURL}"
nuclei -l live_$host.txt -t ~/nuclei-templates/takeovers/ -silent -bs 50 -o nuclei_substkovr_$host

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


#CHAOS Project Discovery without API Key 
#problem @host grep from chaos-data.json echo command
#chaosD(){
#    wget -q "http://chaos-data.projectdiscovery.io/index.json" -O ~/results/chaos-data.json
#    cat chaos-data.json | grep "URL" | sed 's/"URL": "//;s/",//' | grep "${host}"
#}
#echo "${GREEN}Do you want to download subdomains using ${RED}'CHAOS'${RESET} ${GREEN}if available!?${RESET}"
#select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
#    case $yn in
#        Yes ) echo "${BLUE}It's Better to do manual Download ${host} zip file${RESET}"; break;;
#        No ) exit;;
#    esac
#done

#Before using shuffledns we have to get valid resolvers for dns resolving

shuffledns -d $host -list results/$host/domains_$host -silent -r ~/tools/resolvers-valid-all.txt -strict-wildcard -massdns ~/tools/massdns/bin/massdns 

# massdns -r ~/resolversall -t A -o J massdnssubdomains.txt | jq 'select(.resp_type=="A")|.query_name' | sort -u | tee -a domains_$host
#Subbrute 
# echo "${GREEN}Do you wish to do Brute force subdomains using ${RED}'Subbrute & massdns'${GREEN}?${RESET}"
# select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
#     case $yn in
#         Yes ) echo "${GREEN}This may take a while approx.(15-30 minutes)${RESET}"; subbrute $host -p -r ~/tools/subbrute/resolvers.txt | sed -r 's/./\n/g' | grep "*${host}*" | tee -a domains_$host; break;;
#         No ) break;;
#     esac
# done


puredns bruteforce $Wordlist $host -r ~/tools/Wordlists/resolvers-valid-all.txt --bin ~/tools/massdns/bin/massdns --write valid_domains.txt --write-wildcards wc_domains.txt --write-massdns massdns.txt
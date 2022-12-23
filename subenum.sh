#!/bin/bash
source ~/.bash_profile

# Script to initiate the alias in bash file
shopt -s expand_aliases
alias subls="python3 $HOME/tools/Sublist3r/sublist3r.py"
alias subbrute="python3 $HOME/tools/subbrute/subbrute.py"


##Subdomain bruteforcer list 
Wordlist="$HOME/tools/Wordlists/subdomains.txt"
###   AMSCON is decalred in cmd args
AMSCON1="$HOME/.config/amass/config.ini"    # This config file holds less number of API keys which are no. of free queries
AMSCON2="$HOME/.config/amass/config2.ini"   # This config file holds more number of API keys which are limited no. of queries & free also
RESOLVWORDLIST="$HOME/tools/Wordlists/resolvers.txt"

#Tokens 
gitT="ghp_xxxxxxxxxxxxxxPWJCiHixxxx06hohG,ghp_8xxxxxxxxxxxxs2e4kzWA93xevk"
knockpyvirusapi="00a52cxxxxxxxxxxxc67db14xxxxxxxfb9d153cxxxxx9a5"

#Terminal Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
BLINK=$(tput blink)
RESET=$(tput sgr0)

#Banner
Banner(){
    figlet Subenum
}
Banner

MAINSS(){

    FOLDERCREATION(){
        echo -e "${BLUE}By Default ${RED}'results'${BLUE} dir will be created in "${RED}$HOME${RESET}""
        mkdir -p ~/results
        cd ~/results
        mkdir -p $host
        cd ~/results/$host
    }
    FOLDERCREATION

    cd ~/results/$host

    ##if notif.txt file exists already then it appends notify+N.txt
    NOTIFYYY="notfi.txt"
    NNN=0
    while test -f "$NOTIFYYY"; do
        NNN=$((NNN+1))
        NOTIFYYY="notfi_$NNN.txt"
        #statements
    done

    #getting resolver's valid one's
    DNSresolve(){
    echo "${BLUE}Getting valid resolver's from public-dns.info, This may take some time${RESET}" 
    dnsvalidator -tL https://public-dns.info/nameservers.txt --silent -o $RESOLVWORDLIST
    #check again the resolver list valid
    #.................................
    }

    resolverdownload(){
        # Set the URL of the file to download
        echo "${BLUE}Downloading resolver's.............${RESET}"
        resolverurl="https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt"
        wget $resolverurl -O trickest_resolvers.txt -q -p ~/tools/Wordlists
        if [ -f ~/tools/Wordlists/trickest_resolvers.txt ]
        then
            cat ~/tools/Wordlists/trickest_resolvers.txt | anew -t -q $RESOLVWORDLIST
            rm ~/tools/Wordlists/trickest_resolvers.txt
        fi
    }

    ##checks if the file is present or not for DNSRESOLVER'S
    resolverfilecheck(){
            if [[ -f "$RESOLVWORDLIST" ]] 
            then
                if find $RESOLVWORDLIST -mtime +1
                then
                  # Execute the command if the file is older than 1 day
                  echo "${RED}${BLINK}Resolver's ${GREEN}file already existed and${RED}Above 24hrs old resolver's file${RESET}"
                  resolverdownload
                else
                  # Do nothing if the file is not older than 1 day
                  echo "${RED}${BLINK}Resolver's ${GREEN}file already existed and${RED}lesser 24hrs old resolver's file${RESET}"
                  echo "${GREEN}${BLINK}OK!!!${RESET}"
                fi                
            else
                resolverdownload
            fi
    }
    resolverfilecheck

    wordlistdownload(){
        # Set the URL of the file to download
        echo "${BLUE}Downloading wordlist's.............${RESET}"
        wordlistsurl="https://raw.githubusercontent.com/trickest/wordlists/main/inventory/subdomains.txt"
        wget $wordlistsurl -O trickest_subdoamins.txt -q -P ~/tools/Wordlists
        if [ -f ~/tools/Wordlists/trickest_subdomains.txt ]
        then
            cat ~/tools/Wordlists/trickest_subdomains.txt | anew -t -q $Wordlist
            rm ~/tools/Wordlists/trickest_subdomains.txt
        else
            echo "${RED}${BLINK}File didnt downloaded successfully${RESET}"
            exit
        fi
        echo "${GREEN}Done getting Sub-Domains Wordlists${RESET}" 
    }
    wordlistcheck(){
        if [ -f $Wordlist ]
        then
            if find $Wordlist -mtime +4
            then
                echo "${RED}Getting fresh subdomains from trickest\n Present wordlists is 4 days old${RESET}"
                wordlistsurl
            else
                echo "Wordlists OK!!!"
            fi
        else
            echo "${RED}${BLINK}Allocate Wordlist for Subdomain Enumeration${RESET}"
            exit 
        fi
    }
    wordlistcheck

    #Time Elapsed In Seconds CalculatioN---START
    start=$(date +%s)
    echo "${RED}---------------------------------------------${RESET}" | tee -a $NOTIFYYY 
    echo "${GREEN}Doing sub-domain's scan for ${host}${RESET}" | tee -a $NOTIFYYY

   ### V1.0

    #amass
    amassActive(){
        amass enum -active -d $host -o amassA_$host -silent -brute -config $AMSCON
    }
    amassPassive1(){
        amass enum -passive -d $host -config $AMSCON -o amassP_$host -silent 
    }
    amass_A_P_comb(){
        cat amassA_$host amassP_$host | anew -t -q domains_$host
        rm -rf amassA_$host 
        rm -rf amassP_$host
    }
    amassPassive2(){
        amass enum -passive -d $host -config $AMSCON -o amassP1_$host -silent
        cat amassP1_$host | anew -t -q domains_$host
        rm -rf amassP1_$host
    }
    amassIntel(){
        amass intel -whois -d $host -o amassI_$host -silent -config $AMSCON
    }
    echo -e "${GREEN}Do you want to enum domains using active(Bruteforce Method) & passive method ?\nIf No by Default it will do passive scan!, If Nothing selected within 15 secs it will do Both!${RESET}"
    TMOUT=15
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
    assetfinder -subs-only $host | anew -t -q domains_$host
    echo "${RED}Assetfinder Done${RESET}"

    #subfinder
    echo "${GREEN}Doing subfinder scan ...${RESET}"
    subfinder -d $host -all -silent | anew -t -q domains_$host
    echo "${RED}Subfinder Done${RESET}"

    #Sublist3r
    echo "${GREEN}Doing sublist3r scan ...${RESET}"
    sublsOutput="subls_$host.txt"
    SS=0
    while test -f "$sublsOutput"; do
        SS=$((SS+1))
        sublsOutput="subls_$host_$SS.txt"
    done
    subls -d $host -o $sublsOutput ; cat $sublsOutput | anew -t -q domains_$host
    if [ -f "$sublsOutput" ];then
        rm -rf $sublsOutput
    fi
    echo "${RED}Sublist3r Done${RESET}"

    #github-subdomains-search
    echo "${GREEN}Doing github-subdomains scan ...${RESET}"
    github-subdomains -d $host -e -o github-subd_$host.txt -t $gitT
    cat github-subd_$host | anew -t -q domains_$host
    echo "${RED}Github-subdomains-search Done${RESET}"

    # V1.1

    #Search subdomains in crt.sh
    echo "${GREEN}Doing crt.sh scan ...${RESET}"
    curl -s "https://crt.sh/?q=%25.${host}&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | anew -t -q domains_$host
    #crtpy uses recurisive func
    crtsh -d $host -r | anew -t -q domains_$host
    echo "${RED}CRT.SH Sub-Domains scrapping Done${RESET}"

    #Using Search Bufferover resolving domain
    echo "${GREEN}Doing bufferover scan ...${RESET}"
    curl -s "https://dns.bufferover.run/dns?q=.${host}" | jq -r .FDNS_A[] | sed -s 's/,/\n/g' | anew -t -q domains_$host
    echo "${RED}DNS.Bufferover.run scrapping Done${RESET}"

    #Web.archive.org subdomains scrapping
    echo "${GREEN}Doing web.archive scan ...${RESET}"
    curl -sk "http://web.archive.org/cdx/search/cdx?url=*.${host}&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u | anew -t -q domains_$host
    echo "${RED}Web.archive.org subdomains scrapping Done${RESET}"

    # knockpy v5.1.0
    knockpytool(){
        echo "${GREEN}Doing knockpy scan ...${RESET}"
        knockpy --set apikey-virustotal=$knockpyvirusapi
        knockpy $host >> knockpy_$host.txt
        cat knockpy_$host.txt | awk '{print $9}' | sort -u | grep "${host}" | anew -t -q domains_$host
        if [ -f knockpy_$host.txt ]; then
            rm -rf knockpy_$host.txt
        fi
        if [ -d knockpy_report ]; then
            rm -rf knockpy_report
        fi
        echo "${RED}knockpy Done${RESET}"
    }

    knockpytool

    #knockknock searchs/collects for internal website related URL's from one -target / -domain
    KNOCKKNOCKSCAN(){
        echo "${GREEN}Doing knockknock scan ...${RESET}"
        knockknock -n $host -p
        if [[ -f ~/results/$host/domains.txt ]]
        then
            possibleKKhost=$(echo -n $host | cut -d "." -f 1) 
            cat domains.txt | grep -E "^([a-zA-Z0-9-]+\.)*$possibleKKhost" | anew -q domains_$host
            cat domains.txt | grep -E "$possibleKKhost" | anew -q domains_$host
            cat domains.txt | grep "*.$possibleKKhost.*" | anew -q domains_$host
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

    shufflednsmassdns(){
        echo "${GREEN}Doing scan using shufflednsmassdns${RESET}"
        shuffledns -d $host -r $RESOLVWORDLIST -w $Wordlist -o ~/results/$host/shufflednsmassdns_$host.txt -m ~/tools/massdns/bin/massdns -t 500 -sw -wt 10 #| massdns -r $RESOLVWORDLIST -t A -a -o -w massdns_$host
        if [ -f ~/results/$host/shufflednsmassdns_$host.txt ] ; then
            cat ~/results/$host/shufflednsmassdns_$host.txt | anew -t -q domains_$host
        fi
        echo "${RED}shufflednsmassdns Done${RESET}"
    }
    echo "${GREEN}Do you wish to run shuffledns & massdns scan ?\nIf nothing selected within ${RED}45 secs${RESET}${GREEN}It will do automatically!${RESET}"
    TMOUT=45
    select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
        case $yn in
            Yes ) shufflednsmassdns; break;;
            No ) break;;
        esac
    done

    if [ -z "$yn" ] ; then
        shufflednsmassdns
    fi

    #------------------------------------------------------------------------------------------------------------------------
    
    #Port Scanning
    NAABUSCAN(){
        echo "${RED}Probing out Ports of ${host} Domains using naabu${RESET}"
        naabu -l ~/results/$host/domains_$host -p - -o ~/results/$host/naabu_$host -r $RESOLVWORDLIST -rate 2000
        echo "NAABUSCAN Done"
        echo ""
    }
    NAABUSCAN

    # httpx probing
    HTTPX(){
        echo "${RED}Filtering out live Domains${RESET}"
        httpx -r $RESOLVWORDLIST -silent -l ~/results/$host/naabu_$host -o ~/results/$host/live_$host.txt -rlm 5000 -silent 
        echo "HTTPX Done"
        echo ""
    }
    HTTPX
    
    ##################

    nucleiScanSUBS(){
    #updates nuclei templates
    nuclei -update -silent && nuclei -ut -silent 

    #nuclei scan for sub tkovr's
    echo "${BLUE}Nuclei Sub-Domain Takeover scan for ${host}...${RESET}" | tee -a $NOTIFYYY
    nuclei -l ~/results/$host/live_$host.txt -t ~/nuclei-templates/takeovers/ -silent -o nuclei_substkovr_$host
    echo "${RED}Possible SubDomain Takeovers :-${RESET}" | tee -a $NOTIFYYY 
    cat nuclei_substkovr_$host | awk '{print $3,$4,$5,$6}' | tee -a $NOTIFYYY 
    echo "${BLUE} Nuclei Sub-Domain Takeover Scan Done${RESET}" | tee -a $NOTIFYYY 
    }

    echo -e "${GREEN}Do you want to ${RED} Scan for Subdomain Takeover's?\nIf nothing selected within ${RED}5 secs${RESET} ${GREEN}it will do automatically!${RESET}"
    TMOUT=10
    select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
        case $yn in
            Yes ) nucleiScanSUBS ; break;;
            No ) break;;
        esac
    done
    if [ -z "$yn" ] ; then
        slee
        nucleiScanSUBS
    fi

    NucleiScan(){
    #updates nuclei && templates &&&& CENT tool
    nuclei -update -silent && nuclei -ut -silent 
    cent -p cent-nuclei-templates -k 

    #nuclei scan for sub tkovr's
    echo "Nuclei Sub-Domain Takeover scan for ${host}..." | tee -a $NOTIFYYY
    nuclei -l ~/results/$host/live_$host.txt -t ~/nuclei-templates/ -t ~/cent-nuclei-templates/ -es info -silent -o ~/results/$host/nucleiscan_$host.txt
    echo "Possible SubDomain Takeovers :-" | tee -a nuclienotify.txt 
    cat nucleiscan_$host.txt | awk '{print $3,$4,$5,$6}' | tee -a nuclienotify.txt 
    echo "${BLUE} Nuclei Sub-Domain Takeover Scan Done${RESET}" | tee -a nuclienotify.txt 
    }

    echo -e "${GREEN}Do you want to ${RED} Scan for Vulnerabilities?\nIf nothing selected within ${RED}10 secs${RESET} ${GREEN}it will do automatically!${RESET}"
    TMOUT=10
    select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
        case $yn in
            Yes ) NucleiScan ; break;;
            No ) break;;
        esac
    done
    if [ -z "$yn" ] ; then 
        NucleiScan
    fi

    #Time Elapsed In Seconds Calculation---END 
    end=$(date +%s)
    runtime=$(python -c "print '%u:%02u' % ((${end} - ${start})/60, (${end} - ${start})%60)")
    echo "${GREEN}Runtime: ${RED}${runtime}${RESET}${GREEN}(minutes:seconds)${RESET}" | tee -a $NOTIFYYY
    echo ""

    #Number of Sub-Domains
    echo "${GREEN}The Total No of Sub-Domains Gathered:${RESET}${RED}$(cat domains_$host | wc -l)${RESET}" | tee -a $NOTIFYYY
    echo ""

    #Number of Live Sub-Domains
    echo "${GREEN}The Total No of Live Sub-Domains:${RESET}${RED}$(cat live_$host.txt | wc -l)$RESET" | tee -a $NOTIFYYY
    echo ""
    #Number of Sub-Domain Takeover's
    echo "${GREEN}No of Sub-Domains Takeover possible :${RESET}${RED}$(cat nuclei_substkovr_$host | wc -l)${RESET}" | tee -a $NOTIFYYY
    echo ""

    #Done statement for $host
    echo "${GREEN}Done Enumerating All Sub-Domains for${RESET} ${RED}${host}${RESET}" | tee -a $NOTIFYYY

    # Send Details to Discord Server (Implement Notify in your environment and set provider config file)
    notify -data ~/results/$host/$NOTIFYYY -bulk -silent
}


USAGE(){
    echo -e ""
    echo -e "${RED}${BLINK}Usage: subenum -d google.com${RESET}"
    echo -e "${RED}${BLINK}Usage: subenum -f PATH/TO/FILE${RESET}"
    echo -e "${RED}${BLINK}Usage: subenum -d google.com -c [1|2]${RESET}"
    echo -e "${RED}${BLINK}Usage: subenum -f PATH/TO/domains.txt -c [1|2]${RESET}"

    echo -e "${GREEN}Flags:${RESET}"
    echo -e "${RED} -h, -help                      Show's usage                                               "
    echo -e " -d, -domain                    Add your domain                                            "
    echo -e " -f, -file                      List of Domains as file.txt should be line separated file                    ${RESET}"
    echo -e "${RED} -c, -config                      config file for amass                                               "
    echo -e "${GREEN}Example Usage${RESET}\n"
    echo -e " ${BLINK}${BLUE}./subenum.sh -d google.com\n"
    echo -e " ./subenum.sh -f domains.txt\n"
    echo -e " ./subenum.sh -d google.com -c [1|2]\n"
    echo -e " ./subenum.sh -f domains.txt -c [1|2] \n${RESET}"
    echo -e ""

}

####################################################
VERSION="1.2"

#unset's the value assigned to variable : true -> 0
unset d_opt_bool
unset f_opt_bool
unset c_opt_bool

#To let know that -d is specified and used
d_opt_bool=false

#To let know that -f is specified and used
f_opt_bool=false

#To let know that -c is specified and used
c_opt_bool=false


# Process the other command line argument using getopts,while & case options
while getopts :c:d:f:hv option; do
  case $option in
    h|help)
            USAGE
            exit 0
            ;;

    c|config)
              c_opt_bool=true
              c_value=$OPTARG
              ;;

    d|domain)
              #Assigns value true that option '-d' is used 
              d_opt_bool=true
              host=$OPTARG
              ;;

    f|file)
              #Assigns value true that option '-f' is used  
              f_opt_bool=true
              File1=$OPTARG
              ;;
    v|version)
              echo "VERSION IS $VERSION"
              exit 0
              ;;
    \?)
        echo "(\?)Invalid OPTIONS --->>> TRY"
        USAGE
        exit
        ;;
    ?)
        echo "(?)Invalid OPTIONS --->>> TRY"
        USAGE
        exit
        ;;
  esac
done


#First implement amass & subfinder config && Wordlist
if [ -f $Wordlist ];then
    echo "${GREEN}Wordlist EXISTS and contains ${BLINK}${RED}$(cat $Wordlist | wc -l )${RESET}${GREEN} number of words.${RESET}" 
else
    echo "${BLUE}Give Wordlist file path in the script ${BLINK}${RED}@12th line${RESET}"
    echo "${BLUE}So that the ${BLINK}${RED}Sub-Domain Enumeration${RESET}${BLUE} can be done${RESET}"
    exit
fi

if [ -f ~/.config/subfinder/config.yaml ] || [ -f ~/.config/subfinder/provider-config.yaml ]
then
    continue
elif [ -f ~/.config/amass/config.ini ] || [ -f ~/.config/amass/config*.ini ]
    continue
elif [ -f ~/.config/notify/config.yaml ] || [ -f ~/.config/amass/provider-config.yaml ]
    continue
else
    echo "${BLINK}${RED}Subfinder & Amass config should be set in order to run !!!${RESET}"
    exit
fi

if [ "$c_opt_bool" != true ]; then
    AMSCON=AMSCON1
    echo "${GREEN}Using ${RED}${BLINK}AMSCON1${RESET}"
elif [[ $c_value == "1" || $c_value == "2" ]]; then
    if [[ $c_value == "1" ]]; then
        echo "${GREEN}Using ${RED}${BLINK}AMSCON1${RESET}"
        AMSCON=AMSCON1
    elif [[ $c_value == "2" ]]; then
        echo "${GREEN}Using ${RED}${BLINK}AMSCON2${RESET}"
        AMSCON=AMSCON2
    fi
fi


if [ -n "$host" ] && [ -z "$File1" ]; then
    if [ ! -f "$host" ]; then
        MAINSS
    else
        echo "${BLUE}${BLINK}Given input is ${RED}file${BLUE} use option ${RED}-f${BLUE} to pass file as input${RESET}"
    fi 
elif [ -n "$File1" ] && [ -z "$host" ]; then
    if [ -f $File1 ]; then 
            File2=$(cat ${File1})
            echo -e "${GREEN}Total No of Subdomains Found in this file:${RED}${BLINK} $(cat ${File1} | wc -l)${RESET}" 
            for host in $File2;do
                MAINSS 
            done
    else
        echo "${RED}${BLINK}Given File does not EXISTS${RESET}"
    fi
elif [ -n "$host" ] && [ -n "$File1" ]; then
    echo "${BLINK}${RED}Used both -d & -f options"
    echo " Use either -d or -f options${RESET}"
    exit
fi

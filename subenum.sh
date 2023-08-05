#!/bin/bash
source ~/.bash_profile

# Script to initiate the alias in bash file, if you have already described alias as you configured initiate here...!
shopt -s expand_aliases
alias subls="python3 $HOME/tools/Sublist3r/sublist3r.py"
alias subbrute="python3 $HOME/tools/subbrute/subbrute.py"

##Subdomain bruteforcer list 
# This wordlist will automatically gets downloaded, when you use 'subenum-install.sh' file.
Wordlist="$HOME/tools/Wordlists/subdomains.txt"
# This wordlist will automatically gets downloaded, when you use 'subenum-install.sh' file.
RESOLVWORDLIST="$HOME/tools/Wordlists/resolvers.txt"

#Tokens 
#statically allocated tokens/variables should be changed according to the user's private tokens
# gitT : github access token
gitT="ghp_xxxxx,ghp_xxxx"
# gitL : gitlab access token
gitL="glpat-xxxx"
# virustotal scan API Key
knockpyvirusapi="xxxxx"

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

MAINSS()
{

        FOLDERCREATION(){
            echo -e "${BLUE}By Default ${RED}'results'${BLUE} dir will be created in "${RED}$HOME${RESET}""
            if [ "$f_opt_bool" == true ]; then
                mkdir -p ~/results/$ORGNAME/$host
                SAVEPATH="$HOME/results/$ORGNAME/$host"
                cd $SAVEPATH
            elif [ "$d_opt_bool" == true ]; then
                mkdir -p ~/results/$host
                SAVEPATH="$HOME/results/$host"
                cd $SAVEPATH
            fi
        }
        FOLDERCREATION

        cd $SAVEPATH

        ##if notif.txt file exists already then it appends notify+N.txt
        NOTIFYYY="$SAVEPATH/notfi.txt"
        NNN=0
        while test -f "$NOTIFYYY"; do
            NNN=$((NNN+1))
            NOTIFYYY="$SAVEPATH/notfi_$NNN.txt"
        done

        ##savefile
        savefile="$SAVEPATH/domains_$host.txt"


        #Time Elapsed In Seconds Calculation---START   
        start=$(date +%s)
        echo "${RED}---------------------------------------------${RESET}" | tee -a $NOTIFYYY 
        echo "${GREEN}Doing sub-domain's scan for ${host}${RESET}" | tee -a $NOTIFYYY

        ### V1.0

        #amass
        amassActive()
        {
            amassAfile="amassA_$host"
            AA=0
            while test -f "$amassAfile"; do
                AA=$((AA+1))
                amassAfile="amassA_$host_$AA" 
            done
            amass enum -d $host -active -silent -brute -w $Wordlist
            amass db -names -d $host -nocolor | anew -t -q $amassAfile

            if [ -f $amassAfile ]
            then
                cat $amassAfile | anew -t -q $savefile
            else
                echo "${BLINK}${RED}Amass Active Not done successfully !???${RESET}"
                exit 1
            fi
        }
        amassPassive()
        {
            amassPfile="amassP_$host"
            PP=0
            while test -f "$amassPfile"; do
                PP=$((PP+1))
                amassPfile="amassP_$host_$PP"
            done
            amass enum -d $host -passive -silent
            amass db -names -d $host -nocolor | anew -t -q $amassPfile
            if [ -f $amassPfile ]
            then
                cat $amassPfile | anew -t -q $savefile
            else
                echo "${BLINK}${RED}Amass Passive Not done successfully !???${RESET}"
                exit 1
            fi
        }

        if [ "$a_opt_bool" == true ]
        then 
            echo -e "${BLUE}Enumerating Domains using Active & Passive resources${RESET}"
            amassActive
            amassPassive
        elif [ "$p_opt_bool" == true ]
        then
            echo "${BLUE}Enumerating Domains using Passive resources${RESET}"
            amassPassive
        fi

        echo ""
        echo ""
        echo "${RED}Amass Done${RESET}"
        echo ""

        #assetfinder
        echo "${GREEN}Doing assetfinder scan ...${RESET}"
        assetfinder -subs-only $host | anew -t -q $savefile
        echo "${RED}Assetfinder Done${RESET}"

        #subfinder
        echo "${GREEN}Doing subfinder scan ...${RESET}"
        subfinder -d $host -all -silent | anew -t -q subf_$host
        if [ -f subf_$host ]
        then
            cat subf_$host | anew -t -q $savefile
        fi
        echo "${RED}Subfinder Done${RESET}"

        #github-subdomains-search
        echo "${GREEN}Doing github-subdomains scan ...${RESET}"
        githubOutput="github-subd_$host.txt"
        SS=0
        while test -f "$githubOutput"; do
            SS=$((SS+1))
            githubOutput="github-subd_$host_$SS.txt"
        done    
        github-subdomains -d $host -e -o $githubOutput -t $gitT
        if [ -f $githubOutput ];then
            cat $githubOutput | anew -t -q $savefile
        fi
        echo "${RED}Github-subdomains-search Done${RESET}"

        # V1.1

        #Search subdomains in crt.sh
        echo "${GREEN}Doing crt.sh scan ...${RESET}"
        curl -s "https://crt.sh/?q=%25.${host}&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | anew -t -q $savefile
        #crtpy uses recursive function
        crtsh -d $host -r | anew -t -q $savefile
        echo "${RED}CRT.SH Sub-Domains scrapping Done${RESET}"

        #Web.archive.org subdomains scrapping
        echo "${GREEN}Doing web.archive scan ...${RESET}"
        curl -sk "http://web.archive.org/cdx/search/cdx?url=*.${host}&output=txt&fl=original&collapse=urlkey&page=" | awk -F/ '{gsub(/:.*/, "", $3); print $3}' | sort -u | anew -t -q $savefile
        echo "${RED}Web.archive.org subdomains scrapping Done${RESET}"

        # knockpy v5.1.0
        knockpytool(){
            echo "${GREEN}Doing knockpy scan ...${RESET}"
            knockpy $host > $SAVEPATH/knockpy_$host.txt
            if [ -f $SAVEPATH/knockpy_$host.txt ]; then
                cat $SAVEPATH/knockpy_$host.txt | awk '{print $9}' | sort -u | grep "${host}" | anew -t -q $savefile
                #rm knockpy_$host.txt
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
            if [[ -f $SAVEPATH/domains.txt ]]
            then
                possibleKKhost=$(echo -n $host | cut -d "." -f 1) 
                cat domains.txt | grep -E "^([a-zA-Z0-9-]+\.)*$possibleKKhost" | anew -q $savefile
                cat domains.txt | grep -E "$possibleKKhost" | anew -q $savefile
                cat domains.txt | grep "*.$possibleKKhost.*" | anew -q $savefile
                if [ -f $SAVEPATH/domains.txt ];then
                    rm -rf domains.txt
                fi
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
            shuffledns -d $host -r $RESOLVWORDLIST -w $Wordlist -o $SAVEPATH/shufflednsmassdns_$host.txt -m ~/tools/massdns/bin/massdns -t 500 -sw -wt 10 #| massdns -r $RESOLVWORDLIST -t A -a -o -w massdns_$host
            if [ -f $SAVEPATH/shufflednsmassdns_$host.txt ] ; then
                cat $SAVEPATH/shufflednsmassdns_$host.txt | anew -t -q $savefile
            fi
            echo "${RED}shufflednsmassdns Done${RESET}"
        }
        echo "${GREEN}Do you wish to run shuffledns & massdns scan ?\nIf nothing selected within ${RED}5 secs${RESET}${GREEN}It will do automatically!${RESET}"
        TMOUT=5
        select yn in "${BLUE}Yes${RESET}" "${BLUE}No${RESET}"; do
            case $yn in
                Yes ) shufflednsmassdns; break;;
                No ) break;;
            esac
        done

        if [ -z "$yn" ] ; then
            shufflednsmassdns
        fi

        ## Version 1.2

        #gitlab-subdomains-search
        echo "${GREEN}Doing gitlab-subdomains scan ...${RESET}"
        gitlabOutput="gitlab-subd_$host.txt"
        SS=0
        while test -f "$gitlabOutput"; do
            SS=$((SS+1))
            gitlabOutput="gitlab-subd_$host_$SS.txt"
        done    
        gitlab-subdomains -d $host -e -t $gitL | anew -t -q $gitlabOutput 
        if [ -f $gitlabOutput ];then
            cat $gitlabOutput | anew -t -q $savefile
        else
            echo "${RED}gitlabOutput file not Generated${RESET}"
        fi
        echo "${RED}Github-subdomains-search Done${RESET}"


        #GAU & GAUPLUS
        GAUING(){
            echo "$host" | gau --subs | unfurl domains | sort -u | anew -t -q $savefile
            echo "$host" | gauplus -subs | unfurl domains | sort -u | anew -t -q $savefile
        }
        echo "Doing gau && gauplus on ${host}"
        GAUING
        echo "Done GAUING"
        #------------------------------------------------------------------------------------------------------------------------
        
        #resolving domains
        echo "${BLUE}Resolving Domains using DNSX${RESET}"
        savefilednx="$SAVEPATH/domains_$host_dnsx"

        if [ -f $savefile ]
        then
            dnsx -l $savefile -silent | anew -t -q $savefilednx
        else
            echo "${RED}${BLINK}domains file not found${RESET}"
            exit 1
        fi
        echo "${GREEN}Filtering & Resolving Done${RESET}"
        echo ""

        #Port Scanning
        NAABUSCAN(){
            echo ""
            echo "${RED}Probing out Ports of ${host} Domains using naabu${RESET}"
            naabu -l $savefilednx -p - -Pn -o $savefilenaabu -r $RESOLVWORDLIST -rate 5000 -ec
            echo "${BLUE}NAABU SCAN Done${RESET}"
            echo ""
        }
        if [ "$pscan_opt_bool" == true ]
        then
            if [ -f "$savefilednx" ];then
                savefilenaabu="$SAVEPATH/naabu_$host.txt"
                NAABUSCAN
            fi
        fi

        # httpx probing
        HTTPX(){
            echo "${RED}Filtering out live Domains${RESET}"
            httpx -r $RESOLVWORDLIST -silent -l $httpxFILE -o $savefilehttpx -title -sc -cl -silent -nc
            echo "HTTPX Done"
            echo ""
        }
        savefilehttpx="$SAVEPATH/httpx_$host.txt"
        savefilehttpxurls="$SAVEPATH/httpx_urls_$host.txt"
        if [ "$pscan_opt_bool" == true ]
        then
            httpxFILE="$savefilenaabu"
            HTTPX
        else
            httpxFILE="$savefilednx"
            HTTPX
        fi

        if [ -f "$savefilehttpx" ]
        then
            cat $savefilehttpx | awk '{print $1}' | anew -t -q $savefilehttpxurls
        else
            echo "${RED}HTTPX not done,...some error!${RESET}"
            exit 1
        fi

        ##################
        echo "" | tee -a $NOTIFYYY
        nucleiScanSUBS(){
            #nuclei scan for sub tkovr's
            if [ -f "$savefilehttpxurls" ];then
                #updates nuclei templates
                nuclei -up -silent && nuclei -ut -silent
                echo "${BLUE}Nuclei Sub-Domain Takeover scan for ${host}...${RESET}" | tee -a $NOTIFYYY
                nuclei -l $SAVEPATH/httpx_urls_$host.txt -tags takeover -silent -o $SAVEPATH/nuclei_subtk_$host.txt
                echo "${RED}Possible SubDomain Takeovers :-${RESET}" | tee -a $NOTIFYYY
                if [ -f "$SAVEPATH/nuclei_subtk_$host.txt" ]; then
                    cat $SAVEPATH/nuclei_subtk_$host.txt | awk '{print $3,$4,$5,$6}' | tee -a $NOTIFYYY 
                fi
                echo "${BLUE}Nuclei Sub-Domain Takeover Scan Done${RESET}" | tee -a $NOTIFYYY 
            fi
        }
        nucleiScanSUBS

        NucleiScan(){
            if [ -f "$savefilehttpxurls" ]; then       
                #updates nuclei && templates &&&& CENT tool
                nuclei -up -silent && nuclei -ut -ud ~/nuclei-templates/ -silent
                cent -p ~/cent-nuclei-templates -k &> /dev/null
                echo "${RED}Nuclei Vulnerability scan for ${host}...${RESET}" | tee -a $NOTIFYYY
                nuclei -l $SAVEPATH/live_$host.txt -t ~/nuclei-templates/ -t ~/cent-nuclei-templates/ -es info,unknown -etags takeover -et ~/nuclei-templates/workflows/http-missing-security-headers.yaml -silent -o $SAVEPATH/nucleiscan_$host.txt
                echo "${RED}Possible Vulnerabilities:-${RESET}" | tee -a $NOTIFYYY 
                if [ -f $SAVEPATH/nucleiscan_$host.txt ]
                then
                    cat $SAVEPATH/nucleiscan_$host.txt | awk '{print $3,$4,$5,$6}' | tee -a $NOTIFYYY
                else
                    echo "${RED}No Vulnerabilities Found !${RESET}" | tee -a $NOTIFYYY
                fi
                echo "${BLUE}Nuclei Vulnerability Scan Done${RESET}" | tee -a $NOTIFYYY
            fi
        }
        NucleiScan

        #Time Elapsed In Seconds Calculation---END 
        end=$(date +%s)
        runtime=$(python2 -c "print '%u:%02u' % ((${end} - ${start})/60, (${end} - ${start})%60)")
        echo ""
        echo "${GREEN}Runtime: ${RED}$runtime${RESET} ${GREEN}(minutes:seconds)${RESET}" | tee -a $NOTIFYYY

        #Number of Sub-Domains
        echo "${GREEN}The Total No of Sub-Domains Gathered:${RESET}${RED}$(wc -l $SAVEPATH/domains_$host 2> /dev/null | awk '{print $1}')${RESET}" | tee -a $NOTIFYYY
        
        #Number of Resolved Domains
        echo "${GREEN}The Total No of Resolved Sub-Domains:${RESET}${RED}$(wc -l $savefilednx 2> /dev/null | awk '{print $1}')$RESET" | tee -a $NOTIFYYY       

        #Number of Live Sub-Domains
        echo "${GREEN}The Total No of Live Sub-Domains:${RESET}${RED}$(wc -l $savefilehttpxurls 2> /dev/null | awk '{print $1}')$RESET" | tee -a $NOTIFYYY

        #Number of Sub-Domain Takeover's
        echo "${GREEN}No of Sub-Domains Takeover possible :${RESET}${RED}$(wc -l $SAVEPATH/nuclei_subtk_$host.txt 2> /dev/null | awk '{print $1}')${RESET}" | tee -a $NOTIFYYY
        
        #Number of Nuclei Vulnerabilities
        echo "${GREEN}No of Possible Vulnerabilities :${RESET}${RED}$(wc -l $SAVEPATH/nucleiscan_$host.txt 2> /dev/null | awk '{print $1}')${RESET}" | tee -a $NOTIFYYY 

        #Done statement for $host
        echo "${GREEN}Done Enumerating All Sub-Domains for ${RED}${host}${RESET}" | tee -a $NOTIFYYY

        # Send Details to Discord Server (Implement Notify in your environment and set provider config file)
        if [ -f $NOTIFYYY ]; then
            notify -data $NOTIFYYY -bulk -silent > /dev/null
        fi
}


USAGE(){

    echo -e "\n${BLUE}Flags:${RESET}"
    echo -e "${RED} -h, -help                      Show's usage"
    echo -e " -d, -domain                    Add your domain"
    echo -e " -f, -file                      List of Domains as domain_names.txt"
    echo -e " -a, -active                    Do Active Enumeration"
    echo -e " -p, -passive                   Do Passive Enumeration"
    echo -e " -P, -portscan                 Enable Naabu Port scan on found hosts${RESET}"
    echo -e ""    
    echo -e "${BLUE}Example Usage${RESET}"
    echo -e "${RED}Usage: subenum -d google.com [-a|-p] -P"
    echo -e "Usage: subenum -f PATH/TO/FILE [-a|-p] -P"
    echo -e "Usage: subenum -d google.com [-a|-p] -P"
    echo -e "Usage: subenum -f PATH/TO/domains.txt [-a|-p] -P${RESET}"
    echo -e ""
    echo -e "${BLUE}Optional Flags:${RESET}"
    echo -e "${RED}-a or -p to be used ( Optional default -a is used for Enumeration)${RESET}"
    echo -e "${RED}-P to do portscan on all alive domains${RESET}"
    echo -e ""
}

####################################################
VERSION="1.2"

#unset's the value assigned to variable : true -> 0
unset d_opt_bool
unset f_opt_bool
unset c_opt_bool
unset a_opt_bool
unset p_opt_bool
unset pscan_opt_bool

d_opt_bool=false        #To let know that -d is specified and used
f_opt_bool=false        #To let know that -f is specified and used
c_opt_bool=false        #To let know that -c is specified and used
a_opt_bool=false        #To let know that -a is specified and used
p_opt_bool=false        #To let know that -p is specified and used
pscan_opt_bool=false    #To let know that -ps is specified and used



# Process the other command line argument using getopts,while & case options
while getopts :d:f:apPhv option; do
  case $option in
    h|help)
            USAGE
            exit 0
            ;;

    a|active)
              a_opt_bool=true
              # a_value=$OPTARG
              ;;

    p|passive)
              p_opt_bool=true
              # p_value=$OPTARG
              ;;

    P|porscan)
              pscan_opt_bool=true
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

if [ ! -f ~/.config/subfinder/config.yaml ] || [ ! -f ~/.config/subfinder/provider-config.yaml ]
then
    echo "${BLINK}${RED}Error: Subfinder config.yaml & provider-config.yaml files not found${RESET}"
    exit 1
elif [ ! -f ~/.config/amass/config.yaml ] || [ ! -f ~/.config/amass/datasources.yaml ]
then
    echo "${BLINK}${RED}Error: Amass config.yaml and datasources.yaml files not found${RESET}"
    exit 1
elif [ ! -f ~/.config/notify/config.yaml ] || [ ! -f ~/.config/notify/provider-config.yaml ]
then
    echo "${BLINK}${RED}Error: Notify config.yaml & provider-config.yaml files not found${RESET}"
    exit 1
fi

resolverdownload(){
    resolverurl="https://raw.githubusercontent.com/trickest/resolvers/main/resolvers.txt"
    wget $resolverurl -q -P ~/tools/Wordlists -O resolvers.txt -N
    echo "${GREEN}Resolvers OK${RESET}"
    if [ $? -ne 0 ] ## checks whether the wget is done successfully or not!
    then
        echo -e "${RED}wget '${resolverurl}' failed !!! \nSet manually please${RESET}"
        exit 1
    fi
}

resolverdownload

wordlistdownload(){
    wordlistsurl="https://raw.githubusercontent.com/trickest/wordlists/main/inventory/subdomains.txt"
    wget $wordlistsurl -q -P ~/tools/Wordlists -N -O subdomains.txt
    echo -e "${GREEN}Wordlist Ok${RESET}"
    if [ $? -ne 0 ] ## checks whether the wget is done successfully or not!
    then
        echo "${RED}wget '${wordlistsurl}' failed !!!${RESET}"
        exit 1
    fi    
}

wordlistdownload

if [ "$a_opt_bool" != true ] && [ "$p_opt_bool" != true ] ; then
    a_opt_bool=true
    echo "${GREEN}Using ${RED}${BLINK}Active${RESET}"

fi

if [ -n "$host" ] && [ -z "$File1" ]; then
    if [ ! -f "$host" ]; then
        MAINSS 
    else
        echo "${BLUE}${BLINK}Given input is ${RED}file${BLUE} use option ${RED}-f${BLUE} to pass file as input${RESET}"
    fi 
elif [ -n "$File1" ] && [ -z "$host" ]; then
    if [ -f $File1 ]; then
            if [ "$f_opt_bool" == true ]; then
                resfolder="$HOME/results"
                if [ -d "$resfolder" ]
                then
                    echo ""
                    tree $resfolder -d -q -v
                fi 
                echo -e "${RED}Organization Name / Platform Name : ${RESET}" && read ORGNAME
            fi
            File2=$(cat ${File1})
            echo -e "${GREEN}Total No of Domains Found in this file:${RED}${BLINK} $(cat ${File1} | wc -l)${RESET}" 
            for host in $File2;do
                MAINSS 
            done
    else
        echo "${RED}${BLINK}Given File name does not EXISTS${RESET}"
    fi
elif [ -n "$host" ] && [ -n "$File1" ]; then
    echo "${BLINK}${RED}Used both -d & -f options\nUse either -d or -f options${RESET}"
    exit
fi

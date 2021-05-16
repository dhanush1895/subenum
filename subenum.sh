#!/bin/bash
echo "Enter domain name: " && read host

#amass
amass enum --passive -d $host -o domains_$host 
#if using config use command like this "amass enum -d host.com -config ./myconfigfile.ini"
echo "amass done"

#assetfinder
assetfinder -subs-only $host | tee -a domains_$host
echo "assetfinder done"

#subfinder
subfinder -d $host -all -silent | tee -a domains_$host
echo "subfinder done"

#findomain
findomain -t $host -q | tee -a domains_$host
echo "findomain done"

#Sublist3r
subls -d $host -t 30 -n -o subls_$host.txt && cat subls_$host.txt | tee -a domains_$host && rm subls_$host.txt
echo "Sublist3r done"

#github-subdomains-search
github-subd-search -d $host -t 224b061e1ac533e90728a1b5b800c932277d0ca7 -e | tee -a domains_$host
echo "github-subdomains-search done"

#filtering the domains
echo "filtering domains" 
sort -u domains_$host -o domains_$host
#cat domains_$host | filter-resolved | tee -a $host_domains.txt


# httpx live 
echo "filtering out live domains"
cat domains_$host | httpx -silent -threads 500 | tee live_$host.txt

echo "Done Enumerating all Sub-Domains for ${host}"



# V2 
## knockknock searchs/collects for internal website related URL's from one -target / -domain
#knockknock -n $host | cat domains.txt > related_$host_domains.txt
#echo "knockknock ${host} related_domains Done"
#

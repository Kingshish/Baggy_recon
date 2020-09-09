#!/bin/sh
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} Updating ${reset}"
echo '----------------------------------------------------------------------'
sudo apt-get update
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} Installing Go, Python, Ruby, git ${reset}"
echo '----------------------------------------------------------------------'
sudo apt-get install golang
sudo apt-get install python3
sudo apt-get install python3-pip
sudo apt-get install ruby
sudo apt-get install git
sudo apt-get install curl
sudo apt-get install jq
sudo apt-get install vim
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} Installing Go Programs ${reset}"
echo '----------------------------------------------------------------------'
go get -u github.com/tomnomnom/anew
GO111MODULE=on go get -v dw1.io/crlfuzz/cmd/crlfuzz  
GO111MODULE=on go get -u -v github.com/lc/gau
go get -u github.com/jaeles-project/gospider
go get -u github.com/tomnomnom/httprobe
GO111MODULE=on go get github.com/jaeles-project/jaeles
git clone https://github.com/projectdiscovery/nuclei.git; cd nuclei/cmd/nuclei/; go build; cp nuclei ~/go/bin/; cd ~;nuclei -h
GO111MODULE=auto go get -u -v github.com/projectdiscovery/subfinder/cmd/subfinder
go get github.com/tomnomnom/hacks/waybackurls
go get -u github.com/tomnomnom/assetfinder
git clone https://github.com/ghostlulzhacks/waybackMachine.git
GO111MODULE=on go get -u -v github.com/hahwul/dalfox
go get github.com/ffuf/ffuf
go get -u github.com/tomnomnom/gf
GO111MODULE=on go get -u -v github.com/projectdiscovery/httpx/cmd/httpx
go get -u github.com/tomnomnom/qsreplace
git clone https://github.com/1ndianl33t/Gf-Patterns
mkdir ~/.gf
cp ~/Gf-Patterns/* ~/.gf/
echo 'source ~/go/src/github.com/tomnomnom/gf/gf-completion.bash' >> ~/.bashrc
git clone https://github.com/projectdiscovery/nuclei-templates nuclei-templates
git clone --depth=1 https://github.com/jaeles-project/jaeles-signatures /tmp/jaeles-signatures/
echo '______________________________________________________________________'
echo  "${red} Performing : ${green} Adding to bashrc ${reset}"
echo '----------------------------------------------------------------------'
echo "
alias ffuf=~/go/bin/ffuf
alias httpx=~/go/bin/httpx
alias gau=~/go/bin/gau
alias anew=~/go/bin/anew
alias crlfuzz=~/go/bin/crlfuzz
alias gospider=~/go/bin/gospider
alias httprobe=~/go/bin/httprobe
alias nuclei=~/go/bin/nuclei
alias jaeles=~/go/bin/jaeles
alias subfinder=~/go/bin/subfinder
alias dalfox=~/go/bin/dalfox
alias gf=~/go/bin/gf
alias qsreplace=~/go/bin/qsreplace
" >> ~/.bashrc
source .bashrc

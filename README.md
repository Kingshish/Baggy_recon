# Baggy_recon

I've written a Medium Post about this:
https://medium.com/@sherwyn.moodley/building-a-bug-bounty-box-in-aws-dcc691417833

Some steps if you've just setup the kali instance on AWS:

1. ssh into the instance
2. apt-get update   -- to update the repos and things
3. apt-get install git -- to install git
4. git clone https://github.com/Kingshish/Baggy_recon.git    -- to clone this repo to the machine
5. cp Baggy_recon/setup.sh . -- to copy the setup script to home directory
6. chmod +x setup.sh -- to make the script executable , this is usually not a great idea but the permissions should be okay here
7. ./setup.sh
8.source .bashrc 


setup.sh
Updates Kali
Installs needed applications

recon.sh
create a text file called scope.txt with list of domains to investigate
run recon.sh to run applications to recon target and find potential vulnerabilities

## GoDaddyDNS

Lets say you dont have a static DNS but you need to be able to connect back into your network for something (VPN, IoT thingamabob, etc.). What do you do? Well, you could use dynamic DNS (DDNS) but that means making changes in your router and relying on someone else to keep up with your external IP address. It also means you may not have a nice (easy to remember) DNS name to refer back to your home network. Is there a better way? ABSOLUTELY! Get a domain name from GoDaddy for a few dollars a year, run this shell script, and you are set!

### System Requirments

Simple enough: 
- A Linux based system (a Raspberry Pi is cheap enough if you dont already have a Linux system!)
- cURL installed on the Linux system 
    -Debian/Ubuntu: `sudo apt install curl`
- ssmpt installed on the Linux system 
    -Debian/Ubuntu: `sudo apt install ssmtp`
- Access to run this program as root 
    -`sudo i` or `su -`

### Installation

- From a command prompt
    - `git clone https://github.com/dr-b-io/GoDaddyDNS.git`
- Copy GoDaddyDNS.config.dist
    - `cp GoDaddyDNS.config.dist GoDaddyDNS.config`
- Open GoDaddyDNS.confg in your favorite text editor, replace entries with your information
- Log in as root
    - `sudo -i`
- Navigate to the directory 
    - `cd /path/to/repo`
- Execute! 
    - `. ./GoDaddyDNS.shl`
- Profit!

### But wait, theres more!

What happens if your IP address changes - those pesky ISP's will change things up on you if you are not careful! Again, an easy solution: set up a cron job to run this script on a recurring schedule. How often you ask? That is up to you! How long will you be able to survive if your IP address changes and you cannot easily view that $10 survelance camera you got from aliexpress? I would think running the process once per hour should be enough, but do what you want...

- As root 
    - `sudo -i` 
- Edit your cron jobs 
    - `crontab -e` 
- Add this job to the end of the file 
    - `*/5 * * * * . /path/to/GoDaddyDNS.shl`

Just like that, you are automagically updating the interwebs!
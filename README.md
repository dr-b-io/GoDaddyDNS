## GoDaddyDNS

Lets say you dont have a static IP address but you need to be able to connect back into your network for something (VPN, IoT thingamabob, whatever - its none of my business). What do you do? Well, you could use dynamic DNS (DDNS) but that means making changes in your router and relying on someone else to keep up with your external IP address. Some DDNS services are free but I have never had good luck with them, maybe they work better for you. If you use DDNS you may not have a nice (easy to remember) DNS name to refer back to your home network. Is there a better way? ABSOLUTELY! Get a domain name from GoDaddy for a few dollars a year, run this shell script, and you are set!

### System Requirments

Simple enough: 
- A Linux based system
    - A Raspberry Pi is cheap enough
    - Reuse the Windows 7 PC that you have not upgraded to Windows 10 yet
    - +1 geek point if you build a virtual machine!
- cURL installed
    -Debian/Ubuntu: `sudo apt install curl`
- ssmpt installed
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

### But wait, THERE'S MORE!!!

What happens if your IP address changes - those pesky ISP's will change things up on you if you are not careful! Again, an easy solution: set up a cron job to run this script on a recurring schedule. How often you ask? That is up to you! How long will you be able to survive if your IP address changes and you cannot easily watch that $10 survelance camera you got from aliexpress? You know, the one that is sending videos of you walking around naked back to the motherland (China). Again, its none of my business what you do. I would think running the process once per hour should be enough, but do what you want.

- As root 
    - `sudo -i` 
- Edit your cron jobs 
    - `crontab -e` 
- Add this job to the end of the file 
    - `*/5 * * * * . /path/to/GoDaddyDNS.shl`

Just like that, you are automagically updating the interwebs!

### DISCLAIMER

Use this software at your own risk. No warranty is written or implied. dr-b-io cannot be held responsible for any direct or indirect damages caused by the use of this software. 
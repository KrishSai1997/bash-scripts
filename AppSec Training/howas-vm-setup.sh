#!/bin/bash

# Purpose: This script is intended for use with the AOL Training course - "Hands on Application Security (Behind the Curtain)". It will install required tools and libraries onto a Debian-based (virtual) machine.
# Additional configuration should be performed when building a new VM to deploy/deliver for students.

# Written by: Chris Holt
# Original Publication: 2017-04-19
# Updated: 2017-08-21
# built for Kali_4.11.0

# TODO: Add checks to ensure that each section completed successfully. Notify user if anything failed.
# TODO: Ping the eclipse endpoint before downloading from it to ensure it can be downloaded
# TODO: Add prompts or run-options to create scripts, install software, kickoff apps -- Does that turn this script into an init.d 'does it all' thing? is that a bad idea?
# TODO: Figure out how to move this to base-Debian instead of Kali. This will require install package commands for: burpsuite, firefox-esr, sslscan
# TODO: change the names of the webgoat, dvwa scripts to match each other. Combine build+deploy steps where needed
# TODO: Build install scripts for another vulnerable web app.
# TODO: Rebuild VM with the name "The_Curtain_v0.4"
# TODO: Figure out how to script 'Delete Firefox configs' so it reverts to blank settings; Delete all Bookmarks; Add app bookmarks?
# TODO: test the "passwords" script. Make sure that each block APPENDS to the file. Check it is executable. check formatting of the file/output
# TODO: add --yes parameter check to the 'reset' scripts to reduce code re-writing in this script. Then, for setting up apps the first time, just call `app-reset --yes`
# TODO: Ask user if running in vbox or vmware to select appropriate addons package to install
# TODO: set the hostname for the VM
# TODO: change the desktop image
# TODO: change "update" to "build"; requires edits to Module docs

########################
# OS Setup Scripts
#@@@@
mkdir ~/Desktop/howas_scripts/setup -p
 # install os updates
cat <<EOF > /usr/bin/os_update.sh
#!/bin/bash
echo -n "Update the OS. Causes the system to reboot."
echo -n "[Enter] to continue. [ctrl+c] to quit."
read DOIT

apt update
apt-get -y dist-upgrade
apt-get autoremove
apt-get autoclean
reboot

EOF
chmod 755 /usr/bin/os_update.sh
ln -s /usr/bin/os_update.sh ~/Desktop/howas_scripts/setup/os_update.sh
#@@@@
#####
 # Script to install vmtools for VMWare Machine
cat <<EOF > /usr/bin/install_tools_VMWare.sh
#!/bin/bash
echo -n "Install vmtools for VMWare. Causes the system to reboot."
echo -n "[Enter] to continue. [ctrl+c] to quit."
read DOIT

apt update
apt install -y open-vm-tools-desktop fuse
echo "Please run \"reboot\" to reboot the machine."
reboot

EOF
chmod 755 ~/Desktop/install_tools_VMWare.sh
ln -s /usr/bin/install_tools_VMWare.sh ~/Desktop/howas_scripts/setup/install_tools_VMWare.sh
#####
#$$$$
 # Script to install vmtools for VirtualBox
cat <<EOF > /usr/bin/install_tools_VirtualBox.sh
#!/bin/bash
echo -n "Install vmtools for VirtualBox. Causes the system to reboot."
echo -n "[Enter] to continue. [ctrl+c] to quit."
read DOIT

apt-get update
apt-get -y install virtualbox-guest-x11
echo "Please run \"reboot\" to reboot the machine."
reboot

EOF
chmod 755 ~/Desktop/install_tools_VirtualBox.sh
ln -s /usr/bin/install_tools_VirtualBox.sh ~/Desktop/howas_scripts/setup/install_tools_VirtualBox.sh
#$$$$
#%%%%
 # create Passwords script
cat <<EOF > /usr/bin/passwords
echo "Passwords for the locally hosted applications are as follows (unless you changed them!)."
echo -n "[Enter] to continue. [ctrl+c] to quit."
read DOIT

echo ""

EOF
chmod 755 /usr/bin/passwords
ln -s /usr/bin/passwords ~/Desktop/howas_scripts/passwords.sh
#%%%%
# set the favorites bar app shortcuts
dconf write /org/gnome/shell/favorite-apps "['firefox-esr.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'kali-burpsuite.desktop', 'eclipse.desktop']"
########################

########################
# WebGoat
#@@@@
 # create WebGoat script - reload
 mkdir ~/Desktop/howas_scripts/webgoat -p
cat <<EOF > /usr/bin/goat-reload
#!/bin/bash
echo -n "Update WebGoat by building from source and deploying to the tomcat server."
echo -n "[Enter] to continue. [ctrl+c] to quit."
read DOIT

goat-build
goat-deploy

EOF
chmod 755 /usr/bin/goat-reload
ln -s /usr/bin/goat-reload ~/Desktop/howas_scripts/webgoat/goat-reload.sh
#@@@@
#####
  # create WebGoat script - deploy
cat <<EOF > /usr/bin/goat-deploy
#!/bin/bash
echo -n "Deploy WebGoat WAR file to the tomcat server."
echo -n "[Enter] to continue. [ctrl+c] to quit."
read DOIT

cd ~/Documents/WebGoat
mvn -pl webgoat-container tomcat7:run-war

EOF
chmod 755 /usr/bin/goat-deploy
ln -s /usr/bin/goat-deploy ~/Desktop/howas_scripts/webgoat/goat-deploy.sh
#####
#$$$$
  # create WebGoat script - build
# test this, new lines added to delete jars in case of bad-build scenario
cat <<EOF > /usr/bin/goat-build
#!/bin/bash
echo -n "Build the WebGoat code into a deployable WAR file."
echo -n "[Enter] to continue. [ctrl+c] to quit."
read DOIT

cd ~/Documents/WebGoat-Lessons
rm *.jar ../WebGoat/webgoat-container/src/main/webapp/plugin_lessons/
rm *.jar target/plugins/
mvn package
cp target/plugins/*.jar ../WebGoat/webgoat-container/src/main/webapp/plugin_lessons/
echo "Update complete, please redeploy"

EOF
chmod 755 /usr/bin/goat-build
ln -s /usr/bin/goat-build ~/Desktop/howas_scripts/webgoat/goat-build.sh
#$$$$
#%%%%
  # create WebGoat script - reset
cat <<EOF > /usr/bin/goat-reset
#!/bin/bash
echo -n "Reset WebGoat to a new installation."
echo -n "This script will erase all data in your WebGoat folders. Are you sure you want to do this? [YES]: "
read DOIT

if [[ "\$DOIT" = "YES" ]]; then
echo "Alright, deleting everything and getting a new batch...."
sleep 3
cd ~/Documents
rm target -r
rm WebGoat -r
rm WebGoat-Lessons -r

echo "Getting new installation of WebGoat 7.1"
cd ~/Documents
git clone https://github.com/WebGoat/WebGoat.git
git clone https://github.com/WebGoat/WebGoat-Lessons.git
cd ~/Documents/WebGoat
git checkout master
git pull
mvn clean compile install
cd ~/Documents/WebGoat-Lessons
git checkout master
git pull
mvn package
cp target/plugins/*.jar ../WebGoat/webgoat-container/src/main/webapp/plugin_lessons/

else
echo "Safe choice, maybe you can fix it."
fi

EOF
chmod 755 /usr/bin/goat-reset
ln -s /usr/bin/goat-reset ~/Desktop/howas_scripts/webgoat/goat-reset.sh
#%%%%
#&&&&
  # create WebGoat desktop shortcut
cat <<EOF > ~/Desktop/WebGoat.desktop
[Desktop Entry]

Encoding=UTF-8
Name=Open WebGoat
Type=Link
URL=http://localhost:8080/WebGoat
Icon=text-html

EOF
#&&&&

  #drop passwords into the script file
cat <<EOF >> /usr/bin/passwords
echo "--WebGoat--"
echo "  username: goat"
echo "  password: goat"
echo ""

EOF

  # get required tools for dev environment
apt-get update
apt-get install -y maven default-jdk
apt-get autoremove
apt-get autoclean

  # do the initial checkout/install
cd ~/Documents
git clone https://github.com/WebGoat/WebGoat.git
git clone https://github.com/WebGoat/WebGoat-Lessons.git
cd ~/Documents/WebGoat
git checkout master
git pull
mvn clean compile install
cd ~/Documents/WebGoat-Lessons
git checkout master
git pull
mvn package
cp target/plugins/*.jar ../WebGoat/webgoat-container/src/main/webapp/plugin_lessons/
# echo "goat-get-new" > /usr/bin/goat-reset
chmod 755 /usr/bin/goat-reset
###########################

###########################
# eclipse

 # Download and install eclipse
cd /tmp
curl -O http://mirror.csclub.uwaterloo.ca/eclipse/technology/epp/downloads/release/neon/3/eclipse-jee-neon-3-linux-gtk-x86_64.tar.gz
tar xvzf eclipse-jee-neon-3-linux-gtk-x86_64.tar.gz
mv eclipse /opt/eclipse
ln -s /opt/eclipse/eclipse /usr/bin/eclipse
rm eclipse-jee-neon-3-linux-gtk-x86_64.tar.gz
mkdir ~/Documents/eclipse-work

 # create shortcut in Applications launcher
cat <<EOF > /usr/share/applications/eclipse.desktop
[Desktop Entry]

Name=Eclipse
Exec=/opt/eclipse/eclipse
Terminal=false
Type=Application
Categories=IDE
Icon=/opt/eclipse/icon.xpm

EOF

 # set preferences for last launch
cat <<EOF > /opt/eclipse/configuration/.settings/org.eclipse.ui.ide.prefs
MAX_RECENT_WORKSPACES=10
RECENT_WORKSPACES=/root/Documents/eclipse-work
RECENT_WORKSPACES_PROTOCOL=3
SHOW_RECENT_WORKSPACES=false
SHOW_WORKSPACE_SELECTION_DIALOG=false
eclipse.preferences.version=1

EOF
###########################

###########################
# DVWA
  # src: https://github.com/ethicalhack3r/DVWA
  # ref: https://medium.com/@TheShredder/create-your-ethical-hacking-environment-install-dvwa-into-your-kali-linux-4783282dea6a

mkdir ~/Desktop/howas_scripts/dvwa -p
mkdir ~/Desktop/howas_scripts/system -p

  # create DVWA script - on
cat <<EOF > /usr/bin/dvwa-on
#!/bin/bash
echo -n "Turn DVWA web server on."
echo -n "[Enter] to continue. [ctrl+c] to quit."
read DOIT

sphp5
service apache2 start && service mysql start

EOF
chmod 755 /usr/bin/dvwa-on
ln -s /usr/bin/dvwa-on ~/Desktop/howas_scripts/dvwa/dvwa-on.sh

  # create DVWA script - off
cat <<EOF > /usr/bin/dvwa-off
#!/bin/bash
echo -n "Turn DVWA web server off."
echo -n "[Enter] to continue. [ctrl+c] to quit."
read DOIT

service apache2 stop && service mysql stop
sphp7

EOF
chmod 755 /usr/bin/dvwa-off
ln -s /usr/bin/dvwa-off ~/Desktop/howas_scripts/dvwa/dvwa-off.sh

  # create DVWA script - finish
cat <<EOF > /usr/bin/dvwa-finish
#!/bin/bash
echo -n "Final installation step for DVWA."
echo -n "[Enter] to continue. [ctrl+c] to quit."
read DOIT

echo "To finish setting up, create the database."
sleep 3
dvwa-on
firefox http://127.0.0.1/dvwa/setup.php &

EOF
chmod 755 /usr/bin/dvwa-finish
ln -s /usr/bin/dvwa-finish ~/Desktop/howas_scripts/dvwa/dvwa-finish.sh

  # create DVWA script - reset
cat <<EOF > /usr/bin/dvwa-reset
#!/bin/bash
echo -n "Reset DVWA to a new installation."
echo -n "This script will erase all data in your DVWA folders. Are you sure you want to do this? [YES]: "
read DOIT

if [[ "\$DOIT" = "YES" ]]; then
echo "Alright, deleting everything and getting a new batch...."
sleep 3
service apache2 stop && service mysql stop
rm -r /var/www/html/dvwa
cd /var/www/html
wget https://github.com/RandomStorm/DVWA/archive/v1.9.zip && unzip v1.9.zip
mv DVWA-1.9 /var/www/html/dvwa
rm v1.9.zip
chmod -R 777 dvwa
service mysql start
mysql -u root <<SQ
CREATE DATABASE dvwa;
CREATE USER 'user'@'127.0.0.1' IDENTIFIED BY 'p@ssword';
GRANT ALL ON dvwa.* TO 'user'@'127.0.0.1';
FLUSH PRIVILEGES;
exit

SQ

service mysql stop
sed -i -e "s/'root'/'user'/1" /var/www/html/dvwa/config/config.inc.php
sed -i -e "s/'p@ssw0rd'/'p@ssword'/1" /var/www/html/dvwa/config/config.inc.php
sed -i -e "s/'impossible'/'low'/1" /var/www/html/dvwa/config/config.inc.php
sed -i -e 's/allow_url_include = Off/allow_url_include = On/1' /etc/php5/apache2/php.ini
sed -i -e 's/allow_url_fopen = Off/allow_url_fopen = On/1' /etc/php5/apache2/php.ini
dvwa-finish
else
echo "Safe choice, maybe you can fix it."
fi

EOF
chmod 755 /usr/bin/dvwa-reset
ln -s /usr/bin/dvwa-reset ~/Desktop/howas_scripts/dvwa/dvwa-reset.sh

 # create scripts for switching php versions
 # ref: http://www.magleaks.com/running-php-5-and-php-7-on-same-environment-ubuntu/
  # create 'switch to php5' script - sphp5
cat <<EOF  > /usr/bin/sphp5
#!/bin/bash
echo -n "Set to php5."
sudo a2enmod php5 && sudo a2dismod php7.0 && sudo ln -sfn /usr/bin/php5 /etc/alternatives/php && sudo service apache2 restart && php -v

EOF
chmod 755 /usr/bin/sphp5
ln -s /usr/bin/sphp5 ~/Desktop/howas_scripts/system/set_php5.sh

  # create 'switch to php7' script - sphp7
cat <<EOF > /usr/bin/sphp7
#!/bin/bash
echo -n "Set to php7."
sudo a2dismod php5 && sudo a2enmod php7.0 && sudo ln -sfn /usr/bin/php7.0 /etc/alternatives/php && sudo service apache2 restart && php -v

EOF
chmod 755 /usr/bin/sphp7
ln -s /usr/bin/sphp7 ~/Desktop/howas_scripts/system/set_php7.sh

 # create DVWA shortcut
cat <<EOF  > ~/Desktop/DVWA.desktop
[Desktop Entry]

Encoding=UTF-8
Name=Open DVWA
Type=Link
URL=http://127.0.0.1/dvwa/login.php
Icon=text-html

EOF

#drop passwords into the script file
cat <<EOF >> /usr/bin/passwords
echo "--Damn Vulnerable Web App (DVWA)-- "
echo "  username: admin"
echo "  password: password"
echo ""

EOF
  # get required libraries for DVWA
    # backup the sources list, add new source, install, restore original
cp /etc/apt/sources.list /etc/apt/sources.list.bak
echo 'deb http://old.kali.org/kali sana main non-free contrib' >> /etc/apt/sources.list
apt-get update
apt-get install -y php5 php5-mysql php5-gd
apt-get autoremove
apt-get autoclean
rm /etc/apt/sources.list
mv /etc/apt/sources.list.bak /etc/apt/sources.list
  # If using the captcha module, keys will need to be generated and installed to /var/www/html/dvwa/config/config.inc.php
cd /var/www/html
wget https://github.com/RandomStorm/DVWA/archive/v1.9.zip && unzip v1.9.zip
mv DVWA-1.9 /var/www/html/dvwa
rm v1.9.zip
chmod -R 777 dvwa
service mysql start
mysql -u root <<SQ
CREATE DATABASE dvwa;
CREATE USER 'user'@'127.0.0.1' IDENTIFIED BY 'p@ssword';
GRANT ALL ON dvwa.* TO 'user'@'127.0.0.1';
FLUSH PRIVILEGES;
exit

SQ
service mysql stop
sed -i -e "s/'root'/'user'/1" /var/www/html/dvwa/config/config.inc.php
sed -i -e "s/'p@ssw0rd'/'p@ssword'/1" /var/www/html/dvwa/config/config.inc.php
sed -i -e "s/'impossible'/'low'/1" /var/www/html/dvwa/config/config.inc.php
sed -i -e 's/allow_url_include = Off/allow_url_include = On/1' /etc/php5/apache2/php.ini
sed -i -e 's/allow_url_fopen = Off/allow_url_fopen = On/1' /etc/php5/apache2/php.ini
sphp5
service apache2 start && service mysql start
echo "To finish setting up, create the database."
sleep 3
firefox http://127.0.0.1/dvwa/setup.php &
###########################

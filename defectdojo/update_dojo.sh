#!/bin/bash
#
# by Chris Holt
# @humor4fun
# 2017-03-01
#
# Script to perform tasks required to pull down latest code for Defect Dojo, apply updates, migrate database to new version. You'll want to only run this when nobody is running reports, or really using the system as it does a non-graceful restart of services

LOGFILE="/home/dojo/update_dojo.log"
cd /home/dojo/django-DefectDojo
echo -e "Starting Defect Dojo git updates...\n" >> "$LOGFILE"

echo -e "=====================================================" >> "$LOGFILE"
echo -e "Date:\n" >> "$LOGFILE" 
date >> "$LOGFILE"
echo -e "=====================================================\n" >> "$LOGFILE"

echo -e "=====================================================" >> "$LOGFILE"
echo -e "git stash save --keep-index:\n" >> "$LOGFILE" 
sudo git stash save --keep-index | tee -a "$LOGFILE"
echo -e "=====================================================\n" >> "$LOGFILE"

echo -e "=====================================================" >> "$LOGFILE"
echo -e "git checkout master:\n" >> "$LOGFILE" 
sudo git checkout master | tee -a "$LOGFILE"
echo -e "=====================================================\n" >> "$LOGFILE"

echo -e "=====================================================" >> "$LOGFILE"
echo -e "git pull:\n" >> "$LOGFILE" 
sudo git pull | tee -a "$LOGFILE"
echo -e "=====================================================\n" >> "$LOGFILE"

echo -e "=====================================================" >> "$LOGFILE"
echo -e "./manage.py makemigrations dojo:\n" >> "$LOGFILE"
sudo ./manage.py makemigrations dojo | tee -a "$LOGFILE"
echo -e "=====================================================\n" >> "$LOGFILE"

echo -e "=====================================================" >> "$LOGFILE"
echo -e "./manage.py makemigrations:\n" >> "$LOGFILE"
sudo ./manage.py makemigrations | tee -a "$LOGFILE"
echo -e "=====================================================\n" >> "$LOGFILE"

echo -e "=====================================================" >> "$LOGFILE"
echo -e "./manage.py migrate:\n" >> "$LOGFILE"
sudo ./manage.py migrate | tee -a "$LOGFILE"
echo -e "=====================================================\n" >> "$LOGFILE"

echo -e "=====================================================" >> "$LOGFILE"
echo -e "bower install:\n" >> "$LOGFILE"
cd components
bower install | tee -a "$LOGFILE"
cd ..
echo -e "=====================================================\n" >> "$LOGFILE"

echo -e "=====================================================" >> "$LOGFILE"
echo -e "./manage.py collectstatic:\n" >> "$LOGFILE"
cd ..
sudo ./manage.py collectstatic --noinput | tee -a "$LOGFILE"
echo -e "=====================================================\n" >> "$LOGFILE"

echo -e "=====================================================" >> "$LOGFILE"
echo -e "Installing any new python components:\n" >> "$LOGFILE"
sudo read d < <(curl -s -S https://raw.githubusercontent.com/OWASP/django-DefectDojo/master/setup.py | sed "s/[',> \t]//g" | sed '/install_requires=\[/,/\],/!d;s/install_requires=\[//g;s/\[//g;s/\]//g;s/=.*//1;/dependency_links$/,$d;s/[0-9]\.[0-9]//g' | tail -n 2 | sed ':a;N;$!ba;s/\n/ /g') && sudo pip install --ignore-installed $d | tee -a "$LOGFILE"
echo -e "=====================================================\n" >> "$LOGFILE"

echo -e "=====================================================" >> "$LOGFILE"
echo -e "Fetching updated scripts:\n" >> "$LOGFILE"
echo -e "curl https://raw.githubusercontent.com/humor4fun/bash-scripts/master/defectdojo/update_dojo.sh -o update_dojo\n" >> $LOGFILE
curl https://raw.githubusercontent.com/humor4fun/bash-scripts/master/defectdojo/update_dojo.sh -o update_dojo | tee -a "$LOGFILE"
echo -e "curl https://raw.githubusercontent.com/humor4fun/bash-scripts/master/defectdojo/status_dojo.sh -o status_dojo\n" >> $LOGFILE
curl https://raw.githubusercontent.com/humor4fun/bash-scripts/master/defectdojo/status_dojo.sh -o status_dojo | tee -a "$LOGFILE"
echo -e "curl https://raw.githubusercontent.com/humor4fun/bash-scripts/master/defectdojo/startup_dojo.sh -o startup_dojo\n" >> $LOGFILE
curl https://raw.githubusercontent.com/humor4fun/bash-scripts/master/defectdojo/startup_dojo.sh -o startup_dojo | tee -a "$LOGFILE"
chmod 755 *_dojo
echo -e "=====================================================\n" >> "$LOGFILE"

#Next we need to restart gunicorn and celery. Google showed me these commands, but I haven't proved that they work, so I'll just perform a reboot and let the startup script handle restarting these services
################
#ps aux |grep gunicorn |grep projectname | awk '{ print $2 }' |xargs kill -HUP
#sudo ps auxww | grep celeryd | grep -v "grep" | awk '{print $2}' | sudo xargs kill -HUP
####################

echo -e "=====================================================" >> "$LOGFILE"
echo -e "Rebooting now:" >> "$LOGFILE"
date >> "$LOGFILE"
echo -e "=====================================================\n\n" >> "$LOGFILE"
shutdown -r now


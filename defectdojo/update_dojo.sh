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
./manage.py collectstatic --noinput | tee -a "$LOGFILE"
echo -e "=====================================================\n" >> "$LOGFILE"

echo -e "=====================================================" >> "$LOGFILE"
echo -e "Fetching updated scripts:\n" >> "$LOGFILE"
echo -e "curl -O https://raw.githubusercontent.com/humor4fun/bash-scripts/master/defectdojo/update_dojo.sh > update_dojo\n" >> $LOGFILE
curl -O https://raw.githubusercontent.com/humor4fun/bash-scripts/master/defectdojo/update_dojo.sh > update_dojo | tee -a "$LOGFILE"
echo -e "curl -O https://raw.githubusercontent.com/humor4fun/bash-scripts/master/defectdojo/status_dojo.sh > status_dojo\n" >> $LOGFILE
curl -O https://raw.githubusercontent.com/humor4fun/bash-scripts/master/defectdojo/status_dojo.sh > status_dojo | tee -a "$LOGFILE"
echo -e "curl -O https://raw.githubusercontent.com/humor4fun/bash-scripts/master/defectdojo/startup_dojo.sh > startup_dojo\n" >> $LOGFILE
curl -O https://raw.githubusercontent.com/humor4fun/bash-scripts/master/defectdojo/startup_dojo.sh > startup_dojo | tee -a "$LOGFILE"
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


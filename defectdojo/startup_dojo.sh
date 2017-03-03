#!/bin/bash
#2017-01-10 by Chris Holt (@humor4fun)
# Gets the required bits started for Defect Dojo
# Recommended to have this run at system boot so Dojo will always run at system startup

#start the server up in a terminal with profile settings set to HOLD the window on process exit
gnome-terminal --working-directory=/home/dojo/django-DefectDojo --window-with-profile=cronterm --display=:0.0 --execute python manage.py runserver
sleep 5

#kickoff the nginx server if it is not already started
sudo service nginx start
sleep 10

#start the Celery services for report generation
gnome-terminal --working-directory=/home/dojo/django-DefectDojo --window-with-profile=cronterm --display=:0.0 --execute celery -A dojo worker -l info --concurrency 3
sleep 5
gnome-terminal --working-directory=/home/dojo/django-DefectDojo --window-with-profile=cronterm --display=:0.0 --execute celery beat -A dojo -l info
sleep 5

#run heartbeat tests for django and nginx
gnome-terminal --working-directory=/home/dojo/ --window-with-profile=cronterm --display=:0.0 --execute ./status_dojo

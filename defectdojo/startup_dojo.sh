#!/bin/bash
#2017-01-10 by Chris Holt (@humor4fun)
#gets the required bits started for Defect Dojo



#start the server up in a terminal with profile settings set to HOLD the window on process exit
gnome-terminal --working-directory=/home/dojo/django-DefectDojo --window-with-profile=cronterm --display=:0.0 --execute python manage.py runserver

#give django plenty of time to start up
sleep 5

#kickoff the nginx server if it is not already started
sudo service nginx start

#give nginx and django plenty of time to start up
sleep 10

#run heartbeat tests for django and nginx
gnome-terminal --working-directory=/home/dojo/ --window-with-profile=cronterm --display=:0.0 --execute ./status-dojo

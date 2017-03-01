#!/bin/bash
#2017-01-10 by Chris Holt (@humor4fun)
#gets the required bits started for Defect Dojo

#start the server up in a terminal with profile settings set to HOLD the window on process exit
gnome-terminal --working-directory=/home/dojo/django-DefectDojo --window-with-profile=cronterm --display=:0.0 --execute python manage.py runserver

#wait for the server to start up
sleep 5

#open a window to see that you can connect to the server
#firefox https://127.0.0.1:8000 http://127.0.0.1:8000
firefox https://your.domain.com http://your.domain.com http://localhost https://localhost http://127.0.0.1:8000

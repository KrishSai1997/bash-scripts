alias ipconfig='sudo ifconfig $(ifconfig -a | grep -o "en\w*") up && sudo dhclient'
alias reboot='sudo reboot'

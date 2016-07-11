#!/bin/bash

# 
# We will almost certainly will mount an external volume to hold 
# the 'guest' user directory (so that their work persists between
# container restarts). However, there is no guarantee that the
# container user owns or can write to that external volume, so
# make sure they own their home directory
#
chown -R guest ~guest ; chgrp -R users ~guest
chown -R shiny.shiny /srv/shiny-server
sudo chown -R shiny.shiny /var/log/shiny-server

#
# set the passwords for the user 'guest' based on environment variable. 
#

if [ ! -z $USERPASS ] 
then
  /bin/echo "guest:$USERPASS" | /usr/sbin/chpasswd
  unset USERPASS
fi


#
# set the MAGIC_TOKEN environment variable where it will be easy for R to get it
#

if [ ! -z $MAGIC_TOKEN ]
then
/bin/echo "# set the MAGIC_TOKEN environment variable for R" >> /etc/R/Renviron.site
/bin/echo "MAGIC_TOKEN=$MAGIC_TOKEN"  >> /etc/R/Renviron.site
fi

exit 0


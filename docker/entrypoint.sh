#!/bin/sh
cd /app
sudo /app/helper/add_ca.sh
sudo /app/helper/rm_sudo.sh
$@

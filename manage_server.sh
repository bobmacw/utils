#!/bin/bash 
 
##
# start|stop|restart python SimpleHTTPServer
#
# TODO:
#	  use shell Function for DRY
# USAGE:
#   ./manage_server.sh start|stop|restart
#
# VIEW:
#   http://localhost:8000
 
# cd /usr/local/system/projects/entos/external/workspace 
 
case $1 in
	"start" )
                echo "start python SimpleHTTPServer"
		nohup python -m SimpleHTTPServer > /tmp/nohup.out &
		;;
	"stop" )
		echo "stop python SimpleHTTPServer"
		kill `ps aux | grep "python -m SimpleHTTPServer"` | grep -v grep | awk '{print $2}' > /dev/null 
		;;
	"restart" )
		echo "restart python SimpleHTTPServer"
  	        kill `ps aux | grep "python -m SimpleHTTPServer"` | grep -v grep | awk '{print $2}' > /dev/null 
		nohup python -m SimpleHTTPServer > /tmp/nohup.out &
		;;
	*)
		echo "need start|stop|restart"
		exit 1
esac

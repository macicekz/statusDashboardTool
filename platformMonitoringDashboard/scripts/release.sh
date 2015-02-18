#!/bin/sh

#  release.sh
#  
#  Sets up dashboard during release
#
#  ./release.sh [-] sedthHn
#   -s [Release started]  -e [release ended] -d [Data Center] -t [TICKET_URL parenthness has to been used "https:/#jira.intgdc.com/browse/WA-4071"] -H [update HISTORY Y/N] -n [NOTE added to comment] -h [Run Help] -help [Run Help]
#
#
#  Created by Zdenek Macicek on 14.02.15.
#
#----------------------------------------------------------------------
#----------------------------------------------------------------------
PROGNAME=$(basename $0)

echo "" #new row
echo "- Info : $LINENO: $PROGNAME : START release update ..."
echo "- Info : $LINENO: $PROGNAME : info : Reading user configuration. "

source ../conf/user.cfg
T_HOME=$TOOL_HOME
CUSER=$CONF_USER
CAPI_URL=$API_URL

checkToken  #check authentication token

#Checking number of parameters
if [ $# -eq 0 ]; then
    error_exit "$LINENO: Sorry, NO parametr given."
else
    echo "- Info : $LINENO: $PROGNAME : Starting reading of parametrs ...... "
fi

#Reading parameters
while [ $# -gt 0 ]
do
    P=$1
    case $P in
        -s) #release started
        ;;
        -e) #release ended
        ;;
        -d) DC=$2
        ;;
        -t) TICKET_URL=$2
        ;;
        -n) NOTE=$2
        ;;
        -H) HISTORY_FLAG=false
        ;;
        -n) NOTE=$2
        ;;
        -h) #_TODO_ run help
        ;;
        -help) #_TODO_ run help
        ;;
    esac
shift
done

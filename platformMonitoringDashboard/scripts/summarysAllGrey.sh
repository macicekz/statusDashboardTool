#!/bin/sh

#  summarysAllGrey.sh
#  
#
#  Created by Zdenek Macicek on 14.02.15.
#
#----------------------------------------------------------------------
function checkLogin
{
source ../conf/user.cfg
T_HOME=$TOOL_HOME

TOKEN=`cat $T_HOME/conf/token`

###Save token
if [ ! $TOKEN ]; then

ERROR_RESPONSE=$(xmllint --xpath "//faultstring/text()" $T_HOME/logs/messages/responseLogin.xml| awk -F $':' '{print $2 }')
echo "- ERROR : $LINENO: $PROGNAME : INCORRECT LOGIN !!! "
echo "- ERROR : $LINENO: $PROGNAME : Confluence returned error: $ERROR_RESPONSE"
exit
else
echo "- Info : $LINENO: $PROGNAME: Token exists: $TOKEN"
fi
}
#----------------------------------------------------------------------
function checkToken  ###Check if token exists
{
#reading user config
source ../conf/user.cfg
T_HOME=$TOOL_HOME
CUSER=$CONF_USER

TOKEN=$(cat $T_HOME/conf/token)
echo "- INFO : $LINENO: $PROGNAME : Checking authentication token "

if [ ! $TOKEN ]; then
echo "- WARN : $LINENO: $PROGNAME : Token not found, logging in using configured parameters"
./loginConfluence.sh
checkLogin
else
echo "- OK : $LINENO: $PROGNAME : Token exists "
# _TODO_ check age of token if not expired
fi
}
#----------------------------------------------------------------------
#----------------------------------------------------------------------
checkLogin
checkToken

./summarys.sh -p PLATFORM -s UNKNOWN -D NA1 -H
./summarys.sh -p COMPONENTS -s OK -D NA1 -H
./summarys.sh -p SUBCOMPONENTS -s OK -D NA1 -H

#!/bin/bash

./logoutConfluence.sh
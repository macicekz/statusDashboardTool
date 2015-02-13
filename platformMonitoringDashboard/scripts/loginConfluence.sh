#!/bin/bash

#   Loggs in to confluence according to configuration
#   Retrives and saves confluence authentication token
#
#  ./loginConfluence.sh
#
#  Created by Zdenek Macicek on 23.01.15.
#
PROGNAME=$(basename $0)
###get user and tool configuration
source ../conf/user.cfg
CPASSWORD=$CONF_PASSWORD
T_HOME=$TOOL_HOME
CUSER=$CONF_USER
#_TODO_ check configurace
#_TODO_ nacteni parametru
#_TODO_Automaticky relogin
#Log
echo "- Info : $LINENO: $PROGNAME : START "
echo "- Info : $LINENO: $PROGNAME:  Logging in to confluence with user: $CUSER"
### get Confluence configuration
source $T_HOME/conf/config.cfg
REQUEST="$REQUEST_LOGIN"
CAPI_URL="$API_URL"
echo "$REQUEST" > $T_HOME/logs/messages/requestLogin.xml
echo "- Info : $LINENO: $PROGNAME:   Calling confluence API with URL: $CAPI_URL"
#_TODO_ hide password
###Call Confluence API:
curl -H "Content-Type: text/xml; charset=utf-8" -H "SOAPAction: https://confluence.intgdc.com/plugins/servlet/soap-axis1/confluenceservice-v2/ConfluenceSoapService/loginRequest"  -d @$T_HOME/logs/messages/requestLogin.xml -X POST $CAPI_URL > "$T_HOME/logs/messages/responseLogin.xml"
TOKEN=`xmllint --xpath "//loginReturn/text()" $T_HOME/logs/messages/responseLogin.xml`

###Save token
if [ ! $TOKEN ]; then

    ERROR_RESPONSE=$(xmllint --xpath "//faultstring/text()" $T_HOME/logs/messages/responseLogin.xml| awk -F $':' '{print $2 }')
    echo "- ERROR : $LINENO: $PROGNAME : INCORRECT LOGIN !!! "
    echo "- ERROR : $LINENO: $PROGNAME : Confluence returned error: $ERROR_RESPONSE"
    rm $T_HOME/conf/token
else
    echo "$TOKEN" > "$T_HOME/conf/token" > "$T_HOME/conf/token"
    echo "- Info : $LINENO: $PROGNAME: Token: $TOKEN saved to: $T_HOME/conf/token"
    chmod a+rwx $T_HOME/conf/token
fi
rm $T_HOME/logs/messages/requestLogin.xml



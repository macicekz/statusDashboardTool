#!/bin/bash

# - Loggs OUT from confluence
# - Deletes confluence authentication token
#
#  ./logoutConfluence.sh
#
#  Created by Zdenek Macicek on 23.01.15.
#
PROGNAME=$(basename $0)

### Get user and tool configuration
source ../conf/user.cfg
T_HOME=$TOOL_HOME
TOKEN=$(cat $T_HOME/conf/token)

### Log
echo "- Info: $LINENO: $PROGNAME: START Logging OUT ..."
echo "- Info: $LINENO: $PROGNAME: Logging Out from confluence."

### get Confluence configuration
source $T_HOME/conf/config.cfg
REQUEST="$REQUEST_LOGOUT"
CAPI_URL="$API_URL"

echo "$REQUEST" > $T_HOME/logs/messages/requestLogout.xml
#_TODO_ hide password
echo "- Info: $LINENO: $PROGNAME: Calling confluence API with URL: $CAPI_URL"

### Call Confluence API:
curl -H "Content-Type: text/xml; charset=utf-8" -H "SOAPAction: https://confluence.intgdc.com/plugins/servlet/soap-axis1/confluenceservice-v2/ConfluenceSoapService/logoutRequest"  -d @$T_HOME/logs/messages/requestLogout.xml -X POST $CAPI_URL > "$T_HOME/logs/messages/$TIMESTAMP_responseLogout.xml"
RESPONSE=`xmllint --xpath "//logoutReturn/text()" $T_HOME/logs/messages/$TIMESTAMP_responseLogout.xml`

### Delete token
rm "$T_HOME/conf/token"
echo "- Info: $LINENO: $PROGNAME: Loggout finished with state: $RESPONSE"
echo "- Info: $LINENO: $PROGNAME: END "



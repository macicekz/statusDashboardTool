
#!/bin/sh

#  getSpaceInfo.sh
#
#  Retrieves list of all pages in space according to conigured space name
#
#  Created by Zdenek Macicek on 24.01.15.
#

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
    else
        echo "- OK : $LINENO: $PROGNAME : Token exists "
        # _TODO_ check age of token if not expired
    fi
}

#----------------------------------------------------------------------
#----------------------------------------------------------------------
PROGNAME=$(basename $0)

echo "" #new row
echo "- Info : $LINENO: $PROGNAME : START "
echo "- Info : $LINENO: $PROGNAME : info : Reading user configuration. "

source ../conf/user.cfg
T_HOME=$TOOL_HOME
CUSER=$CONF_USER
CAPI_URL=$API_URL

checkToken  #check authentication token

### get Confluence configuration
source $T_HOME/conf/config.cfg
CSPACE="$SPACE_NAME"
CAPI_URL="$API_URL"

REQUEST="<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:soap=\"http://soap.rpc.confluence.atlassian.com\"><soapenv:Header/><soapenv:Body><soap:getPages soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><in0 xsi:type=\"xsd:string\">$TOKEN</in0><in1 xsi:type=\"xsd:string\">$CSPACE</in1></soap:getPages></soapenv:Body></soapenv:Envelope>"

echo "$REQUEST" > $T_HOME/logs/messages/requestGetAllSpacePages.xml

###Call Confluence API:
curl -H "Content-Type: text/xml; charset=utf-8" -H "SOAPAction: https://confluence.intgdc.com/plugins/servlet/soap-axis1/confluenceservice-v2/ConfluenceSoapService/getPagesRequest"  -d @$T_HOME/logs/messages/requestGetAllSpacePages.xml -X POST $CAPI_URL > "$T_HOME/logs/messages/responseGetAllSpacePages.xml"

GIVEN_SPACE=`xmllint --xpath "//getPagesReturn[2]/space/text()" "$T_HOME/logs/messages/responseGetAllSpacePages.xml"`
cp "$T_HOME/logs/messages/responseGetAllSpacePages.xml" $T_HOME/data/responseGetAllSpacePages.xml
cp "$T_HOME/logs/messages/requestGetAllSpacePages.xml" $T_HOME/data/requestGetAllSpacePages.xml

./transformMessages.sh "responseGetAllSpacePages.xml"
./transformMessages.sh "requestGetAllSpacePages.xml"

echo "- Info : $LINENO: $PROGNAME:  Saving informations retrieved for space $SPACE_NAME to $T_HOME/data/responseGetAllSpacePages.xml"
echo "- Info : $LINENO: $PROGNAME : END "
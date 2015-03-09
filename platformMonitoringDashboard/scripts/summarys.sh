#!/bin/sh

#  editPage.sh
#
#  Sets Up summary according to given parameters
#
#  ./summarys.sh [-]pDsTHhnI
#   -p [PAGE_NAME]  -D [Data Center] -s [State] -i #[PAGE_ID] -n [Note] -l [List all possible parameter values]
#
#  Created by Zdenek Macicek on 23.01.15.
#

function convertPageName #Updates Page Name according given parameter
{
source ../conf/config.cfg
case $PAGE in
        PLATFORM) PAGE_NAME=$PLATFORM   ;;
        COMPONENTS) PAGE_NAME=$COMPONENTS    ;;
        SUBCOMPONENTS) PAGE_NAME=$SUBCOMPONENTS   ;;
esac
}
#----------------------------------------------------------------------
function setStateProperties  #sets colour, page comment and comment according to given state
{
    echo "- Info : $LINENO: $PROGNAME : Setting up properties according to given state  "
    source ../conf/user.cfg
    T_HOME=$TOOL_HOME

    case $STATE in
                OK)
                    COLOUR="green"
                    PAGE_COMMENT="User $CUSER change state of $PAGE_NAME on Data Center: $DC to $STATE. $NOTE"
            ;;
                PROBLEM)
                    COLOUR="yellow"
                    PAGE_COMMENT="User $CUSER change state of $PAGE_NAME on Data Center: $DC to $STATE. See $TICKET for more informations. $NOTE"
                    PAGE_URL=
                    URL_NAME=`echo "$TICKET_URL"| awk  -F $'/' '{print $5}'`
            ;;
                DOWN)
                    COLOUR="red"
                    PAGE_COMMENT=$PAGE_COMMENT_PROBLEM
                    URL_NAME=`echo "$TICKET_URL"| awk  -F $'/' '{print $5}'`
            ;;
                PERFORMANCE)
                    COLOUR="blue"
                    STATE="PERFORMANCE DEGRADATION"
                    PAGE_COMMENT=$PAGE_COMMENT_PROBLEM
                    URL_NAME=`echo "$TICKET_URL"| awk  -F $'/' '{print $5}'`
            ;;
                UNKNOWN)
                    COLOUR="grey"
                    STATE="-"
                    PAGE_COMMENT="$PAGE_COMMENT_UNKNOWN"
                    URL_NAME="-"
            ;;
                RELEASE)
                    COLOUR="red"
                    STATE="RELEASE"
                    URL_NAME=$(echo $TICKET_URL|awk  -F $'/' '{print $6}')
                    PAGE_COMMENT="$PAGE_COMMENT_RELEASE"
                    CUSER="$CONF_USER"
;;
    esac
echo " page Name on start of setStateProperties is $PAGE"
}
#----------------------------------------------------------------------
function setDcSpecificProperties  #sets Data center specific properties according to given Data cenetr
{
case $DC in
    NA1)
        if [ $STATE == "OK" ]; then
                URL_NA1=$PAGE_URL
                COLOUR_NA1=$COLOUR
                STATE_NA1="UP"
        else
                URL_NA1=$TICKET_URL
                STATE_NA1=$URL_NAME
                COLOUR_NA1=$COLOUR
        fi
    ;;
    EU1)
        if [ $STATE == "OK"  ]; then
                URL_EU1=$PAGE_URL
                STATE_EU1="UP"
                COLOUR_EU1=$COLOUR
        else
                URL_EU1=$TICKET_URL
                STATE_EU1=$URL_NAME
                COLOUR_EU1=$COLOUR
        fi
    ;;
    NA2)
        if [ $STATE == "OK" ]; then
                URL_NA2=$PAGE_URL
                STATE_NA2="UP"
                COLOUR_NA2=$COLOUR
        else
                URL_NA2=$TICKET_URL
                STATE_NA2=$URL_NAME
                COLOUR_NA2=$COLOUR
        fi
    ;;
    ALL)
        if [ $STATE == "OK" ]; then
                URL_NA1=$PAGE_URL
                URL_EU1=$PAGE_URL
                URL_NA2=$PAGE_URL
                STATE_NA1="UP"
                STATE_EU1="UP"
                STATE_NA2="UP"
                COLOUR_NA1=$COLOUR
                COLOUR_EU2=$COLOUR
                COLOUR_NA2=$COLOUR
        else
                STATE_NA2=$URL_NAME
                COLOUR_NA2=$COLOUR
                STATE_NA1=$URL_NAME
                COLOUR_NA1=$COLOUR
                STATE_EU1=$URL_NAME
                COLOUR_EU1=$COLOUR
        fi
    ;;
    "")  error_exit "$LINENO: NO DATACETER given "
    ;;
    esac
}
#----------------------------------------------------------------------


function error_exit #Exits script in case of failure
{
echo "" #new row
echo "- ERROR : ${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
echo "" #new row
echo "USAGE: ./editPage.sh [-]pDsTHhnI -p [PAGE_NAME]  -D [Data Center] -s [STATE] -T [TICKET_URL parenthness has to been used \"https:/#jira.intgdc.com/browse/WA-4071\"] -H/h [update HISTORY Y/N] -n [NOTE added to comment] -I #[PAGE_ID] -l [List all possible parameter values]]"
echo "" #new row

exit 1
}
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
PROGNAME=$(basename $0)

clear
echo "- Info : $LINENO: $PROGNAME : START "
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
            -p) PAGE=$2 ;;
            -s) STATE=$2 ;;
            -n) NOTE=$2 ;;
            -l) LIST_FLAG=true ;;
            -D) DC=$2 ;;
            -I) PAGE_ID=$2
                ./getPageInfo.sh -i $PAGE_ID
                ;;
            -h) #_TODO_ run help
                ;;
            -help) #_TODO_ run help
                ;;
            esac
    shift
done

#obtain full page name
convertPageName
#set up properties by parameters
setStateProperties
#set up Data center specific variables for page update"
setDcSpecificProperties

#obtain actual informations bout page
echo "Page long before calling getPage is $PAGE_NAME"
echo "Page short before calling getPage is $PAGE"
./getPageInfo.sh -n $PAGE

source ../conf/config.cfg
CAPI_URL=$API_URL

PAGE_VERSION=`xmllint --xpath "//getPageReturn/version/text()" $T_HOME/data/responseGetPage_$PAGE_NAME.xml`
SPACE_NAME=`xmllint --xpath "//getPageReturn/space/text()" $T_HOME/data/responseGetPage_$PAGE_NAME.xml`
PAGE_URL=`xmllint --xpath "//getPageReturn/url/text()" $T_HOME/data/responseGetPage_$PAGE_NAME.xml`
PAGE_ID=`xmllint --xpath "//getPageReturn/id/text()" $T_HOME/data/responseGetPage_$PAGE_NAME.xml`
PAGE_PARENT=`xmllint --xpath "//getPageReturn/parentId/text()" $T_HOME/data/responseGetPage_$PAGE_NAME.xml`

REQUEST="<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:soap=\"http://soap.rpc.confluence.atlassian.com\"><soapenv:Header/><soapenv:Body><soap:updatePage soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><in0 xsi:type=\"xsd:string\">$TOKEN</in0><in1 xsi:type=\"bean:RemotePage\" xmlns:bean=\"http://beans.soap.rpc.confluence.atlassian.com\"><id xsi:type=\"xsd:long\">$PAGE_ID</id><space xsi:type=\"xsd:string\">$SPACE_NAME</space><title xsi:type=\"xsd:string\">$PAGE_NAME</title><parentId xsi:type=\"xsd:long\">$PAGE_PARENT</parentId><url xsi:type=\"xsd:string\">$PAGE_URL</url><version xsi:type=\"xsd:int\">$PAGE_VERSION</version><content xsi:type=\"xsd:string\"><![CDATA[<ac:structured-macro ac:name=\"excerpt\"><ac:parameter ac:name=\"atlassian-macro-output-type\">INLINE</ac:parameter><ac:rich-text-body><ac:structured-macro ac:name=\"table-plus\"><ac:parameter ac:name=\"columnStyles\">width:170px,width:170px,width:170px,width:170px</ac:parameter><ac:parameter ac:name=\"atlassian-macro-output-type\">INLINE</ac:parameter><ac:rich-text-body><table style=\"line-height: 1.4285715;\"><tbody><tr><th class=\"highlight-grey\" data-highlight-colour=\"grey\"><a href=\"$PAGE_URL\">$PAGE_NAME</a></th><th class=\"highlight-$COLOUR\" data-highlight-colour=\"$COLOUR\"><a href=\"$PAGE_URL\"> <ac:structured-macro ac:name=\"status\"><ac:parameter ac:name=\"colour\">$COLOUR</ac:parameter><ac:parameter ac:name=\"title\">NA1</ac:parameter></ac:structured-macro> </a></th><th class=\"highlight-grey\" data-highlight-colour=\"grey\"><a href=\"$PAGE_URL\"> <ac:structured-macro ac:name=\"status\"><ac:parameter ac:name=\"colour\">grey</ac:parameter><ac:parameter ac:name=\"title\">EU1</ac:parameter></ac:structured-macro> </a></th><th class=\"highlight-grey\" data-highlight-colour=\"grey\"><a href=\"$PAGE_URL\"> <ac:structured-macro ac:name=\"status\"><ac:parameter ac:name=\"colour\">grey</ac:parameter><ac:parameter ac:name=\"title\">NA2</ac:parameter></ac:structured-macro> </a></th></tr></tbody></table></ac:rich-text-body></ac:structured-macro></ac:rich-text-body></ac:structured-macro><p><ac:structured-macro ac:name=\"version-history\"><ac:parameter ac:name=\"page\">@self</ac:parameter><ac:parameter ac:name=\"dateFormat\">dd MMMM yyyy - hh:mm aa z</ac:parameter><ac:parameter ac:name=\"first\">23</ac:parameter></ac:structured-macro></p>]]></content></in1><in2 xsi:type=\"bean:RemotePageUpdateOptions\" xmlns:bean=\"http://beans.soap.rpc.confluence.atlassian.com\"><minorEdit xsi:type=\"xsd:boolean\">false</minorEdit><versionComment xsi:type=\"xsd:string\">$PAGE_COMMENT</versionComment></in2></soap:updatePage></soapenv:Body></soapenv:Envelope>"

echo "- Info : Saving update request to $T_HOME/data/messages/requestUpdatePage_$PAGE.xml "
echo "$REQUEST" > $T_HOME/logs/messages/requestUpdatePage_$PAGE.xml
echo "- Info : $LINENO: $PROGNAME : Calling Confluence update page API with request updatePage : "
echo "API url = $CAPI_URL"
echo ""
echo "*****************************************************"
echo "***    ***     ***    ***    ***    ***    ***    ***"
echo "***             API URL : $CAPI_URL ***"
echo "***"
echo "***             Page Name         : $PAGE_NAME ***"
echo "***             Short Name        : $PAGE ***"
echo "***             Space             : $SPACE_NAME ***"
echo "***             Page ID           : $PAGE_ID ***"
echo "***             URL               : $PAGE_URL ***"
echo "***             Page Version      : $PAGE_VERSION ***"
echo "***             State to set up   : $STATE ***"
echo "***             Data Center       : $DC ***"
echo "***             USER              : $CUSER ***"
echo "***             Comment           : $PAGE_COMMENT ***"
echo "***             Note              : $NOTE ***"
echo "***             History  update   : $HISTORY_FLAG ***"
echo "***    ***     ***    ***    ***    ***    ***    ***"
echo "*****************************************************"
echo ""
###Call Confluence API
curl -H "Content-Type: text/xml; charset=utf-8" -H "SOAPAction: https://confluence.intgdc.com/plugins/servlet/soap-axis1/confluenceservice-v2/ConfluenceSoapService/updatePage"  -d @$T_HOME/logs/messages/requestUpdatePage_$PAGE.xml -X POST $CAPI_URL > "$T_HOME/logs/messages/responseUpdatePage_$PAGE.xml"

echo "- $PROGNAME:   Saving informations retrieved for $PAGE_NAME to $TOOL_HOME/data/responseUpdatePage_$PAGE.xml"
cp "$T_HOME/logs/messages/responseUpdatePage_$PAGE.xml" $T_HOME/data/responseUpdatePage_$PAGE.xml
echo "- Info : $LINENO: $PROGNAME : END "

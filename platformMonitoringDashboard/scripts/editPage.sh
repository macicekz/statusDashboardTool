#!/bin/sh

#  editPage.sh
#
#  Sets Up page according to given parameters
#
#  ./editPage.sh [-]pDsTHhnI
#   -p [PAGE_NAME]  -D [Data Center] -s [STATE] -T [TICKET_URL parenthness has to been used "https:/#jira.intgdc.com/browse/WA-4071"] -H/h [update HISTORY Y/N] -n [NOTE added to comment] -I #[PAGE_ID] -l [List all possible parameter values]
#
#  Created by Zdenek Macicek on 23.01.15.
#

function convertPageName #Updates Page Name according given parameter
{
    source ../conf/config.cfg
    case $PAGE in
            ETL) PAGE_NAME=$ETL    ;;
            REPORTS) PAGE_NAME=$REPORTS    ;;
            DS) PAGE_NAME=$DS    ;;
            DM) PAGE_NAME=$DM    ;;
            EXPORTERS) PAGE_NAME=$EXPORTERS     ;;
            SECURITY) PAGE_NAME=$SECURITY    ;;
            CC) PAGE_NAME=$CC    ;;
            API) PAGE_NAME=$API    ;;
            WEBDAV) PAGE_NAME=$WEBDAV    ;;
            POSTGRESS) PAGE_NAME=$POSTGRESS   ;;
            VERTICA) PAGE_NAME=$VERTICA    ;;
            IC) PAGE_NAME=$IC    ;;
            AQE) PAGE_NAME=$AQE    ;;
            CONNECTORS) PAGE_NAME=$CONNECTORS   ;;
            ADS) PAGE_NAME=$ADS   ;;
            WEBS) PAGE_NAME=$WEBS    ;;
            PLATFORM) PAGE_NAME=$PLATFORM   ;;
            COMPONENTS) PAGE_NAME=$COMPONENTS    ;;
            SUBCOMPONENTS) PAGE_NAME=$SUBCOMPONENTS   ;;
            WATCH) PAGE_NAME=$WATCH    ;;
            NO_USER) PAGE_NAME=$NO_USER   ;;
    esac
}
 #----------------------------------------------------------------------
function handleTicket
{
GIVEN_TICKET=$TICKET_URL
ZENDESK_COUNT=$(echo $GIVEN_TICKET | grep -c "https://gooddata.zendesk.com/agent/tickets/")
JIRA_COUNT=$(echo $GIVEN_TICKET | grep -c "https://jira.intgdc.com/browse/")
OLD_ZENDESK_COUNT=$(echo $GIVEN_TICKET | grep -c "https://support.gooddata.com/tickets/")
PD_COUNT=$(echo $GIVEN_TICKET | grep -c "https://gooddata.pagerduty.com/incidents/")
echo "Jira $JIRA_COUNT  zendesk $ZENDESK_COUNT, OLD_ZENDESK_COUNT $OLD_ZENDESK_COUNT"
TICKET_COUNT=$(($JIRA_COUNT + $ZENDESK_COUNT + $OLD_ZENDESK_COUNT + $PD_COUNT))

if [ $TICKET_COUNT -gt 0 ]; then
    if [ $ZENDESK_COUNT -gt 0 ]; then
        URL_NAME=`echo "$TICKET_URL"| awk  -F $'/' '{print $6}'`
    else
        URL_NAME=`echo "$TICKET_URL"| awk  -F $'/' '{print $5}'`
    fi
else
    URL_NAME="No ticket"
    TICKET_URL=""
fi


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
                    PAGE_COMMENT="User $CUSER change state of $PAGE_NAME on Data Center: $DC to $STATE. See $TICKET_URL for more informations. $NOTE"
#        PAGE_URL=
                    handleTicket
            ;;
                DOWN)
                    COLOUR="red"
                    PAGE_COMMENT="User $CUSER change state of $PAGE_NAME on Data Center: $DC to $STATE. See $TICKET_URL for more informations. $NOTE"
                    handleTicket
            ;;
                PERFORMANCE)
                    COLOUR="blue"
                    STATE="PERFORMANCE DEGRADATION"
                    PAGE_COMMENT="User $CUSER change state of $PAGE_NAME on Data Center: $DC to $STATE. See $TICKET_URL for more informations. $NOTE"
                    handleTicket
            ;;
                ONLINE)
                    COLOUR="green"
                    STATE=" = ONLINE = "
                    PAGE_COMMENT=$WLOGIN_TEXT
                    CUSER="$CONF_USER"   #- changing watch state
            ;;
                OFFLINE)
                    COLOUR="grey"
                    STATE="= OFFLINE ="
                    PAGE_COMMENT=$WLOGOUT_TEXT
                    CUSER="$CONF_USER"   #- changing watch state
            ;;
                UNKNOWN)
                    COLOUR="grey"
                    STATE="-"
                    PAGE_COMMENT=""
                    URL_NAME="-"
            ;;

                #_TODO_ RELEASE
                #RELEASE) COLOUR="grey"
                #NA1="-"
                #STATE="UNKNOWN"
                #PAGE_COMMENT=$RELEASE_COMMENT_START
                #;;
            esac
}
#----------------------------------------------------------------------
function setDcSpecificProperties  #sets Data center specific properties according to given Data cenetr
{

URL_EU1=$PAGE_URL
STATE_EU1="-"
COLOUR_EU1="grey"
URL_NA2=$PAGE_URL
STATE_NA2="-"
COLOUR_NA2="grey"

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
            COLOUR_NA1=$COLOUR
        else
            URL_NA2=$TICKET_URL
            STATE_NA2=$URL_NAME
            COLOUR_NA2=$COLOUR
        fi
    ;;
    GOODDATA)
            URL_NA1=$PAGE_URL
            STATE_NA1="GOODDATA.COM"
            COLOUR_NA1=$COLOUR
    ;;
    DEVPORTAL)
            URL_EU1=$PAGE_URL
            STATE_EU1="DEVPORTAL"
            COLOUR_EU1=$COLOUR
    ;;
    HELP)
            URL_NA2=$PAGE_URL
            STATE_NA2="GOODDATA.COM"
            COLOUR_NA2=$COLOUR
    ;;
#_TODO_ set state for all datacenters at once
    ALL)
            URL_NA1=$PAGE_URL
            STATE_NA1="GOODDATA.COM"
            COLOUR_NA1=$COLOUR
            URL_NA2=$PAGE_URL
            STATE_NA2="DEVPORTAL"
            COLOUR_NA2=$COLOUR
            URL_EU1=$PAGE_URL
            STATE_EU1="HELP"
            COLOUR_EU1=$COLOUR
    ;;
    "")  error_exit "$LINENO: NO DATACETER given !"
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
exit 1
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
            -T) TICKET_URL=$2 ;;
            -H) HISTORY_FLAG=false ;;
            -n) NOTE=$2 ;;
            -l) LIST_FLAG=true ;;
            -D) DC=$2  ;;
            -I)
                PAGE_ID=$2
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
./getPageInfo.sh -n $PAGE

source ../conf/config.cfg
CAPI_URL=$API_URL

#Obtain page properties from response
PAGE_VERSION=`xmllint --xpath "//getPageReturn/version/text()" $T_HOME/data/responseGetPage_$PAGE.xml`
SPACE_NAME=`xmllint --xpath "//getPageReturn/space/text()" $T_HOME/data/responseGetPage_$PAGE.xml`
PAGE_URL=`xmllint --xpath "//getPageReturn/url/text()" $T_HOME/data/responseGetPage_$PAGE.xml`
PAGE_ID=`xmllint --xpath "//getPageReturn/id/text()" $T_HOME/data/responseGetPage_$PAGE.xml`
PAGE_PARENT=`xmllint --xpath "//getPageReturn/parentId/text()" $T_HOME/data/responseGetPage_$PAGE.xml`

REQUEST="<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:soap=\"http://soap.rpc.confluence.atlassian.com\"><soapenv:Header/><soapenv:Body><soap:updatePage soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><in0 xsi:type=\"xsd:string\">$TOKEN</in0><in1 xsi:type=\"bean:RemotePage\" xmlns:bean=\"http://beans.soap.rpc.confluence.atlassian.com\"><id xsi:type=\"xsd:long\">$PAGE_ID</id><space xsi:type=\"xsd:string\">$SPACE_NAME</space><title xsi:type=\"xsd:string\">$PAGE_NAME</title><parentId xsi:type=\"xsd:long\">$PAGE_PARENT</parentId><url xsi:type=\"xsd:string\">$PAGE_URL</url><version xsi:type=\"xsd:int\">$PAGE_VERSION</version><content xsi:type=\"xsd:string\"><![CDATA[<ac:structured-macro ac:name=\"excerpt\"><ac:parameter ac:name=\"atlassian-macro-output-type\">INLINE</ac:parameter><ac:rich-text-body><ac:structured-macro ac:name=\"table-plus\"><ac:parameter ac:name=\"columnStyles\">width:170px,width:170px,width:170px,width:170px</ac:parameter><ac:parameter ac:name=\"atlassian-macro-output-type\">INLINE</ac:parameter><ac:rich-text-body><table style=\"line-height: 1.4285715;\"><tbody><tr><th class=\"highlight-grey\" data-highlight-colour=\"grey\"><a href=\"$PAGE_URL\"> <ac:structured-macro ac:name=\"status\"><ac:parameter ac:name=\"colour\">grey</ac:parameter><ac:parameter ac:name=\"title\">$PAGE_NAME</ac:parameter></ac:structured-macro> </a></th><th class=\"highlight-$COLOUR_NA1\" data-highlight-colour=\"$COLOUR_NA1\"><a href=\"$URL_NA1\"><ac:structured-macro ac:name=\"status\"><ac:parameter ac:name=\"colour\">$COLOUR_NA1</ac:parameter><ac:parameter ac:name=\"title\">$STATE_NA1</ac:parameter></ac:structured-macro> </a></th><th class=\"highlight-$COLOUR_EU1\" data-highlight-colour=\"$COLOUR_EU1\"><a href=\"$URL_EU1\"> <ac:structured-macro ac:name=\"status\"><ac:parameter ac:name=\"colour\">$COLOUR_EU1</ac:parameter><ac:parameter ac:name=\"title\">$STATE_EU1</ac:parameter></ac:structured-macro> </a></th><th class=\"highlight-$COLOUR_NA2\" data-highlight-colour=\"$COLOUR_NA2\"><a href=\"$URL_NA2\"> <ac:structured-macro ac:name=\"status\"><ac:parameter ac:name=\"colour\">$COLOUR_EU1</ac:parameter><ac:parameter ac:name=\"title\">$STATE_NA2</ac:parameter></ac:structured-macro> </a></th></tr></tbody></table></ac:rich-text-body></ac:structured-macro></ac:rich-text-body></ac:structured-macro><p><ac:structured-macro ac:name=\"version-history\"><ac:parameter ac:name=\"page\">@self</ac:parameter><ac:parameter ac:name=\"dateFormat\">dd MMMM yyyy - hh:mm aa z</ac:parameter><ac:parameter ac:name=\"first\">23</ac:parameter></ac:structured-macro></p>]]></content></in1><in2 xsi:type=\"bean:RemotePageUpdateOptions\" xmlns:bean=\"http://beans.soap.rpc.confluence.atlassian.com\"><minorEdit xsi:type=\"xsd:boolean\">false</minorEdit><versionComment xsi:type=\"xsd:string\">$PAGE_COMMENT</versionComment></in2></soap:updatePage></soapenv:Body></soapenv:Envelope>"

echo "- Info : Saving update request to $T_HOME/data/messages/requestUpdatePage_$PAGE.xml "
echo "$REQUEST" > $T_HOME/logs/messages/requestUpdatePage_$PAGE.xml
echo "- Info : $LINENO: $PROGNAME : Calling Confluence update page API with request updatePage : "
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
echo "***             Parent Page ID    : $PAGE_PARENT ***"
echo "***             Comment           : $PAGE_COMMENT ***"
echo "***             Note              : $NOTE ***"
echo "***             Ticket_URL        : $TICKET_URL ***"
echo "***             History  update   : $HISTORY_FLAG ***"
echo "***    ***     ***    ***    ***    ***    ***    ***"
echo "*****************************************************"
echo ""
###Call Confluence API
curl -H "Content-Type: text/xml; charset=utf-8" -H "SOAPAction: https://confluence.intgdc.com/plugins/servlet/soap-axis1/confluenceservice-v2/ConfluenceSoapService/updatePage"  -d @$T_HOME/logs/messages/requestUpdatePage_$PAGE.xml -X POST $CAPI_URL > "$T_HOME/logs/messages/responseUpdatePage_$PAGE.xml"

echo "- $PROGNAME:   Saving informations retrieved for $PAGE_NAME to $T_HOME/data/responseUpdatePage_$PAGE.xml"
cp "$T_HOME/logs/messages/responseUpdatePage_$PAGE.xml" $T_HOME/data/responseUpdatePage_$PAGE.xml

if [ $HISTORY_FLAG ]; then
echo "- Info : $LINENO: $PROGNAME : History comment omitted by user"
else
./historyUpdate.sh "$PAGE_COMMENT"
fi
echo "- Info : $LINENO: $PROGNAME : END "


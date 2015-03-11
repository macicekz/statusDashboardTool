#!/bin/sh

#  editWebs.sh
#
#  Sets Up page according to given parameters
#
#  ./editWebs.sh [-] wsTHnlh
#   -w WebPage [GD, DEV, HELP] -s [STATE] -T [TICKET_URL parenthness has to been used "https:/#jira.intgdc.com/browse/WA-4071"] -H [update HISTORY Y/N] -n [NOTE added to comment] -l [List all possible parameter values] -h [run help] -help [Run Help]
#
#  Created by Zdenek Macicek on 23.01.15.
#

#----------------------------------------------------------------------
function getColour ()
{
    #    convertSpecialCharracters

    case $1 in
    1)  COLOUR_GD=`cat $T_HOME/data/htmlCharsConvert_responseGetPage_WEBS.xml | awk -F $'"colour">' '{print  $3 }' | awk -F $'<' '{print $1}'`
        echo "State of GD  in getState is: $STATE_GD"
    ;;
    2)COLOUR_HELP=`cat $T_HOME/data/htmlCharsConvert_responseGetPage_WEBS.xml | awk -F $'"colour">' '{print  $4 }' | awk -F $'<' '{print $1}'`
        echo "State of HELP in getState  is: $STATE_HELP"
    ;;
    3)COLOUR_DEV=`cat $T_HOME/data/htmlCharsConvert_responseGetPage_WEBS.xml | awk -F $'"colour">' '{print  $5 }' | awk -F $'<' '{print $1}'`
        echo "State of DEV in getState is: $STATE_DEV"
    ;;
    esac
}
#----------------------------------------------------------------------
function getState ()
{
#    convertSpecialCharracters

    case $1 in
            1)  STATE_GD=`cat $T_HOME/data/htmlCharsConvert_responseGetPage_WEBS.xml | awk -F $'"title">' '{print  $3 }' | awk -F $'<' '{print $1}'`
            echo "State of GD  in getState is: $STATE_GD"
            ;;
            2)STATE_HELP=`cat $T_HOME/data/htmlCharsConvert_responseGetPage_WEBS.xml | awk -F $'"title">' '{print  $4 }' | awk -F $'<' '{print $1}'`
                echo "State of HELP in getState  is: $STATE_HELP"
            ;;
            3)STATE_DEV=`cat $T_HOME/data/htmlCharsConvert_responseGetPage_WEBS.xml | awk -F $'"title">' '{print  $5 }' | awk -F $'<' '{print $1}'`
                echo "State of DEV in getState is: $STATE_DEV"
    ;;
    esac
}
 #----------------------------------------------------------------------
function convertWebName #Updates Page Name according given parameter
{
    source ../conf/config.cfg
    PAGE="WEBS"
    PAGE_NAME="Our Webs"
    case $WEB in
            GD) WEB_NAME=$GD ;;
            DEV) WEB_NAME=$DEV ;;
            HELP) WEB_NAME=$HELP ;;
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
                    PAGE_COMMENT="User $CUSER change state of $PAGE_NAME to $STATE for Web: $WEB . $NOTE"
            ;;
                PROBLEM)
                    COLOUR="yellow"
                    PAGE_COMMENT="User $CUSER change state of $PAGE_NAME to $STATE for Web: $WEB . See $TICKET_URL for more informations. $NOTE"
#        PAGE_URL=
                    handleTicket
            ;;
                DOWN)
                    COLOUR="red"
                    PAGE_COMMENT="User $CUSER change state of $PAGE_NAME to $STATE for Web: $WEB . See $TICKET_URL for more informations. $NOTE"
                    handleTicket
            ;;
                PERFORMANCE)
                    COLOUR="blue"
                    STATE="PERFORMANCE DEGRADATION"
                    PAGE_COMMENT="User $CUSER change state of $PAGE_NAME to $STATE for Web: $WEB . See $TICKET_URL for more informations. $NOTE"
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
                    PAGE_COMMENT="User $CUSER change state of $PAGE_NAME to $STATE for Web: $WEB . $NOTE"
                    URL_NAME="-"
            ;;
            esac
}
#----------------------------------------------------------------------
function setDcSpecificProperties  #sets Data center specific properties according to given Data cenetr
{
echo "Page on start of setDcSpecificProperties is $PAGE"
echo "FILE on start of setDcSpecificProperties is $FILE"
case $WEB in
    GD)
        if [ $STATE == "OK" ]; then
            URL_GD=$PAGE_URL
            COLOUR_GD=$COLOUR
            STATE_GD="GOODDATA.COM"
        else
            URL_GD=$TICKET_URL
            STATE_GD="GOODDATA.COM"
            COLOUR_GD=$COLOUR
        fi
        getState 2
        getState 3
        getColour 2
        getColour 3
        echo "State of HELP is $STATE_HELP"
        echo "State of DEV is $STATE_DEV"

#get other webs properties
        ;;
    HELP)
        if [ $STATE == "OK"  ]; then
            URL_HELP=$PAGE_URL
            STATE_HELP="HELP"
            COLOUR_HELP=$COLOUR
        else
            URL_HELP=$TICKET_URL
            STATE_HELP="HELP"
            COLOUR_HELP=$COLOUR
        fi
        getState 1
        getState 3
        getColour 1
        getColour 3
        echo "State of GD is $STATE_GD"
        echo "State of DEV is $STATE_DEV"
#get other webs properties
    ;;
    DEV)
        if [ $STATE == "OK" ]; then
            URL_DEV=$PAGE_URL
            STATE_DEV="DEVPORTAL"
            COLOUR_DEV=$COLOUR
        else
            URL_DEV=$TICKET_URL
            STATE_DEV="DEVPORTAL"
            COLOUR_DEV=$COLOUR
        fi
        getState 1
        getState 2
        getColour 1
        getColour 2
        echo "State of GD is $STATE_GD"
        echo "State of HELP is $STATE_HELP"
#get other webs properties
    ;;
    ALL)
            URL_GD=$PAGE_URL
            COLOUR_GD=$COLOUR
            STATE_GD="GOODDATA.COM"

            URL_HELP=$PAGE_URL
            STATE_HELP="HELP"
            COLOUR_HELP=$COLOUR

            URL_DEV=$PAGE_URL
            STATE_DEV="DEVPORTAL"
            COLOUR_DEV=$COLOUR
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
echo "- Info : $LINENO: $PROGNAME : START editing Webs summary"
echo "- Info : $LINENO: $PROGNAME : info : Reading user configuration. "

source ../conf/user.cfg
T_HOME=$TOOL_HOME
CUSER=$CONF_USER
CAPI_URL=$API_URL
PAGE="WEBS"
PAGE_NAME="Our Webs"
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
            -w) WEB=$2
                echo "Web entered is $WEB";;
            -s) STATE=$2
                echo "State entered is $STATE";;
            -T) TICKET_URL=$2
                echo "TICKET URL  entered is $TICKET_URL";;
            -H) HISTORY_FLAG=false
                echo "HISTORY FLAG  entered is $HISTORY_flag";;
            -n) NOTE=$2 ;;
            -l) LIST_FLAG=true ;;
            -h) #_TODO_ run help
                ;;
            -help) #_TODO_ run help
                ;;
            esac
    shift
done

#obtain full page name
convertWebName
#set up properties by parameters
setStateProperties
#obtain actual informations bout page
./getPageInfo.sh -n WEBS

./transformMessages.sh -h responseGetPage_WEBS.xml
#set up Data center specific variables for page update"
setDcSpecificProperties

source ../conf/config.cfg
CAPI_URL=$API_URL
#Obtain page properties from response
PAGE_VERSION=`xmllint --xpath "//getPageReturn/version/text()" $T_HOME/data/responseGetPage_WEBS.xml`
SPACE_NAME=`xmllint --xpath "//getPageReturn/space/text()" $T_HOME/data/responseGetPage_WEBS.xml`
PAGE_URL=`xmllint --xpath "//getPageReturn/url/text()" $T_HOME/data/responseGetPage_WEBS.xml`
PAGE_ID=`xmllint --xpath "//getPageReturn/id/text()" $T_HOME/data/responseGetPage_WEBS.xml`
PAGE_PARENT=`xmllint --xpath "//getPageReturn/parentId/text()" $T_HOME/data/responseGetPage_WEBS.xml`

REQUEST="<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:soap=\"http://soap.rpc.confluence.atlassian.com\"><soapenv:Header/><soapenv:Body><soap:updatePage soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><in0 xsi:type=\"xsd:string\">$TOKEN</in0><in1 xsi:type=\"bean:RemotePage\" xmlns:bean=\"http://beans.soap.rpc.confluence.atlassian.com\"><id xsi:type=\"xsd:long\">$PAGE_ID</id><space xsi:type=\"xsd:string\">$SPACE_NAME</space><title xsi:type=\"xsd:string\">$PAGE_NAME</title><parentId xsi:type=\"xsd:long\">$PAGE_PARENT</parentId><url xsi:type=\"xsd:string\">$PAGE_URL</url><version xsi:type=\"xsd:int\">$PAGE_VERSION</version><content xsi:type=\"xsd:string\"><![CDATA[<ac:structured-macro ac:name=\"excerpt\"><ac:parameter ac:name=\"atlassian-macro-output-type\">INLINE</ac:parameter><ac:rich-text-body><ac:structured-macro ac:name=\"table-plus\"><ac:parameter ac:name=\"columnStyles\">width:170px,width:170px,width:170px,width:170px</ac:parameter><ac:parameter ac:name=\"atlassian-macro-output-type\">INLINE</ac:parameter><ac:rich-text-body><table style=\"line-height: 1.4285715;\"><tbody><tr><th class=\"highlight-grey\" data-highlight-colour=\"grey\"><a href=\"$PAGE_URL\"> <ac:structured-macro ac:name=\"status\"><ac:parameter ac:name=\"colour\">grey</ac:parameter><ac:parameter ac:name=\"title\">$PAGE_NAME</ac:parameter></ac:structured-macro> </a></th><th class=\"highlight-$COLOUR_GD\" data-highlight-colour=\"$COLOUR_GD\"><a href=\"$URL_GD\"><ac:structured-macro ac:name=\"status\"><ac:parameter ac:name=\"colour\">$COLOUR_GD</ac:parameter><ac:parameter ac:name=\"title\">$STATE_GD</ac:parameter></ac:structured-macro> </a></th><th class=\"highlight-$COLOUR_HELP\" data-highlight-colour=\"$COLOUR_HELP\"><a href=\"$URL_HELP\"> <ac:structured-macro ac:name=\"status\"><ac:parameter ac:name=\"colour\">$COLOUR_HELP</ac:parameter><ac:parameter ac:name=\"title\">$STATE_HELP</ac:parameter></ac:structured-macro> </a></th><th class=\"highlight-$COLOUR_DEV\" data-highlight-colour=\"$COLOUR_DEV\"><a href=\"$URL_DEV\"> <ac:structured-macro ac:name=\"status\"><ac:parameter ac:name=\"colour\">$COLOUR_DEV</ac:parameter><ac:parameter ac:name=\"title\">$STATE_DEV</ac:parameter></ac:structured-macro> </a></th></tr></tbody></table></ac:rich-text-body></ac:structured-macro></ac:rich-text-body></ac:structured-macro><p><ac:structured-macro ac:name=\"version-history\"><ac:parameter ac:name=\"page\">@self</ac:parameter><ac:parameter ac:name=\"dateFormat\">dd MMMM yyyy - hh:mm aa z</ac:parameter><ac:parameter ac:name=\"first\">23</ac:parameter></ac:structured-macro></p>]]></content></in1><in2 xsi:type=\"bean:RemotePageUpdateOptions\" xmlns:bean=\"http://beans.soap.rpc.confluence.atlassian.com\"><minorEdit xsi:type=\"xsd:boolean\">false</minorEdit><versionComment xsi:type=\"xsd:string\">$PAGE_COMMENT</versionComment></in2></soap:updatePage></soapenv:Body></soapenv:Envelope>"

echo "- Info : Saving update request to $T_HOME/data/messages/requestUpdatePage_WEBS.xml "
echo "$REQUEST" > $T_HOME/logs/messages/requestUpdatePage_WEBS.xml
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
curl -H "Content-Type: text/xml; charset=utf-8" -H "SOAPAction: https://confluence.intgdc.com/plugins/servlet/soap-axis1/confluenceservice-v2/ConfluenceSoapService/updatePage"  -d @$T_HOME/logs/messages/requestUpdatePage_WEBS.xml -X POST $CAPI_URL > "$T_HOME/logs/messages/responseUpdatePage_$PAGE.xml"

echo "- $PROGNAME:   Saving informations retrieved for $PAGE_NAME to $T_HOME/data/responseUpdatePage_WEBS.xml"
cp "$T_HOME/logs/messages/responseUpdatePage_WEBS.xml" $T_HOME/data/responseUpdatePage_WEBS.xml

if [ $HISTORY_FLAG ]; then
echo "- Info : $LINENO: $PROGNAME : History comment omitted by user"
else
./historyUpdate.sh "$PAGE_COMMENT"
fi
echo "- Info : $LINENO: $PROGNAME : END "


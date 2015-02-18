#!/bin/bash
#
#  Sets state of watch to OFFLINE
#
#  ./wlogout.sh
#
#  Created by Zdenek Macicek on 23.01.15.
#
function error_exit #Exits script in case of failure
{
    echo "- ERROR : ${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
    echo "" #new row
    echo "USAGE: ./editPage.sh [-]pDsTHhnI -p [PAGE_NAME]  -D [Data Center] -s [STATE] -T [TICKET_URL parenthness has to been used \"https:/#jira.intgdc.com/browse/WA-4071\"] -H/h [update HISTORY Y/N] -n [NOTE added to comment] -I #[PAGE_ID] -l [List all possible parameter values]]"
    echo "" #new row
exit 1
}
#----------------------------------------------------------------------
function checkLogin #checks login after ./loginConfluence.sh run
{
    source ../conf/user.cfg
    T_HOME=$TOOL_HOME

    TOKEN=`cat $T_HOME/conf/token`>&2

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

    echo "- INFO : $LINENO: $PROGNAME : Checking authentication token "
    TOKEN=$(cat $T_HOME/conf/token)>&2

    if [ ! $TOKEN ]; then
        echo "- WARN : $LINENO: $PROGNAME : Token not found, logging in using configured parameters"
        ./loginConfluence.sh
        checkLogin
    else
        echo "- OK : $LINENO: $PROGNAME : Token exists "
        # _TODO_ check age of token if not expired
    fi
}
#--------------------------------------------------------------------
#----------------------------------------------------------------------
source ../conf/user.cfg
CUSER=$CONF_USER
T_HOME=$TOOL_HOME

checkToken  #check authentication token

TOKEN=$(cat $T_HOME/conf/token)

PAGE_NAME="State of platform watch"
PAGE="WATCH"

./getPageInfo.sh -n WATCH

PAGE_VERSION=`xmllint --xpath "//getPageReturn/version/text()" $T_HOME/data/responseGetPage_WATCH.xml`
SPACE_NAME=`xmllint --xpath "//getPageReturn/space/text()" $T_HOME/data/responseGetPage_WATCH.xml`
PAGE_URL=`xmllint --xpath "//getPageReturn/url/text()" $T_HOME/data/responseGetPage_WATCH.xml`
PAGE_ID=`xmllint --xpath "//getPageReturn/id/text()" $T_HOME/data/responseGetPage_WATCH.xml`
PAGE_PARENT=`xmllint --xpath "//getPageReturn/parentId/text()" $T_HOME/data/responseGetPage_WATCH.xml`

STATE="= OFFLINE ="
PAGE_COMMENT="User $CUSER is $STATE"
COLOUR="grey"

echo ""
echo "*****************************************************"
echo "***    ***     ***    ***    ***    ***    ***    ***"
echo "***    Updating Page : $PAGE_NAME ***"
echo "***             Space : $SPACE_NAME ***"
echo "***             ID : $PAGE_ID ***"
echo "***             URL: $PAGE_URL ***"
echo "***             Version : $PAGE_VERSION ***"
echo "***        With Comment : $PAGE_COMMENT ***"
echo "***    ***     ***    ***    ***    ***    ***    ***"
echo "*****************************************************"
echo ""

REQUEST="<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:soap=\"http://soap.rpc.confluence.atlassian.com\"><soapenv:Header/><soapenv:Body><soap:updatePage soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><in0 xsi:type=\"xsd:string\">$TOKEN</in0><in1 xsi:type=\"bean:RemotePage\" xmlns:bean=\"http://beans.soap.rpc.confluence.atlassian.com\"><id xsi:type=\"xsd:long\">$PAGE_ID</id><space xsi:type=\"xsd:string\">$SPACE_NAME</space><title xsi:type=\"xsd:string\">$PAGE_NAME</title><url xsi:type=\"xsd:string\">$PAGE_URL</url><version xsi:type=\"xsd:int\">$PAGE_VERSION</version><content xsi:type=\"xsd:string\"><![CDATA[<ac:structured-macro ac:name=\"excerpt\"><ac:parameter ac:name=\"atlassian-macro-output-type\">BLOCK</ac:parameter><ac:rich-text-body><table style=\"line-height: 1.4285715;\"><tbody><tr><th class=\"highlight-$COLOUR\" data-highlight-colour=\"$COLOUR\"><strong> <ac:structured-macro ac:name=\"status\"><ac:parameter ac:name=\"colour\">$COLOUR</ac:parameter><ac:parameter ac:name=\"title\">$STATE</ac:parameter></ac:structured-macro> </strong></th><th class=\"highlight-$COLOUR\" data-highlight-colour=\"$COLOUR\">Not monitored !</th><th class=\"highlight-$COLOUR\" data-highlight-colour=\"$COLOUR\"><em> <ac:structured-macro ac:name=\"page-info\"><ac:parameter ac:name=\"\">modified-date</ac:parameter><ac:parameter ac:name=\"showComments\">true</ac:parameter><ac:parameter ac:name=\"count\">1</ac:parameter><ac:parameter ac:name=\"page\">@self</ac:parameter><ac:parameter ac:name=\"dateFormat\">MMMM dd yyyy - hh:mm aa z</ac:parameter></ac:structured-macro> </em></th></tr></tbody></table></ac:rich-text-body></ac:structured-macro><p><ac:structured-macro ac:name=\"version-history\"><ac:parameter ac:name=\"page\">@self</ac:parameter><ac:parameter ac:name=\"dateFormat\">dd MMMM yyyy - hh:mm aa z</ac:parameter><ac:parameter ac:name=\"first\">23</ac:parameter></ac:structured-macro></p>]]></content></in1><in2 xsi:type=\"bean:RemotePageUpdateOptions\" xmlns:bean=\"http://beans.soap.rpc.confluence.atlassian.com\"><minorEdit xsi:type=\"xsd:boolean\">false</minorEdit><versionComment xsi:type=\"xsd:string\">$PAGE_COMMENT</versionComment></in2></soap:updatePage></soapenv:Body></soapenv:Envelope>"

echo $REQUEST>../data/requestUpdatePage_WATCH.xml

curl -H "Content-Type: text/xml; charset=utf-8" -H "SOAPAction: https://confluence.intgdc.com/plugins/servlet/soap-axis1/confluenceservice-v2/ConfluenceSoapService/updatePage"  -d @../data/requestUpdatePage_WATCH.xml -X POST https://confluence.intgdc.com/plugins/servlet/soap-axis1/confluenceservice-v2>../data/responseUpdatePage_WATCH.xml

./historyUpdate.sh "$PAGE_COMMENT"
echo "- Info : $LINENO: $PROGNAME : END "

#./logoutConfluence.sh

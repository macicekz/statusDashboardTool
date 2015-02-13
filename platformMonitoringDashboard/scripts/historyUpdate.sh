#!/bin/bash

function checkToken  ###Check if token exists
{
    #reading user config
    source ../conf/user.cfg
    T_HOME=$TOOL_HOME
    CUSER=$CONF_USER

    TOKEN=$(cat $T_HOME/conf/token)

    echo "" #new row
    echo "- INFO : $LINENO: $PROGNAME : Checking authentication token "

    if [ ! $TOKEN ]; then
        #_TODO_ automatic relogin
        error_exit "$LINENO: No token found. Please, log in to confluence using loginConfluence.sh"
    else
        echo "- OK : $LINENO: $PROGNAME : Token exists "
        # _TODO_ check age of token if not expired
    fi
}
#----------------------------------------------------------------------
#----------------------------------------------------------------------
echo "- Info : $LINENO: $PROGNAME : START "

source ../conf/user.cfg
T_HOME=$TOOL_HOME
CUSER=$CONF_USER

TOKEN=$(cat $T_HOME/conf/token)

PAGE_COMMENT=$1

./getPageInfo.sh -n history

PAGE_NAME="history"
PAGE_VERSION=`xmllint --xpath "//getPageReturn/version/text()" $T_HOME/data/responseGetPage_history.xml`
SPACE_NAME=`xmllint --xpath "//getPageReturn/space/text()" $T_HOME/data/responseGetPage_history.xml`
PAGE_URL=`xmllint --xpath "//getPageReturn/url/text()" $T_HOME/data/responseGetPage_history.xml`
PAGE_ID=`xmllint --xpath "//getPageReturn/id/text()" $T_HOME/data/responseGetPage_history.xml`
PAGE_PARENT=`xmllint --xpath "//getPageReturn/parentId/text()" $T_HOME/data/responseGetPage_history.xml`

echo "- Info : $LINENO: $PROGNAME : Updating HISTORY with comment: $PAGE_COMMENT."

REQUEST="<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:soap=\"http://soap.rpc.confluence.atlassian.com\"><soapenv:Header/><soapenv:Body><soap:updatePage soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\"><in0 xsi:type=\"xsd:string\">$TOKEN</in0><in1 xsi:type=\"bean:RemotePage\" xmlns:bean=\"http://beans.soap.rpc.confluence.atlassian.com\"><id xsi:type=\"xsd:long\">$PAGE_ID</id><space xsi:type=\"xsd:string\">$SPACE_NAME</space><title xsi:type=\"xsd:string\">$PAGE_NAME</title><url xsi:type=\"xsd:string\">$PAGE_URL</url><version xsi:type=\"xsd:int\">$PAGE_VERSION</version><content xsi:type=\"xsd:string\"><![CDATA[<p>History of all changes......II</p><ac:structured-macro ac:name=\"excerpt\"><ac:parameter ac:name=\"atlassian-macro-output-type\">BLOCK</ac:parameter><ac:rich-text-body><p><ac:structured-macro ac:name=\"version-history\"><ac:parameter ac:name=\"page\">@self</ac:parameter><ac:parameter ac:name=\"dateFormat\">dd MMMM yyyy - hh:mm aa z</ac:parameter><ac:parameter ac:name=\"first\">10</ac:parameter></ac:structured-macro></p></ac:rich-text-body></ac:structured-macro><p>&nbsp;</p>]]></content></in1><in2 xsi:type=\"bean:RemotePageUpdateOptions\" xmlns:bean=\"http://beans.soap.rpc.confluence.atlassian.com\"><minorEdit xsi:type=\"xsd:boolean\">false</minorEdit><versionComment xsi:type=\"xsd:string\">$PAGE_COMMENT</versionComment></in2></soap:updatePage></soapenv:Body></soapenv:Envelope>"

echo $REQUEST>../data/myUpdateHistory.xml

curl -H "Content-Type: text/xml; charset=utf-8" -H "SOAPAction: https://confluence.intgdc.com/plugins/servlet/soap-axis1/confluenceservice-v2/ConfluenceSoapService/updatePage"  -d @../data/myUpdateHistory.xml -X POST https://confluence.intgdc.com/plugins/servlet/soap-axis1/confluenceservice-v2>../data/myUpdateHistoryResponse.xml



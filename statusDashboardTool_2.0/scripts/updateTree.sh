#  updateTree.sh
#
#  Obtains info about page By Name or ID
#
#  updateTree.sh [-]pDsTHhnI
#   -p [PAGE_NAME]  -D [Data Center] -s [STATE] -T [TICKET_URL parenthness has to been used "https:/#jira.intgdc.com/browse/WA-4071"] -H/h [update HISTORY Y/N] -n [NOTE added to comment] -I #[PAGE_ID] -l [List all possible parameter values]
#
#  Created by Zdenek Macicek on 27.01.15.


PROGNAME=$(basename $0)

function getTreeState () {
TREE_PAGE=$1
./getPageInfo.sh -n $TREE_PAGE
./transformMessages.sh -f responseGetPage_$TREE_PAGE.xml
CHANGE_FLAG_GREEN=$(grep -c green $T_HOME/data/readable_responseGetPage_$TREE_PAGE.xml)
CHANGE_FLAG_GREY=$(grep -c grey $T_HOME/data/readable_responseGetPage_$TREE_PAGE.xml)
}
function getShortPageName () {
LONG_NAME=$1

case $LONG_NAME in
"REPORTS CALCULATION") PARENT_PAGE_NAME="REPORTS"    ;;
"DATA STORAGE") PARENT_PAGE_NAME="DS"    ;;
"DATA MART") PARENT_PAGE_NAME="DM"    ;;
"CLOUD CONNECT") PARENT_PAGE_NAME="CC" ;;
"API + CL TOOL") PARENT_PAGE_NAME="API"    ;;
"WEBDAV, S3") PARENT_PAGE_NAME="WEBDAV";;
"POSTGRESS DWHS") PARENT_PAGE_NAME="POSTGRESS"   ;;
"VERTICA DWHS") PARENT_PAGE_NAME="VERTICA"    ;;
"INTEGRATION CONSOLE") PARENT_PAGE_NAME="IC"    ;;

esac
}


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
function error_exit #Exits script in case of failure
{
    echo "" #new row
    echo "- ERROR : ${PROGNAME}: ${1:-"Unknown Error"}"
    echo "" #new row
    echo "USAGE: ./editPage.sh [-]pDsTHhnI -p [PAGE_NAME]  -D [Data Center] -s [STATE] -T [TICKET_URL parenthness has to been used \"https:/#jira.intgdc.com/browse/WA-4071\"] -H/h [update HISTORY Y/N] -n [NOTE added to comment] -I #[PAGE_ID] -l [List all possible parameter values]]"
    exit 1
}
#----------------------------------------------------------------------

function parentPageStatus ()
{
CURRENT_STATUS=$1
echo "currentStatus $CURRENT_STATUS"
if [ $CURRENT_STATUS == "DOWN" ]; then
STATE="PROBLEM"
else
STATE="$CURRENT_STATUS"
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
./getSpaceInfo.sh

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
        -I)PAGE_ID=$2 ;;
        -h) #_TODO_ run help
;;
        -help) #_TODO_ run help
;;
    esac
shift
done

if [ $HISTORY_FLAG]; then
    echo "withou history"
    ./editPage.sh -p $PAGE -s $STATE -D $DC -T $TICKET_URL -H
else
    ./editPage.sh -p $PAGE -s $STATE -D $DC -T $TICKET_URL
fi

PARENT_ID=`xmllint --xpath "//getPageReturn/parentId/text()" $T_HOME/data/responseGetPage_$PAGE.xml`
PAGE_NAME=`xmllint --xpath "//getPageReturn/title/text()" $T_HOME/data/responseGetPage_$PAGE.xml`
./getPageInfo.sh -i $PARENT_ID


PARENT_PAGE_NAME=`xmllint --xpath "//getPageReturn/title/text()" $T_HOME/data/responseGetPage_$PARENT_ID.xml`
echo "" #new row
echo "- Info : $LINENO: $PROGNAME : Parent page to udate: "
echo "Page id: $PARENT_ID"
getShortPageName "$PARENT_PAGE_NAME"
echo "Page Name: $PARENT_PAGE_NAME"
parentPageStatus $STATE
echo "New page state: $STATE"
echo "" #new row
echo "Do you want to update $PARENT_PAGE_NAME too? Yy/Nn"

read PARENT
case $PARENT in
    Y) ./editPage.sh -p $PARENT_PAGE_NAME -s $STATE -D $DC -T "$TICKET_URL" -H
    ;;
    y) ./editPage.sh -p $PARENT_PAGE_NAME -s $STATE -D $DC -T "$TICKET_URL" -H
    ;;
    n) echo "Keeping $PARENT_PAGE_NAME in previous state"
    ;;
    n) echo "Keeping $PARENT_PAGE_NAME in previous state"
    ;;
esac


getTreeState "SUBCOMPONENTS"



if [ $CHANGE_FLAG_GREEN -gt 0 ]; then
    ./summarys.sh -p SUBCOMPONENTS -s $STATE -D $DC
else
echo "keeping subcomponents as they are"
fi

getTreeState "COMPONENTS"

if [ $CHANGE_FLAG_GREEN -gt 0 ]; then
    ./summarys.sh -p COMPONENTS -s $STATE -D $DC
else
    echo "keeping subcomponents as they are"
fi

getTreeState "PLATFORM"
if [ $CHANGE_FLAG_GREEN -gt 0 ]; then
    ./summarys.sh -p PLATFORM -s $STATE -D $DC
else
echo "keeping subcomponents as they are"
fi




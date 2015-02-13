#  getSpaceInfo.sh
#
#  Obtains info about page By Name or ID
#
#  ./getPageInfo.sh -n [Name of confluence Page] Or -i [Page ID]
#
#  Created by Zdenek Macicek on 24.01.15.

PROGNAME=$(basename $0)
#----------------------------------------------------------------------
function getByID
{
    source ../conf/config.cfg
    REQUEST="$REQUEST_GET_PAGE_BY_ID"
    CAPI_URL=$API_URL

    source ../conf/user.cfg
    T_HOME=$TOOL_HOME

    echo "$REQUEST" > $T_HOME/logs/messages/requestGetPage_$PAGE_ID.xml

    echo "- Info : $LINENO: $PROGNAME : Calling Confluence SOAP API with request getPage : "

    ###Call Confluence API:
    curl -H "Content-Type: text/xml; charset=utf-8" -H "SOAPAction: https://confluence.intgdc.com/plugins/servlet/soap-axis1/confluenceservice-v2/ConfluenceSoapService/getPage"  -d @$T_HOME/logs/messages/requestGetPage_$PAGE_ID.xml -X POST $API_URL > "$T_HOME/logs/messages/responseGetPage_$PAGE_ID.xml"

    echo "- Info : $LINENO: $PROGNAME:   Saving informations retrieved for $PAGE_NAME to $TOOL_HOME/data/responseGetPage_$PAGE_ID.xml"
    cp "$T_HOME/logs/messages/responseGetPage_$PAGE_ID.xml" $T_HOME/data/responseGetPage_$PAGE_ID.xml
}
#----------------------------------------------------------------------

function getByName
{
    source ../conf/config.cfg
    REQUEST="$REQUEST_GET_PAGE_BY_NAME"
    CAPI_URL=$API_URL

    echo "$REQUEST" > $T_HOME/logs/messages/requestGetPage_$PAGE.xml

    echo "- Info : $LINENO: $PROGNAME : Calling Confluence SOAP API with request getPage : "

    ###Call Confluence API:
    curl -H "Content-Type: text/xml; charset=utf-8" -H "SOAPAction: https://confluence.intgdc.com/plugins/servlet/soap-axis1/confluenceservice-v2/ConfluenceSoapService/getPage"  -d @$T_HOME/logs/messages/requestGetPage_$PAGE.xml -X POST $CAPI_URL > "$T_HOME/logs/messages/responseGetPage_$PAGE.xml"

    echo "-Info : $LINENO: $PROGNAME:   Saving informations retrieved for $PAGE_NAME to $TOOL_HOME/data/responseGetPage_$PAGE.xml"
    cp "$T_HOME/logs/messages/responseGetPage_$PAGE.xml" $T_HOME/data/responseGetPage_$PAGE.xml
}
#----------------------------------------------------------------------
function error_exit #Exits script in case of failure
{
    echo "" #new row
    echo "- ERROR : ${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
    echo "" #new row
    echo " - USAGE: ./getPageInfo.sh -n [Name of confluence Page] Or -i [Page ID]"
    echo "" #new row
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
function convertPageName  #Updates Page Name according given parameter
{
    source ../conf/config.cfg
    case $PAGE in
            ETL) PAGE_NAME=$ETL ;;
            REPORTS) PAGE_NAME=$REPORTS  ;;
            DS) PAGE_NAME=$DS  ;;
            DM) PAGE_NAME=$DM   ;;
            EXPORTERS) PAGE_NAME=$EXPORTERS  ;;
            SECURITY) PAGE_NAME=$SECURITY  ;;
            CC) PAGE_NAME=$CC     ;;
            API) PAGE_NAME=$API    ;;
            WEBDAV) PAGE_NAME=$WEBDAV   ;;
            POSTGRESS) PAGE_NAME=$POSTGRESS   ;;
            VERTICA) PAGE_NAME=$VERTICA   ;;
            IC) PAGE_NAME=$IC       ;;
            AQE) PAGE_NAME=$AQE      ;;
            CONNECTORS) PAGE_NAME=$CONNECTORS ;;
            ADS) PAGE_NAME=$ADS ;;
            WEBS) PAGE_NAME=$WEBS  ;;
            PLATFORM) PAGE_NAME=$PLATFORM;;
            COMPONENTS) PAGE_NAME=$COMPONENTS ;;
            SUBCOMPONENTS) PAGE_NAME=$SUBCOMPONENTS    ;;
            WATCH) PAGE_NAME=$WATCH  ;;
            NO_USER) PAGE_NAME=$NO_USER   ;;
            history) PAGE_NAME="history" ;;
    esac
}
#----------------------------------------------------------------------
#----------------------------------------------------------------------
echo "- Info : $LINENO: $PROGNAME : START "
source ../conf/config.cfg
CSPACE=$SPACE_NAME
CAPI_URL=$API_URL

source ../conf/user.cfg
T_HOME=$TOOL_HOME

checkToken
###Reading given parameters
case $1 in
        -i)
            PAGE_ID=$2
            echo "- Info : $LINENO: $PROGNAME : Retreiving informations for given Page ID is $PAGE_ID "
            convertPageName
            getByID ####Obtain page
        ;;
        -n)
            PAGE=$2
            echo "- Info : $LINENO: $PROGNAME : Retreiving informations for given Page NAME is $PAGE_ID "
            convertPageName
            getByName  ####Obtain page
        ;;
        "")
            error_exit "$LINENO: Sorry, NO parameter given."
        ;;
esac
echo "- Info : $LINENO: $PROGNAME : END "

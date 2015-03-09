#!/bin/bash
#
#  Updates dashboard to and from release state.
#
#
#  ./release.sh [-]seTAHhnD
#   -s [Release started]  -e [release finished] -T [JIRA for Release] -A [Anouncement for release] -H/h [update HISTORY Y/N] -n [NOTE added to comment] -D [Datacenter]
#
#  Created by Zdenek Macicek on 06.03.15.
#


function error_exit #Exits script in case of failure
{
echo "- ERROR : ${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
echo "" #new row
echo "./release.sh [-]seTAHhnD -s [Release started]  -e [release finished] -T [JIRA for Release] -A [Anouncement for release] -H/h [update HISTORY Y/N] -n [NOTE added to comment] -D [Datacenter]"
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
            -s) RELEASE_STATE="IN PROGRESS"
                STATE="RELEASE"
            ;;
            -e) RELEASE_STATE="FINISHED"
                STATE="OK"
            ;;
            -T) RELEASE_URL=$2 ;;
            -H) HISTORY_FLAG=false ;;
            -h) HISTORY_FLAG=false ;;
            -n) NOTE=$2 ;;
            -A) ANNOUNCEMENT=true ;;
            -D) DC=$2  ;;
         esac
    shift
done


source ../conf/config.cfg
if [ $RELEASE_URL ]; then
    HISTORY_COMMENT_RELEASE=$HISTORY_COMMENT_RELEASE_START
else
    HISTORY_COMMENT_RELEASE=$HISTORY_COMMENT_RELEASE_END
fi

echo "- Info : $LINENO: $PROGNAME : Setting up AQE .... "
./editPage.sh -p AQE -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up CLOUD CONNECT .... "
./editPage.sh -p CC -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up API + CL TOOL .... "
./editPage.sh -p API -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up CONNECTORS .... "
./editPage.sh -p CONNECTORS -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up WEBDAV, S3 .... "
./editPage.sh -p WEBDAV -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up ADS .... "
./editPage.sh -p ADS -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up POSTGRESS DWHs .... "
./editPage.sh -p POSTGRESS -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up VERTICA DWHs .... "
./editPage.sh -p VERTICA -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up SECURITY .... "
./editPage.sh -p SECURITY -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up EXPORTERS .... "
./editPage.sh -p EXPORTERS -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up DATA MART .... "
./editPage.sh -p DM -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up DATA STORAGE .... "
./editPage.sh -p DS -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up REPORTS COMPUTATION .... "
./editPage.sh -p REPORTS -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up ETL .... "
./editPage.sh -p ETL -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up INTEGRATION CONSOLE .... "
./editPage.sh -p IC -s $STATE -D $DC -T $RELEASE_URL -H


echo "- Info : $LINENO: $PROGNAME : Setting up Platform overview .... "
./summarys.sh -p PLATFORM -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up Components overview .... "
./summarys.sh -p COMPONENTS -s $STATE -D $DC -T $RELEASE_URL -H
echo "- Info : $LINENO: $PROGNAME : Setting up Subcomponents overview .... "
./summarys.sh -p SUBCOMPONENTS -s $STATE -D $DC -T $RELEASE_URL -H


./historyUpdate.sh "$HISTORY_COMMENT_RELEASE"

echo "- Info : $LINENO: $PROGNAME : END "


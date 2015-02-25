#  wizzard.sh
#
#  update pages summaries, login etc interactively
#
#  Created by Zdenek Macicek on 27.01.15.
#
#----------------------------------------------------------------------
PROGNAME=$(basename $0)

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
function finishEdit ()
{
    echo "What is a new state? "
    echo "" #new row
    echo "     --- States ---"
    echo "1.  All OK"
    echo "2.  Problems but running"
    echo "3.  Not working"
    echo "4.  Performance problems"
    echo "5.  unknown - to grey out"
    echo "" #new row
    echo -n "Your choice: "

    read STATE
    case $STATE in
                    1) STATE="OK";;
                    2) STATE="PROBLEM";;
                    3) STATE="DOWN";;
                    4) STATE="PERFORMANCE";;
                    5) STATE="UNKNOWN";;
                    0) return 0 ;;
    esac

    echo "What is a ticket (Zendesk, JIRA, PagerDuty allert)? ( Keep empty if no ticket yet) "

    read TICKET

    if [ $TICKET -eq 0 ]; then
        return 0
    else
        echo "entered ticket: $TICKET"
    fi

    echo "Do you want to update history ? "
    echo "" #new row
    echo -n "Your choice: "

    read HISTORY_FLAG
    case $HISTORY_FLAG in
                    y) HISTORY_FLAG="y"
                    ;;
                    Y) HISTORY_FLAG="y"
                    ;;
                    N) HISTORY_FLAG="n"
                    ;;
                    n) HISTORY_FLAG="n" ;;
                    0) return 0 ;;
    esac

    echo "Setting up $PAGE on NA1 to $STATE. $TICKET . History comment? - $HISTORY_FLAG "
    echo "Do you want to proceed? "
    echo "" #new row
    echo -n "Your choice: "

    read PROCEED
    case $PROCEED in
                    y) echo "cosik"
                    ;;
                    Y) echo="cosik velke"
                    ;;
                    N) SCRIPT="blabla"
                    ;;
                    n) SCRIPT="blabla"
                    ;;
                    0) return 0 ;;
    esac

    case $SCRIPT in
            5)
                 if [ $HISTORY_FLAG=="y" ]; then
                    echo "" #new row
                    echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_$PAGE.log"
                    ./summarys.sh -p $PAGE -s $STATE -D NA1 -T $TICKET>../logs/summarys_$PAGE.log
                 else
                    echo "" #new row
                    echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_$PAGE.log"
                    ./summarys.sh -p $PAGE -s $STATE -D NA1 -T $TICKET -H>../logs/summarys_$PAGE.log
                 fi
            ;;
            6)
                 if [ $HISTORY_FLAG == y ]; then
                    echo  "HISTORY"
                    ./editPage.sh -p $PAGE -s $STATE -D NA1 -T $TICKET>../logs/editPage$PAGE.log
                 else
                 echo "NO HISTORY"
                ./editPage.sh -p $PAGE -s $STATE -D NA1 -T $TICKET -H>../logs/editPage$PAGE.log
                 fi
            ;;
            8)
                if [ $HISTORY_FLAG=="y" ]; then
                    echo "" #new row
                    echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/treeUpdate_$PAGE.log"
                    ./updateTree.sh -p $PAGE -s $STATE -D NA1 -T $TICKET > $T_HOME/logs/treeUpdate_$PAGE.log
                else
                    echo "" #new row
                    echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/treeUpdate_$PAGE.log"
                    ./updateTree.sh -p $PAGE -s $STATE -D NA1 -T $TICKET -H $T_HOME/logs/treeUpdate_$PAGE.log
                fi
            ;;
            0) return 0 ;;
            esac
}

#----------------------------------------------------------------------
#----------------------------------------------------------------------

CONTINUE="y"

./loginConfluence.sh

checkLogin

while [ $CONTINUE == "y" ]
do
        echo "" #new row
        echo "               === CHOOSE TYPE OF CHANGE ===            "
        echo "" #new row
        echo "***  1. login platform watch (no change in other parts)"
        echo "***  2. logout platform watch (no change in other parts)"
        echo ""
        echo "***  3. login platform watch and make whole dashboard green"
        echo "***  4. logout platform watch and make whole dashboard grey"
        echo ""
        echo "***  5. change summary"
        echo "***  6. change component"
        echo "***  7. change Our Webs"
        echo ""
        echo "***  8. update the whole tree of components change component"
        echo "" #new row
        echo "***  0. go back to start or exit in any place within Wizzard"
        echo "" #new row
        echo -n "Your choice: "

        read SCRIPT
        case $SCRIPT in
                1)
                    echo "" #new row
                    echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/loginPlatformWatch.log "
                    ./wlogin.sh>../logs/loginPlatformWatch.log
                    shift;;
                2)
                    echo "" #new row
                    echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/logoutPlatformWatch.log "
                    ./wlogout.sh>../logs/logoutPlatformWatch.log
                    shift
                    ;;
                3)  echo "" #new row
                    echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/allOK.log "
                    ./allOK.sh>../logs/allOK.log
                    shift
                    ;;
                4)  echo "" #new row
                    echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/allGrey.log "
                    ./allGrey.sh>../logs/allGrey.log
                    shift
                    ;;
                0) shift ;;

                5)
                    echo "What Summary do you want to change? "
                    echo "***   1. Platform"
                    echo "***   2. Components"
                    echo "***   3. SubComponents"
                    echo "***   4. All SubComponents"
                    echo "" #new row
                    echo -n "Your choice: "

                    read PAGE
                    case $PAGE in
                                0) shift
                                ;;
                                1)
                                    PAGE="PLATFORM"
                                    echo "What is a new state? "
                                    echo "" #new row
                                    echo "     --- States ---"
                                    echo "***   1.  All OK"
                                    echo "***   2.  Problems but running"
                                    echo "***   3.  Not working"
                                    echo "***   4.  Performance problems"
                                    echo "***   5.  unknown - to grey out"
                                    echo -n "Your choice: "

                                    read STATE
                                    case $STATE in
                                    1) STATE="OK";;
                                    2) STATE="PROBLEM";;
                                    3) STATE="DOWN";;
                                    4) STATE="PERFORMANCE";;
                                    5) STATE="UNKNOWN";;
                                    esac
                                    if [ $STATE -eq 0 ]; then
                                        shift
                                    else
                                        echo "" #new row
                                        echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_$PAGE.log"
                                        ./summarys.sh -p $PAGE -s $STATE -D NA1>../logs/summarys_$PAGE.log
                                    fi
                                ;;
                                2)
                                    PAGE="COMPONENTS"
                                    echo "What is a new state? "
                                    echo "" #new row
                                    echo "     --- States ---"
                                    echo "***   1.  All OK"
                                    echo "***   2.  Problems but running"
                                    echo "***   3.  Not working"
                                    echo "***   4.  Performance problems"
                                    echo "***   5.  unknown - to grey out"
                                    echo -n "Your choice: "

                                    read STATE
                                    case $STATE in
                                    1) STATE="OK";;
                                    2) STATE="PROBLEM";;
                                    3) STATE="DOWN";;
                                    4) STATE="PERFORMANCE";;
                                    5) STATE="UNKNOWN";;
                                    0) shift ;;
                                    esac
                                    if [ $STATE -eq 0 ]; then
                                        shift
                                    else
                                        echo "" #new row
                                        echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_$PAGE.log"
                                        ./summarys.sh -p $PAGE -s $STATE -D NA1>../logs/summarys_$PAGE.log
                                    fi
                                ;;
                                3)
                                    PAGE="SUBCOMPONENTS"
                                    echo "What is a new state? "
                                    echo "" #new row
                                    echo "     --- States ---"
                                    echo "***   1.  All OK"
                                    echo "***   2.  Problems but running"
                                    echo "***   3.  Not working"
                                    echo "***   4.  Performance problems"
                                    echo "***   5.  unknown - to grey out"
                                    echo -n "Your choice: "

                                    read STATE
                                    case $STATE in
                                                1) STATE="OK";;
                                                2) STATE="PROBLEM";;
                                                3) STATE="DOWN";;
                                                4) STATE="PERFORMANCE";;
                                                5) STATE="UNKNOWN";;
                                                0) shift ;;
                                    esac
                                    if [ $STATE -eq 0 ]; then
                                        shift
                                    else
                                        echo "" #new row
                                        echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_$PAGE.log"
                                        ./summarys.sh -p $PAGE -s $STATE -D NA1>../logs/summarys_$PAGE.log
                                    fi
                                ;;
                                4)
                                    echo "What is a new state? "
                                    echo "" #new row
                                    echo "     --- States ---"
                                    echo "***   1.  All OK"
                                    echo "***   2.  unknown - to grey out"
                                    echo -n "Your choice: "

                                    read STATE
                                    case $STATE in  1)
                                                    echo "" #new row
                                                    echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_PLATFORM.log"
                                                    ./summarys.sh -p PLATFORM -s OK -D NA1 -H > $T_HOME/logs/summarys_PLATFORM.log
                                                    echo "" #new row
                                                    echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_COMPONENTS.log"
                                                    ./summarys.sh -p COMPONENTS -s OK -D NA1 -H > $T_HOME/logs/summarys_COMPONENTS.log
                                                    echo "" #new row
                                                    echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_SUBCOMPONENTS.log"
                                                    ./summarys.sh -p SUBCOMPONENTS -s OK -D NA1 -H > $T_HOME/logs/summarys_SUBCOMPONENTS.log
                                                ;;
                                                2)
                                                    echo "" #new row
                                                    echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_PLATFORM.log"
                                                    ./summarys.sh -p PLATFORM -s UNKNOWN -D NA1 -H > $T_HOME/logs/summarys_PLATFORM.log
                                                    echo "" #new row
                                                    echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_COMPONENTS.log"
                                                    ./summarys.sh -p COMPONENTS -s UNKNOWN -D NA1 -H > $T_HOME/logs/summarys_COMPONENTS.log
                                                    echo "" #new row
                                                    echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_SUBCOMPONENTS.log"
                                                    ./summarys.sh -p SUBCOMPONENTS -s UNKNOWN -D NA1 -H > $T_HOME/logs/summarys_SUBCOMPONENTS.log
                                                ;;
                                                0) shift ;;
                                    esac
                                ;;
                    esac
                ;;
                6)
                    echo "What Component do you want to change? "
                    echo "" #new row
                    echo "     --- Components ---"
                    echo "***   1.  ETL"
                    echo "***   2.  REPORTS COMPUTATION"
                    echo "***   3.  DATA STORAGE"
                    echo "***   4.  DATA MART"
                    echo "***   5.  EXPORTERS"
                    echo "***   6.  SECURITY"
                    echo "" #new row
                    echo "     --- SubComponents --- "
                    echo "" #new row
                    echo "***   7.   CLOUD CONNECT"
                    echo "***   8.   API + CL TOOL"
                    echo "***   9.   WEBDAV, S3"
                    echo "***   10.  POSTGRESS DWHS"
                    echo "***   11.  VERTICA DWHS"
                    echo "***   12.  INTEGRATION CONSOLE"
                    echo "***   13.  AQE"
                    echo "***   14.  CONNECTORS"
                    echo "***   15.  ADS"
                    echo -n "Your choice: "

                read PAGE
                case $PAGE in
                        1) PAGE="ETL";;
                        2) PAGE="REPORTS";;
                        3) PAGE="DS";;
                        4) PAGE="DM";;
                        5) PAGE="EXPORTERS";;
                        6) PAGE="SECURITY";;
                        7) PAGE="CC";;
                        8) PAGE="API";;
                        9) PAGE="WEBDAV";;
                        10) PAGE="POSTGRESS";;
                        11) PAGE="VERTICA";;
                        12) PAGE="IC";;
                        13) PAGE="AQE";;
                        14) PAGE="CONNECTORS";;
                        15) PAGE="ADS";;
                esac
                if [ $PAGE -eq 0 ]; then
                    shift
                else
                    finishEdit
                fi
                ;;
                7)
                    echo "What web page do you want to change? "
                    echo "" #new row
                    echo "     --- Web Pages ---"
                    echo "***   1.  GOODDATA.COM"
                    echo "***   2.  HELP"
                    echo "***   3.  DEVPORTAL"

                    read WEB
                    case $WEB in
                            1) WEB="GD" ;;
                            2) WEB="HELP" ;;
                            3) WEB="DEV" ;;
                            "") echo "" ;;
                    esac
 #-------Added
                    echo "What is a new state? "
                    echo "" #new row
                    echo "     --- States ---"
                    echo "1.  All OK"
                    echo "2.  Problems but running"
                    echo "3.  Not working"
                    echo "4.  Performance problems"
                    echo "5.  unknown - to grey out"
                    echo "" #new row
                    echo -n "Your choice: "

                    read STATE
                    case $STATE in
                                1) STATE="OK";;
                                2) STATE="PROBLEM";;
                                3) STATE="DOWN";;
                                4) STATE="PERFORMANCE";;
                                5) STATE="UNKNOWN";;
                                0) return 0 ;;
                    esac

                    echo "What is a ticket (Zendesk, JIRA, PagerDuty allert)? ( Keep empty if no ticket yet) "

                    read TICKET

                    if [ $TICKET -eq 0 ]; then
                        return 0
                    else
                        echo "entered ticket: $TICKET"
                    fi

                    echo "Do you want to update history ? "
                    echo "" #new row
                    echo -n "Your choice: "

                    read HISTORY_FLAG
                    case $HISTORY_FLAG in
                            y) HISTORY_FLAG="y" ;;
                            Y) HISTORY_FLAG="y" ;;
                            N) HISTORY_FLAG="n" ;;
                            n) HISTORY_FLAG="n" ;;
                            0) return 0 ;;
                    esac

                    echo "Setting up Web page $WEB on to $STATE. $TICKET . History comment? - $HISTORY_FLAG "
                    echo "Do you want to proceed? "
                    echo "" #new row
                    echo -n "Your choice: "

                    read PROCEED
                    case $PROCEED in
                    y)
                        if [ $HISTORY_FLAG=="y" ]; then
                            ./editWebs.sh -w $WEB -s $STATE -T $TICKET
                        else
                            ./editWebs.sh -w $WEB -s $STATE -T $TICKET T -H
                        fi
                    ;;
                    Y)
                        if [ $HISTORY_FLAG=="y" ]; then
                            ./editWebs.sh -w $WEB -s $STATE -T $TICKET
                        else
                            ./editWebs.sh -w $WEB -s $STATE -T $TICKET T -H
                        fi
                        ;;
                    N) SCRIPT="blabla" ;;
                    n) SCRIPT="blabla" ;;
                    0) return 0 ;;
                    esac
                ;;
#-------Added


                8)
                    echo "What component do you want to change? "
                    echo "" #new row
                    echo "     --- Components ---"
                    echo "***   1.  ETL"
                    echo "***   2.  REPORTS COMPUTATION"
                    echo "***   3.  DATA STORAGE"
                    echo "***   4.  DATA MART"
                    echo "***   5.  EXPORTERS"
                    echo "***   6.  SECURITY"
                    echo "" #new row
                    echo "--- SubComponents --- "
                    echo "" #new row
                    echo "***   7.   CLOUD CONNECT"
                    echo "***   8.   API + CL TOOL"
                    echo "***   9.   WEBDAV, S3"
                    echo "***   10.  POSTGRESS DWHS"
                    echo "***   11.  VERTICA DWHS"
                    echo "***   12.  INTEGRATION CONSOLE"
                    echo "***   13.  AQE"
                    echo "***   14.  CONNECTORS"
                    echo "***   15.  ADS"
                    echo -n "Your choice: "

                read PAGE
                    case $PAGE in
                            1) PAGE="ETL";;
                            2) PAGE="REPORTS";;
                            3) PAGE="DS";;
                            4) PAGE="DM";;
                            5) PAGE="EXPORTERS";;
                            6) PAGE="SECURITY";;
                            7) PAGE="CC";;
                            8) PAGE="API";;
                            9) PAGE="WEBDAV";;
                            10) PAGE="POSTGRESS";;
                            11) PAGE="VERTICA";;
                            12) PAGE="IC";;
                            13) PAGE="AQE";;
                            14) PAGE="CONNECTORS";;
                            15) PAGE="ADS";;
                    esac
                    if [ $PAGE -eq 0 ]; then
                        shift
                    else
                        finishEdit
                    fi
                ;;

                esac

    echo "" #new row
    echo -n "Do you want to continue? yY=YES / nN = NO:"

    read CONTINUE
    case $CONTINUE in
            y) CONTINUE="y"
            ;;
            Y) PROCEED="y"
            ;;
            N) SCRIPT="blabla"
            ;;
            n) SCRIPT="blabla"
            ;;
    esac

shift
done


./logoutConfluence.sh

echo "" #new row
echo "Bye bye ... "



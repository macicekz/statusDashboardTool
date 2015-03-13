#  wizzard.sh
#
#  update pages summaries, login etc interactively
#
#  Created by Zdenek Macicek on 27.01.15.
#
#----------------------------------------------------------------------
PROGNAME=$(basename $0)
EXIT_FLAG=0
#----------------------------------------------------------------------
function setWebs()
{
    if [ $1  -eq 0 ]; then
        echo "" #new row
        echo "Question: What web page do you want to change? "
        echo "" #new row
        echo "     --- Web Pages ---"
        echo "***   1.  GOODDATA.COM"
        echo "***   2.  HELP"
        echo "***   3.  DEVPORTAL"
        echo "" #new row
        echo "***   4.  ALL"
        echo "" #new row
        echo -n "::Your choice >>> "

        read WEB
        case $WEB in
                1) WEB="GD" ;;
                2) WEB="HELP" ;;
                3) WEB="DEV";;
                4) WEB="ALL" ;;
                0) EXIT_FLAG=1;;
                "") echo "" ;;
        esac
            echo ":: Entered WEB :>>>  $WEB"
        else
            shift
        fi
}
#----------------------------------------------------------------------
function checkLogin
{
    source ../conf/user.cfg
    T_HOME=$TOOL_HOME
    TOKEN=`cat $T_HOME/conf/token`
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
function setState()
{
    if [ $1  -eq 0 ]; then
        echo "" #new row
        echo "Question: Wat is a new state? "
        echo "" #new row
        echo "     --- States ---"
        echo "1.  OK - UP and Running"
        echo "2.  PROBLEM but running"
        echo "3.  DOWN - Not working"
        echo "4.  PERFORMANCE DEGRADATION problem"
        echo "" #new row
        echo "5.  UNKNOWN - to grey out"
        echo "" #new row
        echo -n "::Your choice >>> "

        read STATE_P
        case $STATE_P in
                    1) STATE="OK";;
                    2) STATE="PROBLEM";;
                    3) STATE="DOWN";;
                    4) STATE="PERFORMANCE";;
                    5) STATE="UNKNOWN";;
                    0) EXIT_FLAG=1 ;;
        esac
            echo ":: Entered STATE :>>>  $STATE"
    else
        shift
    fi
}
#----------------------------------------------------------------------
function setTicket()
{
    if [ $1  -eq 0 ]; then
        echo "" #new row
        echo "Question: What is a ticket ? (Zendesk, JIRA, PagerDuty allert)? ( Keep empty if no ticket yet) "
        echo "" #new row
        echo -n "::Your choice >>> "

        read TICKET

        if [ $TICKET == "0" ]; then
            EXIT_FLAG=1
        else
            if [ $TICKET ]; then
                TICKET_FLAG="-T $TICKET"
            else
                TICKET_FLAG=""
            fi
            return 0
        fi
    echo ":: Entered TICKET :>>>  $TICKET"
    else
        return 0
    fi
}
#----------------------------------------------------------------------
function confirmUpdate()
{
    if [ $1  -eq 0 ]; then
        echo "Setting up: $PAGE on $DC to $STATE. "
        echo "Ticket: $TICKET ."
        echo "History comment : $HISTORY_FLAG. "
        echo "" #new row
        echo "Do you want to proceed? "
        echo "" #new row

        read PROCEED
        case $PROCEED in
                    y) echo "- Info : $LINENO: $PROGNAME : Proceeding ... "
                    ;;
                    Y) echo "- Info : $LINENO: $PROGNAME : Proceeding ... "
                    ;;
                    N) return 0"
                    ;;
                    n) return 0"
                    ;;
                    0) EXIT_FLAG=1 ;;
        esac
    else
        return 0
    fi
}
#----------------------------------------------------------------------
function setHistory()
{
    if [ $1  -eq 0 ]; then
        echo "Do you want to update history ? "
        echo "" #new row
        echo -n "::Your choice >>> "

        read HISTORY_FLAG
        case $HISTORY_FLAG in
                            y) HISTORY=""
                                echo ":: History will be updated ::"
                            ;;
                            Y) HISTORY=""
                                echo ":: History will be updated ::"
                            ;;
                            N) HISTORY="-H"
                                echo ":: History will not be updated ::"
                            ;;
                            n) HISTORY="-H"
                                echo ":: History will not be updated ::"
                            ;;
                            0) EXIT_FLAG=1 ;;
        esac
    else
        return 0
    fi
}
#----------------------------------------------------------------------
function setSummary()
{
    if [ $1  -eq 0 ]; then
        echo "" #new row
        echo "Question: What Summary do you want to change? "
        echo "***   1. Platform"
        echo "***   2. Components"
        echo "***   3. SubComponents"
        echo "" #new row
        echo "***   4. All SubComponents"
        echo "" #new row
        echo -n "::Your choice >>> "

        read PAGE_P
        case $PAGE_P in
                    1) PAGE="PLATFORM";;
                    2) PAGE="COMPONENTS";;
                    3) PAGE="SUBCOMPONENTS";;
                    4) PAGE="ALL";;
                    0) EXIT_FLAG=1;;
        esac
        echo ":: Entered Summary :>>>  $PAGE"
    else
        return 0
    fi
}
#----------------------------------------------------------------------
function setDataCenter()
{
    if [ $1  -eq 0 ]; then
        echo "" #new row
        echo "Question: What Data Center should be updated? "
        echo "" #new row
        echo "     --- Data Centers ---"
        echo "1.  NA1"
        echo "2.  EU1"
        echo "3.  NA2"
        echo "" #new row
        echo "4.  ALL"
        echo "" #new row
        echo -n "::Your choice >>> "

        read DC_P
        case $DC_P in
                   1) DC="NA1";;
                   2) DC="EU1";;
                   3) DC="NA2";;
                   4) DC="ALL";;
                   0) EXIT_FLAG=1 ;;
        esac
        echo ":: Entered Data Center :>>>  $DC"
    else
        return 0
    fi
}
#----------------------------------------------------------------------
function setPageName()
{
    if [ $1  -eq 0 ]; then
        echo "" #new row
        echo "Question: What Component do you want to change? "
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
        echo "" #new row
        echo -n "::Your choice >>> "

        read PAGE_P
        case $PAGE_P in
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
                    0) EXIT_FLAG=1;
        esac

        if [ $PAGE_P -gt 6 ]; then
            echo ":: Entered Component :>>>  $PAGE"
        else
            echo ":: Entered SubComponent :>>>  $PAGE"
        fi
    else
        return 0
    fi
}
#----------------------------------------------------------------------
function setRelease()
{
    if [ $1  -eq 0 ]; then
        echo "" #new row
        echo "Question: What Data Center should be updated? "
        echo "" #new row
        echo "     --- Data Centers ---"
        echo "1.  NA1"
        echo "2.  EU1"
        echo "3.  NA2"
        echo "" #new row
        echo "4.  ALL"
        echo "" #new row
        echo -n "::Your choice >>> "

        read DC_P
        case $DC_P in
                1) DC="NA1";;
                2) DC="EU1";;
                3) DC="NA2";;
                4) DC="ALL";;
                0) EXIT_FLAG=1 ;;
        esac
        echo ":: Entered Data Center :>>>  $DC"
        echo "Question: What is a Release URL in Confluence ? (check https://confluence.intgdc.com/display/plat/Delivery+and+QA+Portal) "
        echo "" #new row
        echo -n ":: URL >>> "

        if [ $EXIT_FLAG -eq 0 ]; then
            read TICKET
            if [ $TICKET ]; then
                TICKET_FLAG="-T $TICKET"
            else
                TICKET_FLAG="-T RELEASE"
            fi
            echo ":: Entered Release URL :>>>  $TICKET"
            echo "" #new row
        else
            return 0
        fi
    else
        return 0
    fi
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
        echo "***  1. LOGIN WATCH (no change in other parts)"
        echo "***  2. LOGOUT WATCH (no change in other parts)"
        echo ""
        echo "***  3. WATCH Login DASHBOARD green"
        echo "***  4. WATCH Logout DASHBOARD grey"
        echo ""
        echo "***  5. change SUMMARY"
        echo "***  6. change OUR WEBS"
        echo "***  7. change COMPONENT or SUBCOMPONENT"
        echo ""
        echo "***  8. Component TREE update - to update the whole tree of components"
        echo "" #new row
        echo "***  11. RELEASE - Start"
        echo "***  12. RELEASE - End"
        echo "" #new row
        echo "***  13. AllGrey  - no History logged"
        echo "***  17. AllOK - no History logged"
        echo "" #new row
        echo "***  0. go back to start or exit in any place within Wizzard"
        echo "" #new row
        echo -n ":: Enter your wish :>>> "

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
                3)  setDataCenter $EXIT_FLAG
                    if [ $EXIT_FLAG -eq 0 ]; then
                        echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/allOK_$DC.log "
                        ./allOK_$DC.sh>../logs/allOK_$DC.log
                    else
                        shift
                    fi
                    shift
                    ;;
                4)  setDataCenter $EXIT_FLAG
                    if [ $EXIT_FLAG -eq 0 ]; then
                        echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/allGrey_$DC.log "
                        ./allGrey_$DC.sh>../logs/allGrey_$DC.log
                    else
                        shift
                    fi
                    shift
                    ;;
                0) shift ;;
                5)  setSummary $EXIT_FLAG
                    echo "" #new row
                    setState $EXIT_FLAG
                    echo "" #new row
                    setDataCenter $EXIT_FLAG
                    echo "" #new row
                    setTicket $EXIT_FLAG
                    echo "" #new row
                    if [ $EXIT_FLAG -eq 0 ]; then
                        if [ $PAGE == "ALL" ]; then
                            echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_$PAGE.log"
                            ./summarys.sh -p PLATFORM -s $STATE -D $DC $TICKET_FLAG $HISTORY > ../logs/summarys_$PAGE_$DC.log
                            echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_$PAGE.log"
                            ./summarys.sh -p COMPONENTS -s $STATE -D $DC $TICKET_FLAG $HISTORY > ../logs/summarys_$PAGE_$DC.log
                            echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_$PAGE.log"
                            ./summarys.sh -p SUBCOMPONENTS -s $STATE -D $DC $TICKET_FLAG $HISTORY > ../logs/summarys_$PAGE_$DC.log
                        else
                            echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/summarys_$PAGE.log"
                            ./summarys.sh -p $PAGE -s $STATE -D $DC $TICKET_FLAG $HISTORY > ../logs/summarys_$PAGE_$DC.log
                        fi
                    else
                        shift
                    fi
                ;;
                7)  setPageName $EXIT_FLAG
                    setState $EXIT_FLAG
                    setDataCenter $EXIT_FLAG
                    setTicket $EXIT_FLAG
                    setHistory $EXIT_FLAG
                    if [ $EXIT_FLAG -eq 0 ]; then
                        if [ $PAGE -eq 'ALL' ]; then
                            echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/All$STATE_$DC.log"
                            ./allOK_$DC.sh > ../logs/All$STATE_$DC.log
                        else
                            echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/editPage_$PAGE.log"
                            ./editPage.sh -p $PAGE -s $STATE -D $DC $TICKET_FLAG $HISTORY > ../logs/editPage_$PAGE_$DC.log
                        fi
                    else
                        shift
                    fi
                ;;
                6)  setState $EXIT_FLAG
                    setWebs $EXIT_FLAG
                    setHistory $EXIT_FLAG
                    if [ $EXIT_FLAG -eq 0 ]; then
                        echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/editWebs_$WEB.log"
                        ./editWebs.sh -w $WEB -s $STATE $TICKET_FLAG $HISTORY > ../logs/editWebs_$WEB_$DC.log
                    else
                        shift
                    fi
                ;;
                8) # Tree Update
                    setPageName $EXIT_FLAG
                    setState $EXIT_FLAG
                    setDataCenter $EXIT_FLAG
                    setTicket $EXIT_FLAG
                    setHistory $EXIT_FLAG
                    if [ $EXIT_FLAG -eq 0 ]; then
#                        echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/treeUpdate_$PAGE.log"
                        ./updateTree.sh -p $PAGE -s $STATE -D $DC $TICKET_FLAG $HISTORY #> ../logs/treeUpdate_$PAGE_$DC.log
                    else
                        shift
                    fi
                    echo "" #new row
                    echo "To update Summary, please, use selection #5 in main menu. "
                ;;
                11) #Release START
                    setRelease $EXIT_FLAG
                    if [ $EXIT_FLAG -eq 0 ]; then
                        echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/release_START_$DC"
                        ./release.sh -s -D $DC $TICKET_FLAG $HISTORY > $T_HOME/logs/release_START_$DC.log
                    else
                        shift
                    fi
                ;;
                12) #Release
                    setRelease $EXIT_FLAG
                    if [ $EXIT_FLAG -eq 0 ]; then
                        echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/release_END_$DC"
                        ./release.sh -e -D $DC $HISTORY > $T_HOME/logs/release_END_$DC.log
                    else
                        shift
                    fi
                ;;
                13) #Release START
                    setDataCenter $EXIT_FLAG
                    if [ $EXIT_FLAG -eq 0 ]; then
                        echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/release_AllGrey_$DC.log"
                        ./allGrey_$DC.sh > $T_HOME/logs/release_AllGrey_$DC.log
                        echo "- Info : $LINENO: $PROGNAME : Logged into $T_HOME/logs/release_AllGrey_$DC.log"
                    else
                        shift
                    fi
                ;;
                17) #Release START
                    setDataCenter $EXIT_FLAG
                    if [ $EXIT_FLAG -eq 0 ]; then
                        echo "- Info : $LINENO: $PROGNAME : Logging into $T_HOME/logs/release_AllOK_$DC.log"
                        ./allOK_$DC.sh > $T_HOME/logs/release_AllOK_$DC.log
                        echo "- Info : $LINENO: $PROGNAME : Logged into $T_HOME/logs/release_AllOK_$DC.log"
                    else
                        shift
                    fi
                ;;
        esac

        echo "" #new row
        echo -n "Do you want to continue? yY=YES / nN = NO:"
        echo "" #new row
        echo -n "::Your choice >>> "

        read CONTINUE
        case $CONTINUE in
            y)
                EXIT_FLAG=0
                CONTINUE="y"
                TICKET_FLAG=""
            ;;
            Y)
                EXIT_FLAG=0
                CONTINUE="y"
                TICKET_FLAG=""
            ;;
            N) CONTINUE="N"
            ;;
            N) CONTINUE="N"
            ;;
        esac
shift
done

./logoutConfluence.sh

echo "" #new row
echo "Bye bye ... "
echo "" #new row


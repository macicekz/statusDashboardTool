#  wizzard.sh
#
#  update pages summaries, login etc interactively
#
#  Created by Zdenek Macicek on 27.01.15.
#


function finishEdit
{
echo "What is a new state? "
echo "" #new row
echo "     --- States ---"
echo "1.  All OK"
echo "2.  Problems but running"
echo "3.  Not working"
echo "4.  Performance problems"
echo "5.  unknown - to grey out"

read STATE
case $STATE in
1) STATE="OK";;
2) STATE="PROBLEM";;
3) STATE="DOWN";;
4) STATE="PERFORMANCE";;
5) STATE="UNKNOWN";;
esac

echo "What is a ticket? ( write NO if there is no ticket) "
read TICKET
echo "entered ticket: $TICKET"
echo "Do you want to update history ? "
read HISTORY_FLAG
case $HISTORY_FLAG in
y) HISTORY_FLAG="y"
;;
Y) HISTORY_FLAG="y"
;;
N) HISTORY_FLAG="n"
;;
n) HISTORY_FLAG="n"
;;
esac

echo "Setting up $PAGE on NA1 to $STATE. $TICKET . History commnet? - $HISTORY_FLAG "
echo "Do you want to proceed? "


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
esac

case $SCRIPT in
        5)
             if [ $HISTORY_FLAG=="y" ]; then
                ./summarys.sh -p $PAGE -s $STATE -D NA1 -T $TICKET
             else
                ./summarys.sh -p $PAGE -s $STATE -D NA1 -T $TICKET -H
             fi
        ;;
        6)
             if [ $HISTORY_FLAG == y ]; then
                echo  "HISTORY"
                ./editPage.sh -p $PAGE -s $STATE -D NA1 -T $TICKET
             else
             echo "NO HISTORY"
            ./editPage.sh -p $PAGE -s $STATE -D NA1 -T $TICKET -H
             fi

        ;;
        7)
            if [ $HISTORY_FLAG=="y" ]; then
                ./updateTree.sh -p $PAGE -s $STATE -D NA1 -T $TICKET
            else
                ./updateTree.sh -p $PAGE -s $STATE -D NA1 -T $TICKET -H
            fi
        ;;
        esac


}
CONTINUE="y"

./loginConfluence.sh

while [ $CONTINUE == "y" ]
do
    echo " === choose type of change : "
    echo "*****************************************************"
    echo "***    ***     ***    ***    ***    ***    ***    ***"
    echo "***  1. login platform watch \(no change in other parts\)"
    echo "***  2. logout platform watch \(no change in other parts\)"
    echo ""
    echo "***  3. login platform watch and make whole dashboard green"
    echo "***  4. logout platform watch and make whole dashboard grey"
    echo ""
    echo "***  5. Change summary"
    echo "***  6. change component"
    echo ""
    echo "***  7.update the whole tree of components change component"
    echo "***    ***    ***     ***    ***    ***    ***    ***    ***"
    echo "*****************************************************"

    read SCRIPT
    case $SCRIPT in
            1)
                ./wlogin.sh
                exit 1;;
            2) ./wlogout.sh
                exit 1
                ;;
            3) ./allOK.sh
                exit 1
                ;;
            4) ./allGrey.sh
                exit 1
                ;;

            5)
                echo "What Summary do you want to change? "
                echo "***   1. Platform"
                echo "***   2. Components"
                echo "***   3. SubComponents"

                read PAGE
                case $PAGE in
                            1)
                                PAGE="PLATFORM"
                                echo "What is a new state? "
                                echo "" #new row
                                echo "     --- States ---"
                                echo "1.  All OK"
                                echo "2.  Problems but running"
                                echo "3.  Not working"
                                echo "4.  Performance problems"
                                echo "5.  unknown - to grey out"

                                read STATE
                                case $STATE in
                                1) STATE="OK";;
                                2) STATE="PROBLEM";;
                                3) STATE="DOWN";;
                                4) STATE="PERFORMANCE";;
                                5) STATE="UNKNOWN";;
                                esac
                                ./summarys.sh -p $PAGE -s $STATE -D NA1
                            ;;
                            2)
                                PAGE="COMPONENTS"
                                echo "What is a new state? "
                                echo "" #new row
                                echo "     --- States ---"
                                echo "1.  All OK"
                                echo "2.  Problems but running"
                                echo "3.  Not working"
                                echo "4.  Performance problems"
                                echo "5.  unknown - to grey out"

                                read STATE
                                case $STATE in
                                1) STATE="OK";;
                                2) STATE="PROBLEM";;
                                3) STATE="DOWN";;
                                4) STATE="PERFORMANCE";;
                                5) STATE="UNKNOWN";;
                                esac
                                ./summarys.sh -p $PAGE -s $STATE -D NA1
                            ;;
                            3)
                                PAGE="SUBCOMPONENTS"
                                echo "What is a new state? "
                                echo "" #new row
                                echo "     --- States ---"
                                echo "1.  All OK"
                                echo "2.  Problems but running"
                                echo "3.  Not working"
                                echo "4.  Performance problems"
                                echo "5.  unknown - to grey out"

                                read STATE
                                case $STATE in
                                            1) STATE="OK";;
                                            2) STATE="PROBLEM";;
                                            3) STATE="DOWN";;
                                            4) STATE="PERFORMANCE";;
                                            5) STATE="UNKNOWN";;
                                esac
                                ./summarys.sh -p $PAGE -s $STATE -D NA1
                            ;;
                esac
            ;;
            6)
                echo "What Component do you want to change? "
                echo "" #new row
                echo "     --- Components ---"
                echo "1.  ETL"
                echo "2. REPORTS COMPUTATION"
                echo "3.  DATA STORAGE"
                echo "4.  DATA MART"
                echo "5.  EXPORTERS"
                echo "6.  SECURITY"
                echo "" #new row
                echo "--- SubComponents --- "
                echo "" #new row
                echo "7.  CLOUD CONNECT"
                echo "8.  API + CL TOOL"
                echo "9.  WEBDAV, S3"
                echo "10.  POSTGRESS DWHS"
                echo "11.  VERTICA DWHS"
                echo "12.  INTEGRATION CONSOLE"
                echo "13.  AQE"
                echo "14.  CONNECTORS"
                echo "15.  ADS"
                echo "" #new row
                echo "--- Webs ---"
                echo "" #new row
                echo "16.  Web gooddata.com   "
                echo "17  Web devportal"
                echo "18  Web help"
                echo "" #new row

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
                    16) PAGE="WEBS"
                        DC="GOODDATA.COM";;
                    17) PAGE="WEBS"
                        DC="DEVPORTAL";;
                    18) PAGE="WEBS"
                        DC="HELP";;

            esac
            finishEdit
            ;;
            7)
                echo "What component do you want to change? "
                echo "" #new row
                echo "     --- Components ---"
                echo "1.  ETL"
                echo "2. REPORTS COMPUTATION"
                echo "3.  DATA STORAGE"
                echo "4.  DATA MART"
                echo "5.  EXPORTERS"
                echo "6.  SECURITY"
                echo "" #new row
                echo "--- SubComponents --- "
                echo "" #new row
                echo "7.  CLOUD CONNECT"
                echo "8.  API + CL TOOL"
                echo "9.  WEBDAV, S3"
                echo "10.  POSTGRESS DWHS"
                echo "11.  VERTICA DWHS"
                echo "12.  INTEGRATION CONSOLE"
                echo "13.  AQE"
                echo "14.  CONNECTORS"
                echo "15.  ADS"

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
            finishEdit
            ;;

            esac

echo "Do you want to continue? "
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

echo "Bye bye"

./logoutConfluence.sh


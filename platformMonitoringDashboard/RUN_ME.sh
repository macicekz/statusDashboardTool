##!/bin/bash
#Change Logtest
# -----------------------------
# Fri Jan 23 08:00:00 CET 2015 - ZMA
#   - First draft.
# -----------------------------
# Fri Feb 13 2015 - ZMA
#   - 2.0
#   - First stable release
# ----------------- - ZMA------------
# Tue Feb 18 2015
#   - 2.1.
#   - Fix for update of Webs
#   logging out previously logged Watch
#   - Minor bug fixes
# -----------------------------
# Tue Feb 24 2015 - ZMA
#   - Hidden pasword during entering
#   - Logging off previosly logged watch
#   - Minor bug fixes
# -----------------------------
# Wed Feb 25 2015 - ZMA
#   - Order of logging out previously logged Watch
#   - Minor bug fixes
# -----------------------------
# Wed Mar 04 2015 - ZMA
#   - setup for missing directories added
#   - some dummy messages removed/updated
#   - Minor Bug fixes
# -----------------------------
# Mon Mar 09 2015 - ZMA
#   - Release handling added
#   - Minor Bug fixes
# -----------------------------
# Tue Mar 10 2015 - ZMA
#   - Release handling updated
#   - Minor Bug fixes
# -----------------------------
# Tue Mar 11 2015 - ZMA
#   - Multiple DC handling updated
#   - Wizzard update to support Multiple DC
#   - AllOK and AllGrey scripts for mutliple DC added
#   - Minor Bug fixes
# -----------------------------
# Thu Mar 12 2015 - ZMA
#   - Login/logoff of watch removed from history
#   - Minor fixes
# -----------------------------
# Fri Mar 13 2015 - ZMA
#   - logoff logging to history fixed
#   - fixed https://github.com/macicekz/statusDashboardTool/issues/2 - Test flow
#   - treeUpdate set for Components and Subcomponents only
#   - minor fixes
# -----------------------------
# Fri Mar 20 2015 - ZMA
#   - Watch status as a URL to the Watch status page
#   - minor fixes
# -----------------------------
TOOL_HOME=$(pwd)

clear
case $1 in
   "") $TOOL_HOME/doc/first.sh
	;;
   -h)	less $TOOL_HOME/doc/help.txt
    ;;
   -H)  less $TOOL_HOME/doc/help.txt
    ;;
   -help) less $TOOL_HOME/doc/help.txt
    ;;
   -s)
        cd $TOOL_HOME/scripts
    	./setup.sh -u
        ./setup.sh -S
    ;;
    -S)
        cd $TOOL_HOME/scripts
        ./setup.sh -S
    ;;

   -Wizz)
        cd $TOOL_HOME/scripts
        ./wizzard.sh
    ;;
   -wod)
            echo "" #new row
            echo "- Info : $LINENO: $PROGNAME : Loggin into ./logs/wlogin.log "
            echo "" #new row
            cd $TOOL_HOME/scripts
            ./wlogin.sh > ../logs/wlogin.log
    ;;
   -wood)
            echo "" #new row
            echo "- Info : $LINENO: $PROGNAME : Loggin into ./logs/wlogout.log "
            echo "" #new row
            cd $TOOL_HOME/scripts
            ./wlogout.sh > ../logs/wlogout.log
    ;;
   -green)
            echo "" #new row
            echo "- Info : $LINENO: $PROGNAME : Loggin into ./logs/allOK.log "
            echo "" #new row
            cd $TOOL_HOME/scripts
            ./allOK.sh  > ../logs/allOK.log
    ;;
   -grey)
            echo "" #new row
            echo "- Info : $LINENO: $PROGNAME : Loggin into ./logs/allGrey.log "
            echo "" #new row
            cd $TOOL_HOME/scripts
            ./allGrey.sh > ../logs/allGrey.log
   ;;
   -list)   cat $TOOL_HOME/doc/listPage.sh
    ;;
   -D)  rm  $TOOL_HOME/conf/user.cfg
   ;;
esac


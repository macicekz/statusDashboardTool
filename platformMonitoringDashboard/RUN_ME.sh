##!/bin/bash
#Change Logtest
# -----------------------------
# Fri Jan 23 08:00:00 CET 2015
#   - First draft.
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
   -s)  cd $TOOL_HOME/scripts
    	./setup.sh -u
        ./setup.sh -S
    ;;
   -Wizz)
        cd $TOOL_HOME/scripts
        ./wizzard.sh
    ;;
   -wod)
            cd $TOOL_HOME/scripts
            ./wlogin.sh > ../logs/wlogin.log
    ;;
   -wood)
            cd $TOOL_HOME/scripts
            ./wlogout.sh > ../logs/wlogout.log
    ;;
   -green)
	   cd $TOOL_HOME/scripts
	  ./allOK.sh  > ../logs/allOK.log
    ;;
   -grey)  
	   cd $TOOL_HOME/scripts
          ./allGrey.sh > ../logs/allGrey.log
   ;;
   -list)   cat $TOOL_HOME/doc/listPage.sh
    ;;
   -D)  rm  $TOOL_HOME/conf/user.cfg
   ;;
esac


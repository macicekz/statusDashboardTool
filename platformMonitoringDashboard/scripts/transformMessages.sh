#!/bin/sh

#  transformMessages.sh fPVh
#           -f [file to transform] OR -P [file to get properties] -s [ file to get States] -h [converts UTF8 html chars to readable form]
#  
#
#  Created by Zdenek Macicek on 27.01.15.
#

function convertSpecialCharracters
{
    sed -e 's+&lt;+<+g' ./$FILE  | sed -e 's+&gt;+>+g' | sed -e 's+&quot;+"+g'  > "./htmlCharsConvert_$FILE"
    echo "- Info : $LINENO: $PROGNAME : File $FILE has been transformed to $T_HOME/data/htmlCharsConvert_$FILE "
}
#----------------------------------------------------------------------
function getProperties
{
    echo "hpflag `xmllint --xpath "//getPageReturn/homePage/text()" $T_HOME/data/$FILE`"
    echo "pversion `xmllint --xpath "//getPageReturn/version/text()" $T_HOME/data/$FILE`"
    echo "sname `xmllint --xpath "//getPageReturn/space/text()" $T_HOME/data/$FILE`"
    echo "purl `xmllint --xpath "//getPageReturn/url/text()" $T_HOME/data/$FILE`"
    echo "pid `xmllint --xpath "//getPageReturn/id/text()" $T_HOME/data/$FILE`"
    echo "parentid `xmllint --xpath "//getPageReturn/parentId/text()" $T_HOME/data/$FILE`"
    echo "modified `xmllint --xpath "//getPageReturn/modified/text()" $T_HOME/data/$FILE`"

}
#----------------------------------------------------------------------
function getStates
{
    CONTENT=`xmllint --xpath "//getPageReturn/content/text()" $T_HOME/data/$FILE`
    echo "Content: $CONTENT"
    echo "" #new row

    echo "actual state of page is: "
    echo "" #new row
    echo "Content:" $CONTENT | sed -e 's+<th+\'$'\n<th+g' |sed -e 's+</tr+\'$'\n+g' | grep title | sed -e 's+<a>+\'$'\n<a>+g' | awk 
 sed -e 's+ac:parameter></ac:structured-macro> </a></th>++g'
}
#----------------------------------------------------------------------
function getElementsByRow
{
    convertSpecialCharracters
    cat ./htmlCharsConvert_$FILE | sed -e 's+><+>\'$'\n<+g' ../htmlCharsConvert_$FILE  > "./readable_$FILE"
    echo "- Info : $LINENO: $PROGNAME : File $FILE has been transformed to $T_HOME/data/readable_$FILE "
    chmod
}
#----------------------------------------------------------------------
function getState ()
{
convertSpecialCharracters

case $1 in
        1)  echo "State of NA1 is: "
            cat ./htmlCharsConvert_$FILE | awk -F $'"title">' '{print  $3 }' | awk -F $'<' '{print $1}'
        ;;
2)  echo "State of EU1 is: "
cat ./htmlCharsConvert_$FILE | awk -F $'"title">' '{print  $4 }' | awk -F $'<' '{print $1}'
;;
3)  echo "State of NA2 is: "
cat ./htmlCharsConvert_$FILE | awk -F $'"title">' '{print  $5 }' | awk -F $'<' '{print $1}'
;;
esac
}
#----------------------------------------------------------------------
#----------------------------------------------------------------------
PROGNAME=$(basename $0)

#Reading input
FILE=$2
TYPE=$1
DC=$3

echo "- Info : $LINENO: $PROGNAME : START transform ... "
echo "- Info : $LINENO: $PROGNAME : info : Reading user configuration. "

source ../conf/user.cfg
T_HOME=$TOOL_HOME

cd "$T_HOME/data"

case $TYPE in
            -f) getElementsByRow ;;
            -P) getProperties ;;
            -s) getState $DC;;
            -h) convertSpecialCharracters ;;
            "")
            ls -al ../logs/messages/*
            echo "" #new row
            echo "no parameters given "
            echo "" #new row
            echo "Usage: "
            echo "-f [file to transform] OR -P [file to get properties] -V [ file to get States]"
            ;;
esac

#cat "./readable_$FILE"

echo "- Info : $LINENO: $PROGNAME : END "
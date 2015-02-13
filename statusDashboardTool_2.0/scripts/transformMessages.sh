#!/bin/sh

#  transformMessages.sh -f [file to transform] OR -P [file to transform]
#  
#
#  Created by Zdenek Macicek on 27.01.15.
#

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
#function getValues
#{
#echo "actual state of page is: "
#sed -e 's+&lt;+<+g'  ./$FILE | sed -e 's+&gt;+>+g' | sed -e 's+&quot;+"+g' |   | grep highlight | awk  -F $'>' '{print $5 "," $7 }' | sed -e 's+</ac:parameter++g' | sed -e 's+grey++g'
#}

function getFile
{
sed -e 's+&lt;+<+g' ./$FILE | sed -e 's+&gt;+>+g' | sed -e 's+&quot;+"+g' |  sed -e 's+><+>\'$'\n<+g' > "./readable_$FILE"
echo "- Info : $LINENO: $PROGNAME : File $FILE has been transformed to $T_HOME/data/readable_$FILE "
}

PROGNAME=$(basename $0)

FILE=$2
TYPE=$1

source ../conf/user.cfg

T_HOME=$TOOL_HOME

cd "$T_HOME/data"


case $TYPE in
-f)
echo "- Info : $LINENO: $PROGNAME : START "
echo "- Info : $LINENO: $PROGNAME : info : Reading user configuration. "
getFile
;;
-P) getProperties
;;
-V) getValues

;;
"") echo "no parameters given"
;;
esac


#cat "./readable_$FILE"

echo "- Info : $LINENO: $PROGNAME : END "
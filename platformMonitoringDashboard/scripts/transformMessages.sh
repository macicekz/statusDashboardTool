#!/bin/sh

#  transformMessages.sh -f [file to transform] OR -P [file to transform] -V [ file to transform]
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
function getValues
{
CONTENT=`xmllint --xpath "//getPageReturn/content/text()" $T_HOME/data/$FILE`
echo "Content: $CONTENT"
echo "" #new row

echo "actual state of page is: "
echo "Content:" $CONTENT | sed -e 's+&lt;+<+g' | sed -e 's+%2C+ +g'| sed -e 's+&gt;+>+g' | sed -e 's+&quot;+"+g' | sed -e 's+<th+\'$'\n<th+g' |sed -e 's+</tr+\'$'\n+g' | grep title | sed -e 's+<a>+\'$'\n<a>+g' | awk -F $'"' '{print  $7  $13  }' | sed -e 's+ac:parameter></ac:structured-macro> </a></th>++g' | sed -e 's+\'$'\n+ahoj+g' 

#| sed -e 's+grey++g'     |
}

function getResponseReadable
{
sed -e 's+&lt;+<+g' ./$FILE | sed -e 's+&gt;+>+g' | sed -e 's+&quot;+"+g' |  sed -e 's+><+>\'$'\n<+g' > "./readable_$FILE"
echo "- Info : $LINENO: $PROGNAME : File $FILE has been transformed to $T_HOME/data/readable_$FILE "
chmod
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
getResponseReadable
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
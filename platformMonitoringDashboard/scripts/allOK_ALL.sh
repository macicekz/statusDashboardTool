#!/bin/sh

#  allOK_ALL.sh
#  
#
#  Created by Zdenek Macicek on 13.03.15.
#
#!/bin/sh

#  allGrey_ALL.sh
#
#
#  Created by Zdenek Macicek on 13.03.15.
#

./wlogin.sh

./editPage.sh -p AQE -s OK -D ALL -H
./editPage.sh -p CC -s OK -D ALL -H
./editPage.sh -p API -s OK -D ALL -H
./editPage.sh -p CONNECTORS -s OK -D ALL -H
./editPage.sh -p WEBDAV  -s OK -D ALL -H
./editPage.sh -p ADS  -s OK -D ALL -H
./editPage.sh -p POSTGRESS -s OK -D ALL -H
./editPage.sh -p VERTICA -s OK -D ALL -H
./editPage.sh -p SECURITY -s OK -D ALL -H
./editPage.sh -p EXPORTERS -s OK -D ALL -H
./editPage.sh -p DM -s OK -D ALL -H
./editPage.sh -p DS  -s OK -D ALL -H
./editPage.sh -p REPORTS  -s OK -D ALL -H
./editPage.sh -p ETL  -s OK -D ALL -H
./editPage.sh -p IC  -s OK -D ALL -H

./summarys.sh -p PLATFORM -s OK -D ALL -H
./summarys.sh -p COMPONENTS -s OK -D ALL -H
./summarys.sh -p SUBCOMPONENTS -s OK -D ALL -H
./editWebs.sh -w ALL -s OK -H

./logoutConfluence.sh
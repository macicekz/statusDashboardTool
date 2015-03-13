#!/bin/sh

#  allGrey_ALL.sh
#  
#
#  Created by Zdenek Macicek on 13.03.15.
#
./wlogout.sh

./editPage.sh -p AQE -s UNKNOWN -D ALL -H
./editPage.sh -p CC -s UNKNOWN -D ALL -H
./editPage.sh -p API -s UNKNOWN -D ALL -H
./editPage.sh -p CONNECTORS -s UNKNOWN -D ALL -H
./editPage.sh -p WEBDAV  -s UNKNOWN -D ALL -H
./editPage.sh -p ADS  -s UNKNOWN -D ALL -H
./editPage.sh -p POSTGRESS -s UNKNOWN -D ALL -H
./editPage.sh -p VERTICA -s UNKNOWN -D ALL -H
./editPage.sh -p SECURITY -s UNKNOWN -D ALL -H
./editPage.sh -p EXPORTERS -s UNKNOWN -D ALL -H
./editPage.sh -p DM -s UNKNOWN -D ALL -H
./editPage.sh -p DS  -s UNKNOWN -D ALL -H
./editPage.sh -p REPORTS  -s UNKNOWN -D ALL -H
./editPage.sh -p ETL  -s UNKNOWN -D ALL -H
./editPage.sh -p IC  -s UNKNOWN -D ALL -H

./summarys.sh -p PLATFORM -s UNKNOWN -D ALL -H
./summarys.sh -p COMPONENTS -s UNKNOWN -D ALL -H
./summarys.sh -p SUBCOMPONENTS -s UNKNOWN -D ALL -H
./editWebs.sh -w ALL -s UNKNOWN -H

./logoutConfluence.sh
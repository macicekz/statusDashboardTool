#!/bin/bash

#Set whole dashboard Grey
# ./allGrey 

./loginConfluence.sh

./wlogout.sh

./editPage.sh -p AQE -s UNKNOWN -D EU1 -H
./editPage.sh -p CC -s UNKNOWN -D EU1 -H
./editPage.sh -p API -s UNKNOWN -D EU1 -H
./editPage.sh -p CONNECTORS -s UNKNOWN -D EU1 -H
./editPage.sh -p WEBDAV  -s UNKNOWN -D EU1 -H
./editPage.sh -p ADS  -s UNKNOWN -D EU1 -H
./editPage.sh -p POSTGRESS -s UNKNOWN -D EU1 -H
./editPage.sh -p VERTICA -s UNKNOWN -D EU1 -H
./editPage.sh -p SECURITY -s UNKNOWN -D EU1 -H
./editPage.sh -p EXPORTERS -s UNKNOWN -D EU1 -H
./editPage.sh -p DM -s UNKNOWN -D EU1 -H
./editPage.sh -p DS  -s UNKNOWN -D EU1 -H
./editPage.sh -p REPORTS  -s UNKNOWN -D EU1 -H
./editPage.sh -p ETL  -s UNKNOWN -D EU1 -H
./editPage.sh -p IC  -s UNKNOWN -D EU1 -H

./summarys.sh -p PLATFORM -s UNKNOWN -D EU1 -H
./summarys.sh -p COMPONENTS -s UNKNOWN -D EU1 -H
./summarys.sh -p SUBCOMPONENTS -s UNKNOWN -D EU1 -H
./editWebs.sh -w ALL -s UNKNOWN -H

./logoutConfluence.sh



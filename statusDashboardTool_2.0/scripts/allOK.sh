#!/bin/bash

./loginConfluence.sh

./wlogin.sh

./editPage.sh -p AQE -s OK -D NA1 -H
./editPage.sh -p CC -s OK -D NA1 -H
./editPage.sh -p API -s OK -D NA1 -H
./editPage.sh -p CONNECTORS -s OK -D NA1 -H
./editPage.sh -p WEBDAV -s OK -D NA1 -H
./editPage.sh -p ADS -s OK -D NA1 -H
./editPage.sh -p POSTGRESS -s OK -D NA1 -H
./editPage.sh -p VERTICA -s OK -D NA1 -H
./editPage.sh -p SECURITY -s OK -D NA1 -H
./editPage.sh -p EXPORTERS -s OK -D NA1 -H
./editPage.sh -p DM -s OK -D NA1 -H
./editPage.sh -p DS -s OK -D NA1 -H
./editPage.sh -p REPORTS -s OK -D NA1 -H
./editPage.sh -p ETL -s OK -D NA1 -H
./editPage.sh -p IC -s OK -D NA1 -H

./summarys.sh -p PLATFORM -s OK -D NA1 -H
./summarys.sh -p COMPONENTS -s OK -D NA1 -H
./summarys.sh -p SUBCOMPONENTS -s OK -D NA1 -H
./editPage.sh -p WEBS -s OK -D ALL -H

./logoutConfluence.sh



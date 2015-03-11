#!/bin/bash

echo "" #new row
echo "- Info : $LINENO: $PROGNAME : Logging in.... "
./loginConfluence.sh

echo "- Info : $LINENO: $PROGNAME : Setting up state of watch.... "
./wlogin.sh

echo "- Info : $LINENO: $PROGNAME : Setting up AQE .... "
./editPage.sh -p AQE -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up CLOUD CONNECT .... "
./editPage.sh -p CC -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up API + CL TOOL .... "
./editPage.sh -p API -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up CONNECTORS .... "
./editPage.sh -p CONNECTORS -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up WEBDAV, S3 .... "
./editPage.sh -p WEBDAV -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up ADS .... "
./editPage.sh -p ADS -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up POSTGRESS DWHs .... "
./editPage.sh -p POSTGRESS -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up VERTICA DWHs .... "
./editPage.sh -p VERTICA -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up SECURITY .... "
./editPage.sh -p SECURITY -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up EXPORTERS .... "
./editPage.sh -p EXPORTERS -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up DATA MART .... "
./editPage.sh -p DM -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up DATA STORAGE .... "
./editPage.sh -p DS -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up REPORTS COMPUTATION .... "
./editPage.sh -p REPORTS -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up ETL .... "
./editPage.sh -p ETL -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up INTEGRATION CONSOLE .... "
./editPage.sh -p IC -s OK -D EU1 -H


echo "- Info : $LINENO: $PROGNAME : Setting up Platform overview .... "
./summarys.sh -p PLATFORM -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up Components overview .... "
./summarys.sh -p COMPONENTS -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up Subcomponents overview .... "
./summarys.sh -p SUBCOMPONENTS -s OK -D EU1 -H
echo "- Info : $LINENO: $PROGNAME : Setting up Webs .... "
./editWebs.sh -w ALL -s OK -H

echo "- Info : $LINENO: $PROGNAME : Logging out .... "
./logoutConfluence.sh



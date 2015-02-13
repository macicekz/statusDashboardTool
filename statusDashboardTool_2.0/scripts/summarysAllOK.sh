#!/bin/bash

./loginConfluence.sh

./summarys.sh -p PLATFORM -s OK -D NA1 -H
./summarys.sh -p COMPONENTS -s OK -D NA1 -H
./summarys.sh -p SUBCOMPONENTS -s OK -D NA1 -H
./editPage.sh -p WEBS -s OK -D ALL -H

#!/bin/bash

./logoutConfluence.sh
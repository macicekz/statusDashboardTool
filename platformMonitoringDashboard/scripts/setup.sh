#!/bin/bash

cd ../
TOOL_HOME=$(pwd)
case $1 in

-D)
    rm $TOOL_HOME/conf/user.cfg
    rm $TOOL_HOME/conf/token
;;
-u)
    echo "Giving rights to control this tool to current user......"
    chmod -R u+x $TOOL_HOME/*

    #user properties

    echo "Please, enter your confluence user name (e.g. zdenek.macicek):"
    read a
    CONF_USER=$a

    echo "Please, enter your confluence user password :"
    while IFS= read -p "$prompt" -r -s -n 1 char
        do
            if [[ $char == $'\0' ]]
            then
                break
            fi
            prompt='*'
            PASSWORD+="$char"
    done
    CONF_PASSWORD=$PASSWORD

    echo "TOOL_HOME=$TOOL_HOME" >> $TOOL_HOME/conf/user.cfg
    echo "CONF_USER=$CONF_USER" > $TOOL_HOME/conf/user.cfg
    echo "CONF_PASSWORD=$CONF_PASSWORD" >> $TOOL_HOME/conf/user.cfg
    echo "TOOL_HOME=$TOOL_HOME" >> $TOOL_HOME/conf/user.cfg
;;
-S)
    PRODUCTION=$(grep "SPACE_NAME=" $TOOL_HOME/conf/config.cfg | awk  -F $'=' '{print $2}' )
    echo "Currently, space :$PRODUCTION is used."
    echo "Do you want to change used confluence space name to (`grep "NU_NAME=" $TOOL_HOME/conf/config.cfg | awk  -F $'=' '{print $2}' `)? Yy/Nn:"

    read CHANGE
        case $CHANGE in
        Y)
            sed -e 's+SPACE_NAME+TMP_NAME+g' $TOOL_HOME/conf/config.cfg > $TOOL_HOME/conf/tmp_config
            sed -e 's+NU_NAME+SPACE_NAME+g' $TOOL_HOME/conf/tmp_config | sed -e 's+TMP_NAME+NU_NAME+g' > $TOOL_HOME/conf/config.cfg
            rm .$TOOL_HOME/conf/tmp_config
            ;;
        y)
            sed -e 's+SPACE_NAME+TMP_NAME+g' $TOOL_HOME/conf/config.cfg > $TOOL_HOME/conf/tmp_config
            sed -e 's+NU_NAME+SPACE_NAME+g' $TOOL_HOME/conf/tmp_config | sed -e 's+TMP_NAME+NU_NAME+g' > $TOOL_HOME/conf/config.cfg
            rm $TOOL_HOME/conf/tmp_config
            ;;
        n) echo "Keeping space $PRODUCTION" ;;
        N) echo "Keeping space $PRODUCTION" ;;
    esac
    ;;
esac

clear






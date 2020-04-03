#!/bin/sh

DEVICE=$1
FILE=$2

udevadm info --query=all --name=$DEVICE >$FILE

# return UUID if possible...
UUID=`grep ID_FS_UUID= $FILE |cut -d= -f2 |sed 's/[[:blank:]]*//g'`
USAGE=`grep ID_FS_USAGE= $FILE |cut -d= -f2 |sed 's/[[:blank:]]*//g'`
FSTYPE=`grep ID_FS_TYPE= $FILE |cut -d= -f2 |sed 's/[[:blank:]]*//g'`

if ! echo $USAGE |egrep -q "(filesystem|disklabel)"; then
	rm -f $FILE
	exit 0
elif [ "$UUID" != "" ]; then
	echo "$UUID:$FSTYPE"
	exit 0
fi

# ...but if not, then use most possibly unique string instead
MODEL=`grep ID_MODEL= $FILE |cut -d= -f2 |sed 's/[[:blank:]]*//g'`
VENDOR=`grep ID_VENDOR= $FILE |cut -d= -f2 |sed 's/[[:blank:]]*//g'`
SERIAL=`grep ID_SERIAL= $FILE |cut -d= -f2 |tr ':' '-' |sed 's/[[:blank:]]*//g'`

if [ "$SERIAL" != "" ]; then
	echo "$SERIAL:$FSTYPE"
elif [ "$MODEL" != "" ] && [ "$VENDOR" != "" ]; then
	echo "${VENDOR}_${MODEL}:$FSTYPE"
elif [ "$MODEL" != "" ]; then
	echo "$MODEL:$FSTYPE"
else
	rm -f $FILE
fi

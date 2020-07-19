#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

APPNAME=syncdnd
APP_DIR=$DIR/local_wrapper
VIRTUALENV=$APPNAME
LABEL=com.floriankempenich.$APPNAME.daemon
WORKING_DIR=/usr/local/lib/$LABEL

PLIST_FILENAME=$LABEL.plist
PLIST_PATH=$HOME/Library/LaunchAgents/$PLIST_FILENAME

# Install virtualenv if needed
if ! pip3 show virtualenv >/dev/null; then
    echo "virtualenv setup: Not found for 'python3'"
    echo "virtualenv setup: Installing"
    pip3 install --user virtualenv
else
    echo "virtualenv setup: Found for 'python3'"
    echo "virtualenv setup: Skipping installation"
fi

# Create app dir & copy code
mkdir -p $WORKING_DIR
cp $APP_DIR/local_wrapper.py $WORKING_DIR
cd $WORKING_DIR

# Create & activate virtual env
python3 -m venv $VIRTUALENV
source ./$VIRTUALENV/bin/activate

# Install MQTT dependency
pip3 install paho-mqtt==1.5.0

# Load daemon
cat $APP_DIR/daemon.plist.template |
    sed "s|%WORKING_DIR|$WORKING_DIR|" |
    sed "s|%LABEL|$LABEL|" |
    sed "s|%VIRTUALENV|$VIRTUALENV|" \
        >$PLIST_PATH
launchctl load $PLIST_PATH

echo ""
echo "Sync DnD was installed"

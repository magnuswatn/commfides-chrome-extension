#!/bin/sh
# Based on the example script from the Chromium Authors:
# https://chromium.googlesource.com/chromium/src/+/master/chrome/common/extensions/docs/examples/api/nativeMessaging/host/install_host.sh


HOST_NAME=no.watn.magnus.smartcardsignapp
SCRIPT_NAME="smartcardsignapp.py"

set -e

DIR="$( cd "$( dirname "$0" )" && pwd )"
HOST_PATH=$DIR/$SCRIPT_NAME

if [ "$(whoami)" = "root" ]; then
    TARGET_DIR="/etc/opt/chrome/native-messaging-hosts"
else
    TARGET_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
fi

# Creating a virtualenv and installing PyKCS11
virtualenv $DIR/virtualenv
source $DIR/virtualenv/bin/activate
pip install PyKCS11
deactivate
PYTHON_PATH="$DIR/virtualenv/bin/python"

# Copying the manifest to the Chrome folder
mkdir -p "$TARGET_DIR"
cp "$DIR/$HOST_NAME.json" "$TARGET_DIR"

# Update host path in the manifest.
ESCAPED_HOST_PATH=${HOST_PATH////\\/}
sed -i -e "s/HOST_PATH/$ESCAPED_HOST_PATH/" "$TARGET_DIR/$HOST_NAME.json"

# Set permissions for the manifest so that all users can read it.
chmod o+r "$TARGET_DIR/$HOST_NAME.json"

# Set permission on the app so that it can run
chmod +x $HOST_PATH

# Update shebang in Python script
ESCAPED_PYTHON_PATH=${PYTHON_PATH////\\/}
sed -i -e "s/PYTHON_PATH/$ESCAPED_PYTHON_PATH/" "$HOST_PATH"

echo "Native messaging host $HOST_NAME has been installed."

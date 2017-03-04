#!/bin/bash
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

# Look for the OpenSC PKCS11 lib in known locations
PKCS11_LIB=None
for libfile in /usr/lib/opensc-pkcs11.so /usr/lib/*/opensc-pkcs11.so /usr/lib64/opensc-pkcs11.so
do
	if [ -f $libfile ]; then
		PKCS11_LIB=$libfile
	fi
done
if [ "$PKCS11_LIB" = "None" ]; then
	echo "PKCS11 library file not found"
	exit 1
fi

# Creating a virtualenv and installing PyKCS11
virtualenv $DIR/virtualenv
$DIR/virtualenv/bin/pip install PyKCS11
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

# Update the path to the PKCS11 library in the Python script
ESCAPED_PKCS11_LIB=${PKCS11_LIB////\\/}
sed -i -e "s/PKCS11_LIB/'$ESCAPED_PKCS11_LIB'/" "$HOST_PATH"

# Update shebang in Python script
ESCAPED_PYTHON_PATH=${PYTHON_PATH////\\/}
sed -i -e "s/PYTHON_PATH/$ESCAPED_PYTHON_PATH/" "$HOST_PATH"

echo "$HOST_NAME has been installed."

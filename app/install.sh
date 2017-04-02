#!/bin/bash
# Based on the example script from the Chromium Authors:
# https://chromium.googlesource.com/chromium/src/+/master/chrome/common/extensions/docs/examples/api/nativeMessaging/host/install_host.sh


HOST_NAME=no.watn.magnus.smartcardsignapp
SCRIPT_NAME="smartcardsignapp.py"

set -e

DIR="$( cd "$( dirname "$0" )" && pwd )"
HOST_PATH=$DIR/$SCRIPT_NAME

if [[ $1 == "chrome" ]]; then
  CH=true
elif [[ $1 == "firefox" ]]; then
  FF=true
elif [[ $1 == "both" ]]; then
  CH=true
  FF=true
else
  echo "Usage: $0 [chrome|firefox|both]"
  exit 1
fi

if [ "$(whoami)" = "root" ]; then
  CH_TARGET_DIR="/etc/opt/chrome/native-messaging-hosts"
  FF_TARGET_DIR="/usr/lib64/mozilla/native-messaging-hosts"
else
  CH_TARGET_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
  FF_TARGET_DIR="$HOME/.mozilla/native-messaging-hosts"
fi

# Look for the OpenSC PKCS11 lib in known locations
PKCS11_LIB=None
for libfile in /usr/lib/opensc-pkcs11.so /usr/lib/*/opensc-pkcs11.so /usr/lib64/opensc-pkcs11.so; do
  if [ -f $libfile ]; then
    PKCS11_LIB=$libfile
  fi
done
if [ "$PKCS11_LIB" = "None" ]; then
  echo "PKCS11 library file not found. Unable to contiune."
  exit 1
fi

# Creating a virtualenv and installing PyKCS11
virtualenv $DIR/virtualenv
$DIR/virtualenv/bin/pip install PyKCS11
PYTHON_PATH="$DIR/virtualenv/bin/python"

ESCAPED_HOST_PATH=${HOST_PATH////\\/}

# Chrome
if [ $CH ]; then
  echo "Installing for Chrome..."
  mkdir -p "$CH_TARGET_DIR"
  cp "$DIR/$HOST_NAME-chrome.json" "$CH_TARGET_DIR/$HOST_NAME.json"
  sed -i -e "s/HOST_PATH/$ESCAPED_HOST_PATH/" "$CH_TARGET_DIR/$HOST_NAME.json"
  sed -i -e "s/HOST_PATH/$ESCAPED_HOST_PATH/" "$CH_TARGET_DIR/$HOST_NAME.json"
  chmod o+r "$CH_TARGET_DIR/$HOST_NAME.json"
fi

# Firefox
if [ $FF ]; then
  echo "Installing for Firefox..."
  mkdir -p "$FF_TARGET_DIR"
  cp "$DIR/$HOST_NAME-firefox.json" "$FF_TARGET_DIR/$HOST_NAME.json"
  sed -i -e "s/HOST_PATH/$ESCAPED_HOST_PATH/" "$FF_TARGET_DIR/$HOST_NAME.json"
  sed -i -e "s/HOST_PATH/$ESCAPED_HOST_PATH/" "$FF_TARGET_DIR/$HOST_NAME.json"
  chmod o+r "$FF_TARGET_DIR/$HOST_NAME.json"
fi

# Set permission on the app so that it can run
chmod +x $HOST_PATH

# Update the path to the PKCS11 library in the Python script
ESCAPED_PKCS11_LIB=${PKCS11_LIB////\\/}
sed -i -e "s/PKCS11_LIB/'$ESCAPED_PKCS11_LIB'/" "$HOST_PATH"

# Update shebang in Python script
ESCAPED_PYTHON_PATH=${PYTHON_PATH////\\/}
sed -i -e "s/PYTHON_PATH/$ESCAPED_PYTHON_PATH/" "$HOST_PATH"

echo "$HOST_NAME has been installed."

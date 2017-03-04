#!/bin/sh
# Based on the example script from the Chromium Authors:
# https://chromium.googlesource.com/chromium/src/+/master/chrome/common/extensions/docs/examples/api/nativeMessaging/host/uninstall_host.sh

HOST_NAME=no.watn.magnus.smartcardsignapp

set -e

if [ "$(whoami)" = "root" ]; then
    TARGET_DIR="/etc/opt/chrome/native-messaging-hosts"
else
    TARGET_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
fi

rm "$TARGET_DIR/$HOST_NAME.json"

echo "$HOST_NAME has been uninstalled."

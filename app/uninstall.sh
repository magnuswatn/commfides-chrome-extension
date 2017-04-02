#!/bin/sh
# Based on the example script from the Chromium Authors:
# https://chromium.googlesource.com/chromium/src/+/master/chrome/common/extensions/docs/examples/api/nativeMessaging/host/uninstall_host.sh

HOST_NAME=no.watn.magnus.smartcardsignapp

set -e

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

if [ $CH ]; then
  echo "Uninstalling from Chrome..."
  rm "$CH_TARGET_DIR/$HOST_NAME.json"
fi

if [ $FF ]; then
  echo "Uninstalling from Firefox.."
  rm "$FF_TARGET_DIR/$HOST_NAME.json"
fi

echo ""
echo "$HOST_NAME has been uninstalled. You can now delete the files."

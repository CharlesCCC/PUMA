#!/bin/bash

if [ $# -eq 0 ]
    then 
        echo "please provide the apk folder path" #/Volumes/HDD/Tools/APK-collections/backApk4000_1
        exit 
fi

#adb shell  "su -c 'am broadcast -a android.intent.action.MASTER_CLEAR'"
adb push haos /data/local/tmp
adb shell "chmod 0755 /data/local/tmp/haos"
adb shell "ls -l /data/local/tmp/haos"
adb shell "mkdir -p /data/local/tmp/local/tmp"
adb push bin/TestApp.jar /data/local/tmp/

folder=$1

total=$(find "$folder"/*.apk -type f | wc -l)

for filename in "$folder"/*.apk; do
    var=$((var + 1))
    echo "$filename" - "$var"/"$total"
    packageName=$($ANDROID_HOME/build-tools/28.0.3/aapt d badging "$filename" | grep package:\ name | awk '{print $2}' | cut -c 7- | rev | cut -c 2- | rev)
    APP=$($ANDROID_HOME/build-tools/28.0.3/aapt d badging "$filename" | grep "application-label:" | cut -c 20- |rev | cut -c 2- | rev)
    echo "$packageName"$"\n""$APP" > app.info
    adb push app.info /data/local/tmp/
    # 0. Start app from fresh
    adb install "$filename"
	adb shell "am force-stop $APP"
	adb shell /data/local/tmp/haos runtest TestApp.jar -c nsl.stg.tests.LaunchApp | grep "Total UIState clusters" >> results.log 
	adb shell pm uninstall $packageName 
done
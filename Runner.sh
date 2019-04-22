#!/bin/bash

if [ $# -eq 0 ]
    then 
        echo "please provide the apk folder path" #/Volumes/HDD/Tools/APK-collections/backApk4000_1
        exit 
fi

folder=$1
deviceId=$2

#adb -s "$deviceId" shell  "su -c 'am broadcast -a android.intent.action.MASTER_CLEAR'"
adb -s "$deviceId" push haos /data/local/tmp
adb -s "$deviceId" shell "chmod 0755 /data/local/tmp/haos"
adb -s "$deviceId" shell "ls -l /data/local/tmp/haos"
adb -s "$deviceId" shell "mkdir -p /data/local/tmp/local/tmp"
adb -s "$deviceId" push bin/TestApp.jar /data/local/tmp/

total=$(find "$folder"/*.apk -type f | wc -l)
mkdir "$folder"/processed

for filename in "$folder"/*.apk; do
    var=$((var + 1))
    echo "$filename" - "$var"/"$total"
    packageName=$($ANDROID_HOME/build-tools/28.0.3/aapt d badging "$filename" | grep package:\ name | awk '{print $2}' | cut -c 7- | rev | cut -c 2- | rev)
    APP=$($ANDROID_HOME/build-tools/28.0.3/aapt d badging "$filename" | grep "application-label:" | cut -c 20- |rev | cut -c 2- | rev)
    #echo "$packageName"$"\r""$APP" > "$folder"/app.info
    echo $packageName >"$folder"/app.info
    echo $APP >> "$folder"/app.info
    adb -s "$deviceId" push "$folder"/app.info /data/local/tmp/
    # 0. Start app from fresh
    adb -s "$deviceId" install "$filename"
	adb -s "$deviceId" shell "am force-stop $APP"
	adb -s "$deviceId" shell /data/local/tmp/haos runtest TestApp.jar -c nsl.stg.tests.LaunchApp | grep "Total UIState clusters" >> results.log 
	adb -s "$deviceId" shell pm uninstall $packageName 
    mv $filename $folder/processed
done
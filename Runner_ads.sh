#!/bin/bash

if [ $# -eq 0 ]
    then 
        echo "please provide the apk folder path" #/Volumes/HDD/Tools/APK-collections/backApk4000_1
        exit 
fi

folder=$1
deviceId=$2
mkdir -p results_main

#adb -s "$deviceId" shell  "su -c 'am broadcast -a android.intent.action.MASTER_CLEAR'"
adb -s "$deviceId" push haos //data/local/tmp
adb -s "$deviceId" shell "chmod 0755 //data/local/tmp/haos"
adb -s "$deviceId" shell "ls -l //data/local/tmp/haos"
adb -s "$deviceId" shell "mkdir -p //data/local/tmp/local/tmp"
adb -s "$deviceId" push bin/TestApp.jar //data/local/tmp/

total=$(find "$folder"/*.apk -type f | wc -l)

for filename in "$folder"/*.apk; do
    var=$((var + 1))
    echo "$filename" - "$var"/"$total"
    packageName=$($ANDROID_HOME/build-tools/28.0.3/aapt d badging "$filename" | grep package:\ name | awk '{print $2}' | sed 's/^.\{6\}\(.*\).\{1\}$/\1/')
APP=$($ANDROID_HOME/build-tools/28.0.3/aapt d badging "$filename" | grep "application-label-en:"  | sed 's/^.\{22\}\(.*\).\{1\}$/\1/')
	if [ -z "$APP" ]
	then
		APP=$($ANDROID_HOME/build-tools/28.0.3/aapt d badging "$filename" | grep "application-label:"  | sed 's/^.\{19\}\(.*\).\{1\}$/\1/')
	fi
    #echo "$packageName"$"\r""$APP" > "$folder"/app.info
    echo $packageName >"$folder"/app.info
    echo $APP >> "$folder"/app.info
    adb -s "$deviceId" push "$folder"/app.info //data/local/tmp/

    if (adb -s "$deviceId" install "$filename") ; then
        echo "$deviceId --- installed --- $filename"
    	adb -s "$deviceId" shell "am force-stop $APP"
    	adb -s "$deviceId" shell //data/local/tmp/haos runtest TestApp.jar -c nsl.stg.tests.LaunchApp | grep ">>>>" >> results_main/results_"$packageName".log 
    else
        break;
        exit_on_error "can't install $filename on $deviceId ---- quit ---- " 
	fi

    if (adb -s "$deviceId" shell pm uninstall $packageName) ; then
        mkdir -p "$folder"/processed
        mv $filename "$folder"/processed
        echo "$deviceId sucessfully uninstall $packageName "
    else 
        break;
        exit_on_error "can't uninstall $packageName on $deviceId ---- quit ---- " 
    fi
done
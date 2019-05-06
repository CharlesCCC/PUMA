
script_name=$0
script_full_path=$(dirname "$0")

num_devices=$((`adb devices | awk 'NR>1 {print $1}' | wc -l`-1))
dir=$1 #/Volumes/HDD/Tools/APK-collections/selectedAPKs/

dir_name="APKs"
dir_size=$((`find $dir -maxdepth 1 -type f | wc -l`/$num_devices+1))
for i in `seq 1 $num_devices`;
do
	deviceId=$(adb devices | awk 'NR>1 {print $1}' | sed -n "$i p")
	subDir=$dir$dir_name$i

	echo $deviceId
	echo $subDir
	echo $script_full_path

    mkdir -p "$subDir";
    find $dir -maxdepth 1 -type f | head -n $dir_size |xargs -I {} mv {} "$subDir"

    "$script_full_path"/Runner_ads.sh $subDir $deviceId &

done
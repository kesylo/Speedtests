#!/usr/bin/env bash

# Character for separating values
# (commas are not safe, because some servers return speeds with commas)
sep=";"

# Usage message
display_usage() {
echo "This script must be run with super-user privileges"
exit 1
}

# Check if root access
if [ "$(id -u)" != "0" ]; then
display_usage
fi

mkdir -p /home/pi/logs

# Temporary file holding speedtest-cli output
user=$USER
if test -z $user; then
  user=$USERNAME
fi
log=/home/pi/logs/temp-speedtest-2ghz-bxl.log
result=/home/pi/logs/speedtest-2ghz-bxl.log

# Local functions
function str_extract() {
 pattern=$1
 # Extract
 res=`grep "$pattern" $log | sed "s/$pattern//g"`
 # remove points
 res=`echo $res | sed 's/[.][.][.]//g'`
 # reduce
 res=`echo $res | sed 's/^ *//g' | sed 's/ *$//g'`
 echo $res
}

# result file info for trim
if test "$1" = "--header"; then
  start="start"
  stop="stop"
  from="from"
  from_ip="from_ip"
  server="server"
  server_dist="server_dist"
  server_ping="server_ping"
  download="download"
  upload="upload"
  share_url="share_url"
else
  mkdir -p `dirname $log`

  start=`date +"%Y-%m-%d"`

  if test -n "$SPEEDTEST_CSV_SKIP" && test -f "$log"; then
    # Reuse existing results (useful for debugging)
    1>&2 echo "** Reusing existing results: $log"
  else
    # Query Speedtest
    /usr/local/bin/speedtest-cli --share > $log
  fi
  
  stop=`date +"%Y-%m-%d"`
  
  # Parse
  from=`str_extract "Testing from "`
  from_ip=`echo $from | sed 's/.*(//g' | sed 's/).*//g'`
  from=`echo $from | sed 's/ (.*//g'`
  
  server=`str_extract "Hosted by "`
  server_ping=`echo $server | sed 's/.*: //g'`
  server=`echo $server | sed 's/: .*//g'`
  server_dist=`echo $server | sed 's/.*\\[//g' | sed 's/\\].*//g'`
  server=`echo $server | sed 's/ \\[.*//g'`
  
  download=`str_extract "Download: "`
  upload=`str_extract "Upload: "`
  share_url=`str_extract "Share results: "`
fi

# Standardize units?
if test "$1" = "--standardize"; then
  download=`echo $download | sed 's/Mbits/Mbit/'`
  upload=`echo $upload | sed 's/Mbits/Mbit/'`
fi

# Send to IFTTT
secret_key="3H5MYW9_mDaB7Cw83TG8V"
value1=`echo $server_ping | cut -d" " -f1`
value1=`echo "$value1" | sed -r 's/[.]+/,/g'`
value2=`echo $download | cut -d" " -f1`
value2=`echo "$value2" | sed -r 's/[.]+/,/g'`
value3=`echo $upload | cut -d" " -f1` 
value3=`echo "$value3" | sed -r 's/[.]+/,/g'`
json="{\"value1\":\"${value1}\",\"value2\":\"${value2}\",\"value3\":\"${value3}\"}"
curl -X POST -H "Content-Type: application/json" -d "${json}" https://maker.ifttt.com/trigger/speedtest-2ghz/with/key/${secret_key}



if [ -s $result ]
then
        #echo "not empty"
	echo " " >>  $result
	echo $stop >> $result
	echo "Ping: $value1" >> $result
	echo "Download: $value2" >> $result
	echo "Upload: $value3" >> $result
else
         #echo "empty"
	echo $stop >> $result
	echo "Ping: $value1" >> $result
	echo "Download: $value2" >> $result
	echo "Upload: $value3" >> $result
fi

# clean
rm -r $log

#!/bin/sh

source ./hosts.sh

if [ -z $1 ];
then
  echo "Provide the file that you want to copy"
  exit 1
fi

for HOST in $ALL_HOSTS
do
  echo "Copying to $HOST"
  scp -r ./locust_app_perf/$1 $HOST:/opt/locust/ &
done

wait
echo "Done"
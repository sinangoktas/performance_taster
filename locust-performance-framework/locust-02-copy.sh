#!/bin/sh

source ./hosts.sh

for HOST in $ALL_HOSTS
do
  echo "Copying to $HOST"
  scp -r ./locust_app_perf/. $HOST:/opt/locust/ &
done

wait
echo "Done"
#!/bin/sh

source ./hosts.sh

for HOST in $ALL_HOSTS
do
  echo "Killing locust processes on $HOST"
  ssh -n -f $HOST "sh -c 'sudo pkill locust -9'" &
done

wait
echo "Done"
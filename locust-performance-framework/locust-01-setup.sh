#!/bin/sh

source ./hosts.sh

for HOST in $ALL_HOSTS
do
  echo "Setting up $HOST"
  ssh -n -f $HOST "sudo pip install locustio dnslib  dnspython" &
  ssh $HOST "sudo sh -c 'cat > /etc/hosts'" &
done

wait
echo "Done"
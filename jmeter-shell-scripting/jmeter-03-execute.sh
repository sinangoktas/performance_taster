#!/bin/sh

source ./hosts.sh

if [ -z $1 ];
then
  echo -e "Provide the name of the jmx file you want to run"
  exit 1
fi

if [ -z $2 ];
then
  echo -e "Provide the name that you want to save the report under - It must have the format .jtl"
  exit 1
fi

# run the test

for HOST in $HOST_WORKERS
do
  ssh -tt $HOST_WORKERS << ENDSSH &
  cd /opt/apache-jmeter-version/bin/
  nohup sh jmeter -n -t $1 -l $2
  echo "starting process in $HOST"

ENDSSH
done

echo "Done"
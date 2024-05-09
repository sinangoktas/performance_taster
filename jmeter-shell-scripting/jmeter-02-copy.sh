#!/bin/sh

source ./hosts.sh

if [ -z $1 ];
then
  echo -e "Provide the name of the jmx file you want to run"
  echo -e "i.e. jmeter-02-copy.sh test.jmx"
  exit 1
fi

for HOST in $HOST_WORKERS
do
  echo "Copying to $HOST"
  scp -r ./$1 $HOST:/opt/apache-jmeter-version/bin/ &
done

wait
echo "Done"
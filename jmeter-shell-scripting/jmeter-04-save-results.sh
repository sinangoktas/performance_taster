#!/bin/sh

TIMESTAMP=`date +%s`
DIRECTORY=results/$TIMESTAMP
mkdir -p $DIRECTORY

if [ -z $1 ];
then
  echo -e "Provide the name of the jmx file you want to run"
  exit 1
fi

if [ -z $2 ];
then
  echo -e "Provide the name you want to save the report under - It must have the format .jtl"
  exit 1
fi

for HOST in $HOST_WORKERS
do
  echo "Extracting results from $HOST"
  scp $HOST_WORKERS:/opt/apache-jmeter-version/bin/$1/* $DIRECTORY/

ENDSSH
done

# generate html report from jtl file
cd $DIRECTORY
sudo jmeter -g $2 -o .

ENDSSH

wait
echo "Done"
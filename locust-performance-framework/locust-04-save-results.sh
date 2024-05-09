#!/bin/sh

TIMESTAMP=`date +%s`
DIRECTORY=results/$TIMESTAMP
mkdir -p $DIRECTORY


curl -o $DIRECTORY/statistics.csv http://localhost:8089/stats/requests/csv
curl -o $DIRECTORY/report.html http://localhost:8089/stats/report
curl -o $DIRECTORY/failures.csv http://localhost:8089/stats/failures/csv
curl -o $DIRECTORY/exceptions.csv http://localhost:8089/stats/exceptions/csv

echo "Results copied to $DIRECTORY"
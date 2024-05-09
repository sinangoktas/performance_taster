#!/bin/sh

source ./hosts.sh

# -----------------------------------------
# Example of using bash/AWS CLI to dynamically create these variables
# Appropriate AWS programmatic credentials are needed.

if false
then
  AWS_REGION=eu-wes-1
  AWS_TAG_PREFIX=qa_tester_
  HOST_PREFIX=i
  MASTER_HOST_NUMBER=1

  echo "Counting the hosts ..."
  host_count=$( \
    aws --region ${AWS_REGION} --output text ec2 describe-instances \
      --filters \
        "Name=instance-state-name,Values=running" \
        "Name=tag:Name,Values=${AWS_TAG_PREFIX}*" \
      --querry "Reservations[*].Instances[*].PrivateIpAddress" \
    | wc -l | tr -d ' '\
  )
  echo "Found ${host_count} hosts"

  echo "Assigning the identities of the master and slaves ..."
  HOST_MASTER=${HOST_PREFIX}${MASTER_HOST_NUMBER}
  HOST_WORKERS=
  ALL_HOSTS=
  for idx in $(seq 1 ${host_count})
  do
    ALL_HOSTS="${ALL_HOSTS} ${HOST_PREFIX}${idx}"
    if [ ${idx} -ne "${MASTER_HOST_NUMBER}" ]
    then
      HOST_WORKERS="${HOST_WORKERS} ${HOST_PREFIX}${idx}"
    fi
  done

  echo "Master $HOST_MASTER"
  echo "Slaves $HOST_WORKERS"
  echo "All $ALL_HOSTS"

  if [ -z "${MASTER_HOST_IP}" ]
  then
    echo "Finding the private IP for the master host (node ${MASTER_HOST_NUMBER})"
    MASTER_HOST_IP=$( \
      aws --region ${AWS_REGION} --output text ec2 describe-instances \
      --filters \
        "Name=instance-state-name,Values=running" \
        "Name=tag:Name,Values=${AWS_TAG_PREFIX}${MASTER_HOST_NUMBER}" \
      --querry "Reservations[*].Instances[*].PrivateIpAddress" \
    )
    echo "MAster IP is ${MASTER_HOST_IP}"
  fi
fi

#-------------------------------------------------------------

if [ -z "$SCENARIO_FILE" ]
then
  echo "Provide a SCENARIO_FILE environment variable"
  exit 1
fi

if [ -z "$TARGET_ENV" ]
then
  echo "Provide a TARGET_ENV environment variable"
  exit 1
fi

ssh -tt $HOST_MASTER << ENDSSH &
source  /opt/locust/.venv/bin/activate
cd /opt/locust
TARGET_ENV=$TARGET_ENV nohup locust -f $SCENARIO_FILE --master 2>&1 &
ENDSSH

for HOST in $HOSt_WORKERS
do
  echo "Starting process in $HOST"
  ssh -tt $HOST << ENDSSH &
source  /opt/locust/.venv/bin/activate
cd /opt/locust

TARGET_ENV=$TARGET_ENV locust -f $SCENARIO_FILE --worker --master-host ${MASTER_HOST_IP} 2>&1 &
TARGET_ENV=$TARGET_ENV locust -f $SCENARIO_FILE --worker --master-host ${MASTER_HOST_IP} 2>&1 &
TARGET_ENV=$TARGET_ENV locust -f $SCENARIO_FILE --worker --master-host ${MASTER_HOST_IP} 2>&1 &
TARGET_ENV=$TARGET_ENV locust -f $SCENARIO_FILE --worker --master-host ${MASTER_HOST_IP} 2>&1 &
TARGET_ENV=$TARGET_ENV locust -f $SCENARIO_FILE --worker --master-host ${MASTER_HOST_IP} 2>&1 &
ENDSSH
done

echo "Setting up ssh tunnel to $HOST_MASTER on port 8089"
ssh -N $HOST_MASTER -L 8089:localhost:8089

echo "Done"








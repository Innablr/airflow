#!/usr/bin/env /bin/sh

AIRFLOW_HOME="/usr/local/airflow"
CMD="airflow"
PATH=${PATH}:${AIRFLOW_HOME}/jobs/script

if [ "${FERNET_KEY:0:5}" = "PARAM" ]; then
    FERNET_KEY=$(aws ssm get-parameters --names "${FERNET_KEY:6:100}" --with-decryption  --region ap-southeast-2 --output text | awk -F '\t' '{print $4}')
fi

if [ "${POSTGRES_PASSWORD:0:5}" = "PARAM" ]; then
    POSTGRES_PASSWORD=$(aws ssm get-parameters --names "${POSTGRES_PASSWORD:6:100}" --with-decryption --region ap-southeast-2 --output text | awk -F '\t' '{print $4}')
fi

if [ "${OAUTH_SLACK_TOKEN:0:5}" = "PARAM" ]; then
    OAUTH_SLACK_TOKEN=$(aws ssm get-parameters --names "${OAUTH_SLACK_TOKEN:6:100}" --with-decryption --region ap-southeast-2 --output text | awk -F '\t' '{print $4}')
fi

sed -i "s#remote_base_log_folder = s3://airflow-log-bucket#remote_base_log_folder = s3://$WORKER_LOG_BUCKET#" "$AIRFLOW_HOME"/airflow.cfg
sed -i "s#base_url = http://localhost#base_url = http://$WEBSERVER_HOSTNAME#" "$AIRFLOW_HOME"/airflow.cfg
sed -i "s#celery_result_backend = postgresdblink#celery_result_backend = db+postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB#" "$AIRFLOW_HOME"/airflow.cfg
sed -i "s#sql_alchemy_conn = postgresdblink#sql_alchemy_conn = postgresql+psycopg2://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB#" "$AIRFLOW_HOME"/airflow.cfg
sed -i "s#broker_url = redislink#broker_url = redis://$REDIS_HOST:$REDIS_PORT/$REDIS_DB_NUMBER#" "$AIRFLOW_HOME"/airflow.cfg
sed -i "s#celeryd_concurrency = NUMBER#celeryd_concurrency = $WORKER_POOL_SIZE#" "$AIRFLOW_HOME"/airflow.cfg
sed -i "s#default_queue = default#default_queue = $WORKER_QUEUE#" "$AIRFLOW_HOME"/airflow.cfg
sed -i "s#fernet_key = ANIVKYP1oTIEk4RgvmAdG7WWNQpc87Wz7nt1z5PYb44=#fernet_key = $FERNET_KEY#" "$AIRFLOW_HOME"/airflow.cfg
sed -i "s#oauth_token = OAUTH_SLACK_TOKEN#oauth_token = $OAUTH_SLACK_TOKEN#" "$AIRFLOW_HOME"/airflow.cfg

if [ "$EXEC_MODE" = "LOCAL" ]; then
  echo "waiting 10 seconds for db and redis to wake up"
  sleep 10
  HOSTNAME=localhost
  sed -i "s#authenticate = TRUEORFALSE#authenticate = False#" "$AIRFLOW_HOME"/airflow.cfg
else
  if [ "${BIND_PASSWORD:0:5}" = "PARAM" ]; then
      BIND_PASSWORD=$(aws ssm get-parameters --names "${BIND_PASSWORD:6:100}" --with-decryption --region ap-southeast-2 --output text | awk -F '	' '{print $4}')
  fi
  HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
  echo "updating authentication to True"
  sed -i "s#authenticate = TRUEORFALSE#authenticate = True#" "$AIRFLOW_HOME"/airflow.cfg
  sed -i "s#memberOf=CN=SUPER_USER_GROUP1#memberOf=CN=$SUPER_USER_GROUP1#" "$AIRFLOW_HOME"/airflow.cfg
  sed -i "s#memberOf=CN=SUPER_USER_GROUP2#memberOf=CN=$SUPER_USER_GROUP2#" "$AIRFLOW_HOME"/airflow.cfg
  sed -i "s#bind_password = BIND_PASSWORD_SECRET#bind_password = $BIND_PASSWORD#" "$AIRFLOW_HOME"/airflow.cfg
fi



if [ "$1" = "worker" ]; then
  echo "Now running: $CMD $1  -q $WORKER_QUEUE"
  exec $CMD $1 -q $WORKER_QUEUE
else
  if [ "$1" = "scheduler" ]; then
    # initdb can run as often as required but lets limit to only when initialising a new scheduler
    echo "Initialize database as a Scheduler is starting. running: $CMD initdb"
    $CMD initdb
  fi
  if [ "$1" = "queue_depth_monitor.py" ]; then
    echo "Now running: /usr/bin/python ${AIRFLOW_HOME}/$1 --broker_host $REDIS_HOST --broker_port $REDIS_PORT --broker_index $REDIS_DB_NUMBER"
    exec /usr/bin/python ${AIRFLOW_HOME}/$1 --broker_host $REDIS_HOST --broker_port $REDIS_PORT --broker_index $REDIS_DB_NUMBER --queue_name $WORKER_QUEUE_LIST
  else
    if [ "$1" = "/dag_deploy.sh" ]; then
      echo "Now running ${AIRFLOW_HOME}$1"
      exec ${AIRFLOW_HOME}$1
    else
      echo "Now running: $CMD $1"
      exec $CMD $1
    fi
  fi
fi

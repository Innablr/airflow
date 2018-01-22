#!/bin/bash
# When run from GoCD, mount the efs file share and dowload an artifact representing the current codebase, and
# extract it on to the mount
AIRFLOW_HOME="/usr/local/airflow"
artifactory_url=https://artifacts.com/artifactory/list
artifactory_user=botuser
if [ ${ENVIRONMENT} = "development" ]; then
    ARTIFACTORY_REPO=analytics-generic-dev
    GO_PIPELINE_NAME=Airflow_Dags_Development
    BRANCH_NAME=develop
fi
if [ ${ENVIRONMENT} = "production" ]; then
    ARTIFACTORY_REPO=analytics-generic-prod
    GO_PIPELINE_NAME=Airflow_Dags
    BRANCH_NAME=master
fi
artifactory_key=$(aws ssm get-parameters --names artifactory_key --region ap-southeast-2 --with-decryption --output text | awk -F '\t' '{print $4}')

PREFIX=airflow/snapshots/airflow-dags
LATEST_FILENAME=${GO_PIPELINE_NAME}-${BRANCH_NAME}-latest.tgz

mkdir dag_working
cd dag_working
while true
do
    if [ "$EXEC_MODE" = "LOCAL" ]; then
        python ${AIRFLOW_HOME}/jobs/script/load_airflow_config.py
        echo "Config syncronised to airflow. Waiting 30 seconds before re-syncing."
    else
        curl -s -u ${artifactory_user}:${artifactory_key} -O --insecure ${artifactory_url}/${ARTIFACTORY_REPO}/${PREFIX}/${LATEST_FILENAME}
        tar -xzf ./${LATEST_FILENAME}
        cp -r ./jobs $AIRFLOW_HOME
        rm ./${LATEST_FILENAME}
        rm -rf ./jobs
        echo "Dags, scripts, SQL and config synced to ${AIRFLOW_HOME}/jobs from Artifactory."
        python ${AIRFLOW_HOME}/jobs/script/load_airflow_config.py
        echo "Config syncronised to airflow. Waiting 30 seconds before re-syncing."
    fi
    sleep 30
done
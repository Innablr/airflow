SCRIPT_ACTION?=update
INSTALLATION_NAME?=airflow-production-worker
LOG_BUCKET?=airflow-production-worker-runlog
AWS_REGION?=ap-southeast-2
ENVIRONMENT?=production
VPC_ID?=vpc-02765e67
APP_SUBNETS?=subnet-7a0a020d,subnet-1e0be47a,subnet-7f233d39
SSH_KEY?=mykey
INSTANCE_ROLE?=airflow-worker-role
AUTOSCALE_ROLE?=ecsAutoscaleRole
SSH_IP_RANGES?=10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
DOCKER_REGISTRY?=1234.dkr.ecr.ap-southeast-2.amazonaws.com
DOCKER_IMAGE_NAME?=airflow
DOCKER_IMAGE_VERSION?=123
WORKER_CLUSTER_MAX?=10
WORKER_CLUSTER_DESIRED?=2
WORKER_CLUSTER_MIN?=2
WORKER_INSTANCE_TYPE?=t2.small
WORKER_POOL_SIZE?=8
WORKER_QUEUE_TO_USE?=t2.small.queue
UPSCALE_ALARM_THESHOLD?=50
DOWNSCALE_ALARM_THESHOLD?=10
SCHEDULE?=24x7
OWNER_DESC?='Owner=dan@somewhere.com.au,Description=Airflow Installation'
COST_CENTRE?=CMO
POSTGRES_DB_HOST?=bi-shared-db-prd.makeme.ap-southeast-2.rds.amazonaws.com
POSTGRES_DB_SCHEMA?=airflow
POSTGRES_DB_USER?=biadmin
POSTGRES_DB_PASSWORD?=PARAM.bi.shared.db.prd
FERNET_KEY?=PARAM.airflow.fernet.key
REDIS_HOST?=airflow.makeme.ng.0001.apse2.cache.amazonaws.com
REDIS_DB_NUMBER?=1
OAUTH_SLACK_TOKEN=PARAM.airflow.slack.token
WEBSERVER_HOSTNAME=internal-airfl-Webse-makeme.ap-southeast-2.elb.amazonaws.com
FILE_SYSTEM=fs-0d6a8934

airflow-worker:
	aws --region $(AWS_REGION) cloudformation $(SCRIPT_ACTION)-stack --stack-name $(INSTALLATION_NAME) \
		--capabilities CAPABILITY_IAM \
		--template-body file://./2.airflow_ecs_default_worker.yaml \
		--parameters \
			"ParameterKey=EcsClusterTagEnvironment,ParameterValue=$(ENVIRONMENT)" \
			"ParameterKey=VpcId,ParameterValue=$(VPC_ID)" \
			"ParameterKey=WorkerSubnets,ParameterValue='$(APP_SUBNETS)'" \
			"ParameterKey=KeyName,ParameterValue=$(SSH_KEY)" \
			"ParameterKey=EcsInstanceRole,ParameterValue='$(INSTANCE_ROLE)'" \
			"ParameterKey=EcsServiceAutoscaleRole,ParameterValue='$(AUTOSCALE_ROLE)'" \
			"ParameterKey=SSHIPRanges,ParameterValue='$(SSH_IP_RANGES)'" \
			"ParameterKey=AirflowImageRepository,ParameterValue='$(DOCKER_REGISTRY)'" \
			"ParameterKey=AirflowImageName,ParameterValue='$(DOCKER_IMAGE_NAME)'" \
			"ParameterKey=AirflowVersionTag,ParameterValue='$(DOCKER_IMAGE_VERSION)'" \
			"ParameterKey=WorkersMaxClusterSize,ParameterValue='$(WORKER_CLUSTER_MAX)'" \
			"ParameterKey=WorkersDesiredClusterSize,ParameterValue='$(WORKER_CLUSTER_DESIRED)'" \
			"ParameterKey=WorkersMinClusterSize,ParameterValue='$(WORKER_CLUSTER_MIN)'" \
			"ParameterKey=WorkerInstanceType,ParameterValue='$(WORKER_INSTANCE_TYPE)'" \
			"ParameterKey=WorkersPoolSize,ParameterValue='$(WORKER_POOL_SIZE)'" \
			"ParameterKey=WorkerQueue,ParameterValue=$(WORKER_QUEUE_TO_USE)" \
			"ParameterKey=WorkersQueueDepthUpAlarmThreshold,ParameterValue=$(UPSCALE_ALARM_THESHOLD)" \
			"ParameterKey=WorkersQueueDepthDownAlarmThreshold,ParameterValue=$(DOWNSCALE_ALARM_THESHOLD)" \
			"ParameterKey=EcsClusterTagSchedule,ParameterValue=$(SCHEDULE)" \
			"ParameterKey=EcsClusterTagOwnerDescription,ParameterValue=$(OWNER_DESC)" \
			"ParameterKey=EcsClusterTagCostCentre,ParameterValue=$(COST_CENTRE)" \
			"ParameterKey=PostgresDBScheme,ParameterValue=$(POSTGRES_DB_SCHEMA)" \
			"ParameterKey=PostgresDBHost,ParameterValue=$(POSTGRES_DB_HOST)" \
			"ParameterKey=PostgresDBUser,ParameterValue=$(POSTGRES_DB_USER)" \
			"ParameterKey=PostgresDBPassword,ParameterValue=$(POSTGRES_DB_PASSWORD)" \
			"ParameterKey=FernetKey,ParameterValue=$(FERNET_KEY)" \
			"ParameterKey=RedisHost,ParameterValue=$(REDIS_HOST)" \
			"ParameterKey=RedisDBNumber,ParameterValue=$(REDIS_DB_NUMBER)" \
			"ParameterKey=LogBucket,ParameterValue=$(LOG_BUCKET)" \
			"ParameterKey=OauthSlackToken,ParameterValue=$(OAUTH_SLACK_TOKEN)" \
			"ParameterKey=WebserverHostname,ParameterValue=$(WEBSERVER_HOSTNAME)" \
			"ParameterKey=FileSystem,ParameterValue=$(FILE_SYSTEM)" \



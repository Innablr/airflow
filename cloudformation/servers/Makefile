SCRIPT_ACTION?=update
INSTALLATION_NAME?=airflow-production-servers
LOG_BUCKET?=airflow-production-worker-runlog
AWS_REGION?=ap-southeast-2
ENVIRONMENT?=production
VPC_ID?=vpc-02765e67
ELB_SUBNETS?=subnet-7a0a020d,subnet-1e0be47a,subnet-7f233d39
APP_SUBNETS?=subnet-7a0a020d,subnet-1e0be47a,subnet-7f233d39
ELB_SCHEME?=internal
SSH_KEY?=mysshkey
INSTANCE_ROLE?=airflow-role
SERVICE_ROLE?=ecsServiceRole
SITE_IP_RANGES?=10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
SSH_IP_RANGES?=10.0.0.0/8,172.16.0.0/12,192.168.0.0/16
DOCKER_REGISTRY?=1234.dkr.ecr.ap-southeast-2.amazonaws.com
DOCKER_IMAGE_NAME?=airflow
DOCKER_IMAGE_VERSION?=123
QUEUES_TO_MONITOR?=t2.small.queue
DEFAULT_QUEUE_TO_USE?=t2.small.queue
SCHEDULE?=24x7
OWNER_DESC?='Owner=dan@somewhere.com.au,Description=Airflow Installation'
COST_CENTRE?=CMO
POSTGRES_DB_HOST?=shared-db-prd.createme.ap-southeast-2.rds.amazonaws.com
POSTGRES_DB_SCHEMA?=airflow
POSTGRES_DB_USER?=biadmin
POSTGRES_DB_PASSWORD?=PARAM.shared.createme.db.prd
FERNET_KEY?=PARAM.airflow.fernet.key
REDIS_HOST?=airflow.createme.ng.0001.apse2.cache.amazonaws.com
REDIS_DB_NUMBER?=1
BIND_PASSWORD?=PARAM.airflow.bind_password
SUPER_USR_GROUP1=r-aws-1234-devops
SUPER_USR_GROUP2=r-aws-1234-support
OAUTH_SLACK_TOKEN=PARAM.airflow.slack.token

airflow-apps:
	aws --region $(AWS_REGION) cloudformation $(SCRIPT_ACTION)-stack --stack-name $(INSTALLATION_NAME) \
		--capabilities CAPABILITY_IAM \
		--template-body file://./1.airflow_ecs_apps.yaml \
		--parameters \
			"ParameterKey=EcsClusterTagEnvironment,ParameterValue=$(ENVIRONMENT)" \
			"ParameterKey=VpcId,ParameterValue=$(VPC_ID)" \
			"ParameterKey=ELBSubnets,ParameterValue='$(ELB_SUBNETS)'" \
			"ParameterKey=ELBScheme,ParameterValue='$(ELB_SCHEME)'" \
			"ParameterKey=AppSubnets,ParameterValue='$(APP_SUBNETS)'" \
			"ParameterKey=KeyName,ParameterValue=$(SSH_KEY)" \
			"ParameterKey=EcsInstanceRole,ParameterValue='$(INSTANCE_ROLE)'" \
			"ParameterKey=EcsServiceRole,ParameterValue='$(SERVICE_ROLE)'" \
			"ParameterKey=AirflowImageRepository,ParameterValue='$(DOCKER_REGISTRY)'" \
			"ParameterKey=AirflowImageName,ParameterValue='$(DOCKER_IMAGE_NAME)'" \
			"ParameterKey=AirflowVersionTag,ParameterValue='$(DOCKER_IMAGE_VERSION)'" \
			"ParameterKey=WorkersQueueMonitorList,ParameterValue=$(QUEUES_TO_MONITOR)" \
			"ParameterKey=DefaultWorkerQueue,ParameterValue=$(DEFAULT_QUEUE_TO_USE)" \
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
			"ParameterKey=BindPassword,ParameterValue=$(BIND_PASSWORD)" \
			"ParameterKey=SuperUserADGroup1,ParameterValue=$(SUPER_USR_GROUP1)" \
			"ParameterKey=SuperUserADGroup2,ParameterValue=$(SUPER_USR_GROUP2)" \
			"ParameterKey=OauthSlackToken,ParameterValue=$(OAUTH_SLACK_TOKEN)" \

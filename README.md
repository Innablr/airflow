# airflow #

This repository contains **Dockerfile** of [airflow].

## Information / background ##

* Based on Alipine Image
(but locally via docker-compose it uses the official [Postgres](https://hub.docker.com/_/postgres/) as backend and [Redis](https://hub.docker.com/_/redis/) as queue)
* Install [Docker](https://www.docker.com/)
* Install [Docker Compose](https://docs.docker.com/compose/install/)
* This Airflow only runs Airflow with **CeleryExecutor** and uses redis (Elasticache) and postgres for queuing and persistence.
* Airflow documentation including DAG learning etc: https://airflow.incubator.apache.org/
* Airflow source code: https://github.com/apache/incubator-airflow

## Installation (local / docker-compose) ##

Clone this repo and then build the docker image from the repo's root folder:

        docker build -t <your_repo>/airflow .
        (or run ./build.sh fixing up the part where you need to put a 'tag' number in).

Push the image to your repo (you may wish to tag it 'latest' too).

        docker push <your_repo>/airflow

### Updating Dags ###

The repository dags are loaded from (in git) is airflow-dags.
In AWS dags are downloaded and extracted from artifactory to an EFS share mounted within docker as 'jobs' by a service/task running in the cluster.
This is the script dag_deploy and at the moment its configured to run every 30 seconds.
Locally (docker-compose) dags are mounted as ../airflow-dags so make sure the path is correct and you clone without updating the folder name.

### Security (AWS keys) ###

* Locally docker-compose will create a mount in ~/.aws on your image so the worker can use the local default credentials.
* Be sure to sign-in before running if using adfs.

## Running/controlling locally via docker-compose ##

* There are 5 services that run locally: redis, postgres, flower, webserver and worker.
* There is a 'temporary' service that runs each time (called update_s3_connections) that adds a couple of connections to the default configuration so that S3 can be contacted.

You need to update/edit 'docker-compose.yml' to source the image for all 4 services from your image repository then run (from the root of the airflow/git):

        docker-compose up

or if you want it to run in the background:

        docker-compose up -D

To stop:

        docker-compose stop

Then you can either

        docker-compose rm

to remove the images or

        docker-compose start

to restart the images.

### Local UI Links ###

- Airflow: [localhost:8080](http://localhost:8080/)
- Flower: [localhost:5555](http://localhost:5555/)

(ensure that you enable any jobs / dags - by default all new dags/jobs will all be disabled).

## Installation (AWS) ##

The installation comes in 4 essential 'parts':
1. A manually/console deployed Elasticache redis.
2. A manually/console deployed Postgres RDS.
3. A cloud formation deployed ECS cluster including the services for Webserver, Flower, Scheduler, Monitor.
    * For this see \deploy\apps\Maxkefile and \deploy\apps\1.airflow_ecs_apps.yaml
    * See the output of the cloud formation for links to the ELBs of the started Webserver and Scheduler.
4. A cloud formation deployed ECS cluster including the service for Workers.
    * For this see \deploy\workers\Makefile and \deploy\apps\2.airflow_ecs_default_worker.yaml


### High-availability deployment and data persistence: ##

* Part 1 and 2 (above) can be deployed using either HA or non-HA configuaration by utilizing the AWS RDS/Elasticache service options for this.
* All job state is managed through 1 and 2 so back-up also needs to be considered, especially for the postgres database.
* Worker logs are, by default, stored on s3 for the AWS deployment. For this it is necessary to configure a log connection in the GUI for "s3_Airflow_Logs".
* This is done either by the console or, more easily, by running a script \update_S3_connections.py that is installed on every docker image.

### Security (AWS) ###

* IAM EC2 credentials will assumed by the instance.
* There are two secrets to manage: One is the password for Postgres and the other is a symmetric encryption 'fernet' key.
* The broker is only secured via its security group so if restriction is required you must manually change the SG on Elasticache.

For encrypted connection passwords (in Local or Celery Executor), you must have the same fernet_key. By default docker-airflow generates the fernet_key at startup, you have to set an environment variable in the docker-compose (ie: docker-compose-LocalExecutor.yml) file to set the same key accross containers. To generate a fernet_key :

        python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print FERNET_KEY"


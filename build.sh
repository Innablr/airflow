#!/bin/bash

source ./PROJECT_CONFIG

docker build -t $COMPONENT_NAME .
docker tag $COMPONENT_NAME:latest $AWS_ECR_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$COMPONENT_NAME:latest
echo "Built image $COMPONENT_NAME:latest"

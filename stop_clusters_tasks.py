#!/usr/bin/env python
import sys
import boto3

cluster_names = sys.argv[1]
client = boto3.client("ecs", region_name = "ap-southeast-2")
for cluster_name in cluster_names.split(","):
    tasks = client.list_tasks(cluster=cluster_name)
    for taskArn in tasks["taskArns"]:
        print ('stopping task: {0}'.format(taskArn))
        client.stop_task(cluster=cluster_name, task=taskArn)

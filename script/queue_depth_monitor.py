import redis
import boto3
from time import sleep
import argparse
import time
from airflow import models, settings

cloudwatch = boto3.client('cloudwatch', region_name='ap-southeast-2')


def get_task_instances_running(queue_name, session):
    TI = models.TaskInstance
    running_TIs = session.query(TI).filter(
        TI.queue == queue_name, TI.state == 'running'
    ).order_by(TI.queue).all()
    return len(running_TIs)


def configure_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--broker_host", help="The host of the broker", default='localhost')
    parser.add_argument("--broker_port", help="The port of the broker", default='6379')
    parser.add_argument("--broker_index", help="The index of the broker's schema", type=int, default=1)
    parser.add_argument("--queue_names", help="csv list of queue names to monitor on the broker",default='default')
    parser.add_argument("--capture_interval", help="minutes to capture the metrics to cloudwatch", type=int, default=1)
    return parser.parse_args()

def queue_depth_capture(queue_name):
    queue_depth = broker_db.llen(queue_name)
    strdate = time.strftime("%Y-%m-%d %H:%M")
    print(strdate + " queue_name: ", queue_name, "  waiting depth: ", queue_depth)
    cloudwatch.put_metric_data(
        Namespace='Airflow',
        MetricData=[{
                'MetricName': 'QueueDepthWaiting',
                'Dimensions': [
                    {
                        'Name': 'Queue Name',
                        'Value': queue_name
                    },
                ],
                'Unit': 'None',
                'Value': queue_depth
            },])
    return queue_depth

def active_worker_capture(queue_name, session, queue_depth):
    running_count = get_task_instances_running(queue_name, session)
    strdate = time.strftime("%Y-%m-%d %H:%M")
    print(strdate + " queue_name: ", queue_name, "  running depth: ", running_count)
    cloudwatch.put_metric_data(
        Namespace='Airflow',
        MetricData=[{
            'MetricName': 'QueueDepthWaitingAndRunning',
            'Dimensions': [
                {
                    'Name': 'Queue Name',
                    'Value': queue_name
                },
            ],
            'Unit': 'None',
            'Value': running_count + queue_depth
        }, ])


args=configure_args()
broker_db = redis.Redis(host=args.broker_host, port=int(args.broker_port), db=int(args.broker_index),)

while True:
    session = settings.Session
    for queue_name in args.queue_names.split(','):
        queue_depth = queue_depth_capture(queue_name)
        active_worker_capture(queue_name, session, queue_depth)
    sleep(args.capture_interval * 60)

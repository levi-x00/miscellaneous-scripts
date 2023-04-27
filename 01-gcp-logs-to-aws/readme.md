# gcp-logs-to-aws
How to Send Logs From GCP to AWS
## Architecture
![alt text](https://github.com/levi-x00/gcp-logs-to-aws/blob/main/arch.jpg?raw=true)
## Setup
1. Create log sink with following pattern as well create the pub/sub topic here as destination.
```
logName="projects/[PROJECT_ID]/logs/cloudaudit.googleapis.com%2Factivity"
protoPayload.methodName:"compute.firewalls"
```
2. Create cloud function triggered by created pub/sub.
```
# Function dependencies, for example:
# package>=version
requests
```
```py
import base64
import os
import requests
import json

def hello_pubsub(event, context):
    """Triggered from a message on a Cloud Pub/Sub topic.
    Args:
         event (dict): Event payload.
         context (google.cloud.functions.Context): Metadata for the event.
    """
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    proto_payload = json.loads(pubsub_message)['protoPayload']

    if 'response' in proto_payload:
        endpoint = os.environ['URL']
        r = requests.post(url=endpoint, data=pubsub_message)
        print(pubsub_message)
    else:
        print("no response in 'protoPayload'")
```
3. Create lambda function.
```py
import json

def lambda_handler(event, context):
    print(json.dumps(event))
    return {
        'statusCode': 200,
        'body': json.dumps('logs printed!')
    }
```
4. Create API Gateway with POST method, then create resource and deploy it.
5. Create a firewall rule, and try to edit the rule to generate some events.

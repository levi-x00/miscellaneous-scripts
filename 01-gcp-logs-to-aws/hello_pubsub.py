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

'''
Author: Levi
email: m.r.pahlevi00@gmail.com

'''

import smtplib  
import email.utils
import json
import base64
from json2html import *
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from datetime import datetime as dt


def send_email(body_html):

    SENDER = 'sender@youremaildomain.com'  
    SENDERNAME = 'GCPMonitoring'
    RECIPIENTS  = ['rec1@youremaildomain.com', 'rec2@youremaildomain.com']
    USERNAME_SMTP = "<USERNAME_SMTP>"
    PASSWORD_SMTP = "<PASSWORD_SMTP>"
    HOST = "email-smtp.us-west-2.amazonaws.com"
    PORT = 587
    SUBJECT = 'GCP Monitoring API event'
    BODY_HTML = f'''{body_html}'''

    # Create message container - the correct MIME type is multipart/alternative.
    msg = MIMEMultipart('alternative')
    msg['Subject'] = SUBJECT
    msg['From'] = email.utils.formataddr((SENDERNAME, SENDER))
    msg['To'] = ','.join(RECIPIENTS)

    # Record the MIME types of both parts - text/plain and text/html.
    body_html = MIMEText(BODY_HTML, 'html')

    # Attach parts into message container.
    # According to RFC 2046, the last part of a multipart message, in this case
    # the HTML message, is best and preferred.
    msg.attach(body_html)

    # Try to send the message.
    try:  
        server = smtplib.SMTP(HOST, PORT)
        server.ehlo()
        server.starttls()

        #stmplib docs recommend calling ehlo() before & after starttls()
        server.ehlo()
        server.login(USERNAME_SMTP, PASSWORD_SMTP)
        server.sendmail(SENDER, RECIPIENTS, msg.as_string())
        server.close()
    # Display an error message if something goes wrong.
    except Exception as e:
        print ("Error: ", e)
    else:
        print ("Email sent success!")
        
        
def main(event, context):

    event_buffer = base64.b64decode(event['data'])
    log_entry = json.loads(event_buffer)

    if 'protoPayload' in log_entry and 'authorizationInfo' in log_entry['protoPayload']:
        send_email(json2html.convert(json=log_entry))

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

from builtins import str
from past.builtins import basestring

import importlib
import logging
from airflow import configuration
import boto3

def send_email(to, subject, html_content, dryrun=False, files=None, cc=None, bcc=None, mime_subtype=None, SES_MAIL_FROM=None, SES_REGION=None):



    if SES_MAIL_FROM is None:
        SES_MAIL_FROM = configuration.get('ses', 'SES_MAIL_FROM')
    if SES_REGION is None:
        SES_REGION = configuration.get('ses', 'SES_REGION')
    sesclient = boto3.client('ses', region_name=SES_REGION)
    if cc is None and bcc is None:
        msg = {
                    'Data':
                    'From: ' + SES_MAIL_FROM + '\n'
                    'To: ' + to + '\n'
                    'Subject: ' + subject + '\n'
                    'MIME-Version: 1.0\n'
                    'Content-type: Multipart/Mixed; '
                    'boundary="NextPart"\n'
                    '\n'
                    '--NextPart\n'
                    'Content-Type: text/html\n'
                    '\n' + html_content + '\n'
                    '\n--NextPart--',
            }
    else:
        logging.error('Not implemented the cc or bcc in ses mail sender.')
    if not dryrun:
        try:
            response = sesclient.send_raw_email(RawMessage=msg)
            logging.info("Sent an alert email to {0}".format(str(to)))
            return response
        except Exception as e:
            logging.error("Failed to send email to {0} with error: {1}".format(str(to), e))
            raise
    else:
        logging.info("Dryrun (so note sent) an alert email to {0}".format(str(to)))



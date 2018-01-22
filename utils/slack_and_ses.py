from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

from builtins import str
from past.builtins import basestring

import importlib
import logging

def send_messages(to, subject, html_content, files=None, dryrun=False, cc=None, bcc=None, mime_subtype='mixed', SLACK_TOKEN=None, SES_MAIL_FROM=None, SES_REGION=None):
    try:
        slack_module = importlib.import_module('airflow.utils.slack_message')
        slack_message = getattr(slack_module, 'send_slack')
        slack_response = slack_message(to.split(",")[0], subject, html_content, files=files, dryrun=dryrun, cc=cc, bcc=bcc,
                                       mime_subtype=mime_subtype, SLACK_TOKEN=SLACK_TOKEN)
        slack_passed = True
    except Exception as e:
        logging.error("Failed to send SLACK message with error: {0}".format(e))
        slack_passed = False

    try:
        ses_module = importlib.import_module('airflow.utils.ses_email')
        ses_email = getattr(ses_module, 'send_email')
        ses_response = ses_email(to.split(",")[1], subject, html_content, files=files, dryrun=dryrun, cc=cc, bcc=bcc,
                                 mime_subtype=mime_subtype, SES_MAIL_FROM=SES_MAIL_FROM, SES_REGION=SES_REGION)
    except Exception as e:
        logging.error("Failed to send SES message with error: {0}".format(e))
        if slack_passed: return slack_response
    return slack_response, ses_response






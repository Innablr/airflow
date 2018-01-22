from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

from builtins import str
from past.builtins import basestring

import importlib
import logging
from airflow import configuration

from slackclient import SlackClient

def send_slack(to, subject, html_content, files=None, dryrun=False, cc=None, bcc=None, mime_subtype=None, SLACK_TOKEN=None):
    if SLACK_TOKEN is None:
        SLACK_TOKEN = configuration.get('slack', 'OAUTH_TOKEN')
    sc = SlackClient(SLACK_TOKEN)
    if not dryrun:
        red = "#ff0000"
        orange = "#ff6700"
        try:
            if "up_for_retry" in subject:
                colour = orange
            else:
                colour = red
            message = subject.replace("Airflow alert: <", "")
            message = message.replace(">", "\n")
            message = message.replace("[", "*")
            message = message.replace("]", "*")
            attachment_content = html_content.replace("<br>", "\n")
            top_text = attachment_content.split("Log: <a href='")[0] + "\n"
            log_link = "<" + attachment_content.split("Log: <a href='")[1].split(">Link</a>")[0] + "|Link to task log>   "
            mark_success_link = "<" + attachment_content.split("Mark success: <a href='")[1].split(">Link</a>")[0] + "|Link to mark task successful>"
            message_attachments = [
                {
                    "fallback": "Message subject may be MIA. Or there might be a problem with your slack client.",
                    "color": colour,
                    "attachment_type": "default",
                    "text": top_text + log_link + mark_success_link
                }
            ]
            response = sc.api_call(
                "chat.postMessage",
                channel=to,
                text=message,
                attachments=message_attachments
            )
            logging.info("Sent an alert slack to channel {0}.".format(str(to)))
            return response
        except Exception as e:
            logging.error("Failed to send slack message to {0} with error: {1}".format(str(to), str(e)))
            return e
    else:
        logging.info("Dryrun (so not sent) a slack alert to {0}".format(str(to)))



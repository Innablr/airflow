# AIRFLOW VERSION 1.8.0
# AUTHOR: Dan Hornby
# DESCRIPTION: Airflow container
# BUILD: docker build --rm -t docker-airflow .
# SOURCE REPO: TBD

# FROM gliderlabs/alpine@sha256:3bc470ae90dc25fc5fbd09a115ec3662762c8ad15de4b2a3411dd021e52469fc
FROM gliderlabs/alpine:3.4

# Airflow
ARG AIRFLOW_VERSION=1.8.0
ARG AIRFLOW_HOME=/usr/local/airflow
ENV AIRFLOW_HOME ${AIRFLOW_HOME}

RUN apk add --update \
    jq \
    python \
    python-dev \
    py-pip \
    py-cryptography \
    build-base \
    curl \
    krb5 \
    cyrus-sasl \
    openssl-dev \
    ca-certificates \
    libpq \
    postgresql-dev \
    git \
    cython-dev \
    libffi-dev \
    libxml2-dev \
    libxslt-dev \
    redis \
    linux-headers \
    bash

RUN pip install --upgrade pip \
  && pip install pytz \
  && pip install pyOpenSSL \
  && pip install ndg-httpsclient \
  && pip install pyasn1 \
  && pip install airflow[s3,crypto,celery,postgres,hive,hdfs,jdbc]==$AIRFLOW_VERSION \
  && pip install celery[redis]==3.1.17 \
  && pip install boto \
  && pip install boto3 \
  && pip install awscli \
  && pip install beautifulsoup4 \
  && pip install requests \
  && pip install requests-ntlm \
  && pip install configparser \
  && pip install parse \
  && pip install celery \
  && pip install ldap3 \
  && pip install slackclient \
  && pip install pyyaml \
  && pip install pysftp \
  && adduser -s /bin/bash -D -h ${AIRFLOW_HOME} airflow \
  && rm -rf /var/cache/apk/*

RUN mkdir ${AIRFLOW_HOME}/.aws

COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg
COPY dags ${AIRFLOW_HOME}/dags
COPY script/* ${AIRFLOW_HOME}/
COPY hook/S3_hook.patch /S3_hook.patch
COPY /www/views.patch /views.patch
COPY /utils /usr/lib/python2.7/site-packages/airflow/utils

RUN mv ${AIRFLOW_HOME}"/entrypoint.sh" "/entrypoint.sh"
RUN chown -R airflow: ${AIRFLOW_HOME} "/entrypoint.sh"
RUN chmod -R 755 ${AIRFLOW_HOME} "/entrypoint.sh"
RUN cd /usr/lib/python2.7/site-packages/airflow/hooks; patch S3_hook.py -p0 </S3_hook.patch
RUN cd /usr/lib/python2.7/site-packages/airflow/www; patch views.py -p0 </views.patch

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]

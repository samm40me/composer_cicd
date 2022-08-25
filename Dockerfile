FROM eu.gcr.io/cts-public-images-1/cts-standard


ARG AIRFLOW_VERSION=2.2.5
ARG PYTHON_VERSION=3.9
ARG CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
RUN pip install "apache-airflow[async,postgresql,google]==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"
RUN echo "alias python=python3" >> ~/.bashrc

COPY requirements.txt /tmp
RUN  pip install -r /tmp/requirements.txt
RUN  gcloud components install kubectl


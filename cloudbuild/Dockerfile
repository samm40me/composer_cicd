FROM eu.gcr.io/cts-public-images-1/cts-standard


ARG AIRFLOW_VERSION=2.3.3
ARG PYTHON_VERSION=3.9
ARG CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
RUN pip install "apache-airflow[async,postgresql,google]==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"
RUN echo "alias python=python3" >> ~/.bashrc

COPY cloudbuild/requirements.txt /tmp
RUN  pip install -r /tmp/requirements.txt
RUN  curl -LO https://dl.k8s.io/release/v1.25.0/bin/linux/amd64/kubectl
RUN  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

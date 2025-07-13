FROM apache/airflow

USER root

# Install vim
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    vim \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER airflow

COPY image-requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt
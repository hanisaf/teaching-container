# Teaching container: Python + Jupyter + PySpark with the packages used in my courses.
# One Dockerfile for both architectures; build with --platform linux/amd64 or linux/arm64.
FROM python:3.12-slim
LABEL maintainer="hanisaf@uga.edu"

# Set automatically by BuildKit from --platform (amd64 / arm64)
ARG TARGETARCH

ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    JAVA_HOME=/usr/lib/jvm/java-21-openjdk-${TARGETARCH}
ENV PATH="$JAVA_HOME/bin:$PATH"

# Runtime system packages:
#   openjdk-21-jre-headless  Java runtime for Spark (native to Debian trixie, no bookworm pinning needed)
#   ncat                     netcat, used for socket streaming exercises
#   nano                     terminal text editor
#   procps                   ps/top, used by Spark scripts and handy for students
RUN apt-get update \
 && apt-get install -y --no-install-recommends openjdk-21-jre-headless ncat nano procps \
 && rm -rf /var/lib/apt/lists/*

# Python packages. Compilers are installed only for this step (in case a package
# has no prebuilt wheel) and removed in the same layer so they add no size.
COPY requirements.txt /tmp/requirements.txt
RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential \
 && pip install -r /tmp/requirements.txt \
 && apt-get purge -y --auto-remove build-essential \
 && rm -rf /var/lib/apt/lists/* /tmp/requirements.txt

RUN python -m textblob.download_corpora \
 && python -m spacy download en_core_web_sm

ENV SPARK_LOCAL_IP=127.0.0.1 \
    SPARK_LOCAL_HOSTNAME=localhost \
    PYSPARK_SUBMIT_ARGS="--master local[1] \
    --conf spark.driver.host=127.0.0.1 \
    --conf spark.driver.bindAddress=127.0.0.1 \
    --conf spark.local.ip=127.0.0.1 \
    --conf spark.driver.extraJavaOptions=-Djava.net.preferIPv4Stack=true \
    pyspark-shell"

# Pre-populate the Ivy cache with hadoop-aws (and the ~700MB AWS SDK bundle) so
# notebooks using spark.jars.packages don't download it at runtime. Ivy also copies
# every jar into ~/.ivy2*/jars; that copy is deleted here (Spark recreates it from
# the cache on first use, no network needed), which halves the size of this layer.
RUN python -c "\
from pyspark.sql import SparkSession; \
SparkSession.builder \
    .appName('preload') \
    .config('spark.jars.packages', 'org.apache.hadoop:hadoop-aws:3.5.0') \
    .getOrCreate().stop()" \
 && rm -rf /root/.ivy2*/jars

COPY ipython_config.py /root/.ipython/profile_default/ipython_config.py

WORKDIR /user

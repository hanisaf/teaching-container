#!/bin/bash
set -e

IMAGE_ARM64="hanisaf/teaching_container_arm64"
PLATFORM="linux/arm64"

CONTAINER_NAME="notebook_$(date +%s)"

echo "==================================================="
echo "Container is starting up..."
echo "To open a separate terminal inside this container, run:"
echo "docker exec -it ${CONTAINER_NAME} bash"
echo "==================================================="
echo

docker run --platform "${PLATFORM}" --rm -it \
	--name "${CONTAINER_NAME}" \
	-p 8888:8888 \
	-p 4040:4040 \
	-p 4041:4041 \
	-p 4042:4042 \
	-p 4043:4043 \
	-v "$PWD":/app/work \
	-e SPARK_LOCAL_IP=0.0.0.0 \
	-e SPARK_LOCAL_HOSTNAME=localhost \
	-e SOCKET_HOST=host.docker.internal \
	-e s3a_access_key="${s3a_access_key}" \
	-e s3a_secret_key="${s3a_secret_key}" \
	-e PYSPARK_SUBMIT_ARGS="--master local[*] --conf spark.ui.enabled=true --conf spark.ui.port=4040 --conf spark.driver.host=0.0.0.0 --conf spark.driver.bindAddress=0.0.0.0 --conf spark.local.ip=0.0.0.0 --conf spark.driver.extraJavaOptions=-Djava.net.preferIPv4Stack=true pyspark-shell" \
	"${IMAGE_ARM64}" \
	jupyter notebook --allow-root --ip 0.0.0.0

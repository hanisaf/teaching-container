#!/bin/bash
set -e

IMAGE_ARM64="hanisaf/teaching_container_arm64"
PLATFORM="linux/arm64"

CONTAINER_NAME="teaching_container"

# Clean up: remove leftovers from earlier runs (closing the terminal window instead of
# Ctrl+C leaves the container running, holding port 8888), including old notebook_<timestamp>
# containers, and remove this run's container when the script exits for any reason.
cleanup() { docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true; }
leftovers=$(docker ps -aq --filter "name=^(teaching_container|notebook_[0-9]+)$")
[ -n "${leftovers}" ] && docker rm -f ${leftovers} >/dev/null
trap cleanup EXIT
trap 'exit 130' INT TERM HUP

echo "==================================================="
echo "Container is starting up..."
echo "To open a separate terminal inside this container, run:"
echo "docker exec -it ${CONTAINER_NAME} bash"
echo "Press Ctrl+C to stop the container."
echo "==================================================="
echo

# Run detached and follow the logs: waiting on the log follower in the background lets the
# traps above fire right away on Ctrl+C or a closed window (a foreground `docker run -it`
# blocks them, which is what left containers running for days).
docker run --platform "${PLATFORM}" --rm -d \
	--name "${CONTAINER_NAME}" \
	-p 8888:8888 \
	-p 4040:4040 \
	-p 4041:4041 \
	-p 4042:4042 \
	-p 4043:4043 \
	-v "$PWD":/user/work \
	-e SPARK_LOCAL_IP=0.0.0.0 \
	-e SPARK_LOCAL_HOSTNAME=localhost \
	-e SOCKET_HOST=host.docker.internal \
	-e s3a_access_key="${s3a_access_key}" \
	-e s3a_secret_key="${s3a_secret_key}" \
	-e PYSPARK_SUBMIT_ARGS="--master local[*] --conf spark.ui.enabled=true --conf spark.ui.port=4040 --conf spark.driver.host=0.0.0.0 --conf spark.driver.bindAddress=0.0.0.0 --conf spark.local.ip=0.0.0.0 --conf spark.driver.extraJavaOptions=-Djava.net.preferIPv4Stack=true pyspark-shell" \
	"${IMAGE_ARM64}" \
	jupyter notebook --allow-root --ip 0.0.0.0 --no-browser >/dev/null

docker logs -f "${CONTAINER_NAME}" &
wait $!

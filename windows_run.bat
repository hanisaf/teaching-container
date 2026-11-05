@echo off
set CONTAINER_NAME=teaching_container
REM Clean up leftovers from earlier runs (closing the window instead of Ctrl+C leaves the
REM container running, holding port 8888), including old notebook_<timestamp> containers
docker rm -f %CONTAINER_NAME% >nul 2>&1
for /f %%n in ('docker ps -a --format "{{.Names}}" ^| findstr /r /x "notebook_[0-9]*"') do docker rm -f %%n >nul 2>&1

echo ===================================================
echo Container is starting up...
echo To open a separate terminal inside this container, run:
echo docker exec -it %CONTAINER_NAME% bash
echo ===================================================
echo.


docker run --platform linux/amd64 --rm -it ^
    --name %CONTAINER_NAME% ^
    -p 8888:8888 ^
    -p 4040:4040 ^
    -p 4041:4041 ^
    -p 4042:4042 ^
    -p 4043:4043 ^
    -p 7777:7777 ^
    -v "%CD%":/user/work ^
    -e SPARK_LOCAL_IP=0.0.0.0 ^
    -e SPARK_LOCAL_HOSTNAME=localhost ^
    -e SOCKET_HOST=host.docker.internal ^
    -e s3a_access_key=%s3a_access_key% ^
    -e s3a_secret_key=%s3a_secret_key% ^
    -e PYSPARK_SUBMIT_ARGS="--master local[*] --conf spark.ui.enabled=true --conf spark.ui.port=4040 --conf spark.driver.host=0.0.0.0 --conf spark.driver.bindAddress=0.0.0.0 --conf spark.local.ip=0.0.0.0 --conf spark.driver.extraJavaOptions=-Djava.net.preferIPv4Stack=true pyspark-shell" ^
    hanisaf/teaching_container_amd64 ^
    jupyter notebook --allow-root --ip 0.0.0.0

REM In case the container is still around after docker run returns
docker rm -f %CONTAINER_NAME% >nul 2>&1

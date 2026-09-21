@echo off
set CONTAINER_NAME=notebook
for /f %%i in ('powershell -Command "[int64]([datetimeoffset]::Now.ToUnixTimeSeconds())"') do set CONTAINER_NAME=notebook_%%i

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
    -v "%CD%":/app/work ^
    -e SPARK_LOCAL_IP=0.0.0.0 ^
    -e SPARK_LOCAL_HOSTNAME=localhost ^
    -e SOCKET_HOST=host.docker.internal ^
    -e s3a_access_key=%s3a_access_key% ^
    -e s3a_secret_key=%s3a_secret_key% ^
    -e PYSPARK_SUBMIT_ARGS="--master local[*] --conf spark.ui.enabled=true --conf spark.ui.port=4040 --conf spark.driver.host=0.0.0.0 --conf spark.driver.bindAddress=0.0.0.0 --conf spark.local.ip=0.0.0.0 --conf spark.driver.extraJavaOptions=-Djava.net.preferIPv4Stack=true pyspark-shell" ^
    hanisaf/teaching_container_amd64 ^
    jupyter notebook --allow-root --ip 0.0.0.0

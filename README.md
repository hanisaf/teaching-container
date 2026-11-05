# teaching-container
docker container with packages needed for my courses, python jupyter notebook with pyspark configured.
It also includes `ncat` (netcat) and `nano`.

set up `s3a_access_key` and `s3a_secret_key` as environment variables, their values are available from eLC

run compile first then run. To access files in a certain directory, run the run script from that directory.
That directory is available inside the container (and in Jupyter) as `/user/work`.

A single `Dockerfile` builds both architectures (`--platform linux/arm64` on mac, `--platform linux/amd64` on windows).

I also offer prebuilt images if you don't want to build locally

`docker pull hanisaf/teaching_container_arm64` for mac

and 

`docker pull hanisaf/teaching_container_amd64` for windows

This image is also the base image (step 1) of `notebook-tester`.

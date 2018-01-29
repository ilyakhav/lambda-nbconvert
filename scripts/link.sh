#!/bin/bash

rm -rf build
mkdir -p build
docker build -t lambda .
docker run -v $PWD:/outputs -v $PWD/build:/lambda_build/lib/python3.6/site-packages -it lambda /bin/bash /outputs/install_python_packages_docker_venv.sh

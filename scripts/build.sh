#!/bin/bash

rm -rf build
mkdir -p build
rm -rf lib
mkdir -p lib

docker build -t lambda .
docker run -v $(pwd):/outputs -it lambda /bin/bash /outputs/install_python_packages_docker_venv.sh


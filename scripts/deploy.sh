#!/bin/bash

rm -rf build
mkdir -p build
docker build -t lambda .
docker run -v $PWD:/outputs -v $PWD/build:/lambda_build/lib/python3.6/site-packages -it lambda /bin/bash /outputs/install_python_packages_docker_venv.sh

aws cloudformation package \
   --template-file template.yaml \
   --output-template-file packaged.yaml \
   --s3-bucket $1

aws cloudformation deploy --capabilities CAPABILITY_IAM --template-file packaged.yaml --stack-name  $2 --region $3

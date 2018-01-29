FROM lambci/lambda:build-python3.6

RUN mkdir /app
COPY install_python_packages_docker_venv.sh /app/.
COPY numpy_pickle_utils.py /app/.
COPY requirements.txt /app/.

WORKDIR /
CMD ["/bin/bash"] 
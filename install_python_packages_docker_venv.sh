#!/bin/bash

yum -y update
yum -y upgrade
yum install -y \
    atlas-devel \
    atlas-sse3-devel \
    blas-devel \
    gcc \
    gcc-c++ \
    lapack-devel \
    findutils \
    xz \
    zip \
    libgfortran \
    gcc-gfortran \
    blas \
    lapack

rm -rf /var/runtime /var/lang && \
  curl https://lambci.s3.amazonaws.com/fs/python3.6.tgz | tar -xz -C / && \
  curl https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz | tar -xJ && \
  cd Python-3.6.1 && \
  ./configure --prefix=/var/lang && \
  make -j$(getconf _NPROCESSORS_ONLN) libinstall inclinstall && \
  cd .. && \
  rm -rf Python-3.6.1

do_pip () {
		pip install --upgrade pip wheel
		pip install --use-wheel --no-binary numpy numpy
		pip install --use-wheel --no-binary scipy scipy
		pip install --use-wheel -U sklearn
		pip install --use-wheel multiprocess
		pip install --use-wheel -r /outputs/requirements.txt
		# It seems scipy==0.20 is not compile with the script.
		# scikit-learn==0.18.0 need to fix numpy_pickle_utils.py under folder of /lambda_build/lib/python3.6/site-packages/sklearn/externals/joblib/
		# 2.0.6 has issue with my model on num_leavs.
	}

strip_virtualenv () {
		echo "original size $(du -sh $VIRTUAL_ENV | cut -f1)"
        pip uninstall -y Jinja2

		find $VIRTUAL_ENV/lib/python3.6/site-packages/ -name "tests*"| xargs rm -r

		# Can't remove tests files from pandas
		pip install pandas==0.20.3
		find $VIRTUAL_ENV/lib/python3.6/site-packages/ -name "*.txt" | xargs rm -r
		find $VIRTUAL_ENV/lib/python3.6/site-packages/ -name "*.so" | xargs strip

		find $VIRTUAL_ENV/lib/python3.6/site-packages/ -name "*.pyc" -delete
		find $VIRTUAL_ENV/lib/python3.6/site-packages/ -type d -empty -delete

		pip install Jinja2==2.10

		echo "current size $(du -sh $VIRTUAL_ENV | cut -f1)"

		pushd $VIRTUAL_ENV/lib/python3.6/llib/ && cp -r * /outputs/lib/ ; popd
		pushd $VIRTUAL_ENV/lib/python3.6/site-packages/ && cp -r * /outputs/build/ ; popd

	}

shared_libs () {
    libdir="$VIRTUAL_ENV/lib/python3.6/llib/"
    mkdir -p $VIRTUAL_ENV/lib/python3.6/llib || true
    cp /usr/lib64/atlas/* $libdir
    cp /usr/lib64/libquadmath.so.0 $libdir
    cp /usr/lib64/libgfortran.so.3 $libdir
}

main () {
		pip install virtualenv
		virtualenv -p /var/lang/bin/python \
			        --always-copy \
			        --no-site-packages \
			        lambda_build

		source lambda_build/bin/activate

        do_pip

        shared_libs

        strip_virtualenv

    	pip list --format=columns
}

main

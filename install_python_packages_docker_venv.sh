#!/bin/bash

install_pip_requirements () {
		pip install --upgrade pip wheel		
		pip install -r /app/requirements.txt
		# It seems scipy==0.20 is not compile with the script.
		# scikit-learn==0.18.0 need to fix numpy_pickle_utils.py under folder of /lambda_build/lib/python3.6/site-packages/sklearn/externals/joblib/
		# 2.0.6 has issue with my model on num_leavs.
        pip uninstall -y -v Jinja2
        # We need to uninstall 'Jinja2' that was installed as a dependency for 'nbconvert' package
        # and install it after optimization routines was performed because those routines 
        # remove extra modules that 'Jinja2' requires for correct execution.
	}

strip_virtualenv () {
		echo "original size $(du -sh $VIRTUAL_ENV | cut -f1)"
		find $VIRTUAL_ENV/lib/python3.6/site-packages/ -name "tests*" | xargs rm -r
		find $VIRTUAL_ENV/lib/python3.6/site-packages/ -name "dataset*" | xargs rm -r

		# Can't remove tests files from pandas
		pip install pandas==0.22.0
        # Install previously uninstalled 'Jinja2' package
        pip install Jinja2==2.10
		find $VIRTUAL_ENV/lib/python3.6/site-packages/ -name "*.txt" | xargs rm -r
		find $VIRTUAL_ENV/lib/python3.6/site-packages/ -name "*.so" | xargs strip
				
		find $VIRTUAL_ENV/lib/python3.6/site-packages/ -name "*.pyc" -delete
		find $VIRTUAL_ENV/lib/python3.6/site-packages/ -type d -empty -delete
		echo "current size $(du -sh $VIRTUAL_ENV | cut -f1)"
	}

main () {
		pip install virtualenv
		virtualenv -p /var/lang/bin/python \
			        --always-copy \
			        --no-site-packages \
			        lambda_build

		source lambda_build/bin/activate
    
    	install_pip_requirements

    	strip_virtualenv		

    	pip list --format=columns
}

main


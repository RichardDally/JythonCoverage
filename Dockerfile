FROM openjdk:8

RUN apt-get update
RUN apt-get install -y curl unzip emacs-nox

RUN wget https://files.pythonhosted.org/packages/b2/40/4e00501c204b457f10fe410da0c97537214b2265247bc9a5bc6edd55b9e4/setuptools-44.1.1.zip
RUN unzip -o -q setuptools-44.1.1.zip && cd setuptools-44.1.1 && python setup.py install && cd .. && rm -rf setuptools-44.1.1

RUN wget https://files.pythonhosted.org/packages/53/7f/55721ad0501a9076dbc354cc8c63ffc2d6f1ef360f49ad0fbcce19d68538/pip-20.3.4.tar.gz
RUN tar -xf pip-20.3.4.tar.gz && cd pip-20.3.4 && python setup.py install && cd .. && rm -rf pip-20.3.4

WORKDIR /setup/

RUN wget -O sonar-scanner-cli-4.6.0.2311-linux.zip https://bintray.com/sonarsource/SonarQube/download_file?file_path=org%2Fsonarsource%2Fscanner%2Fcli%2Fsonar-scanner-cli%2F4.6.0.2311%2Fsonar-scanner-cli-4.6.0.2311-linux.zip
RUN unzip -o -q sonar-scanner-cli-4.6.0.2311-linux.zip
RUN ln -s sonar-scanner-cli-4.6.0.2311-linux/ sonar-scanner
ENV PATH="${PATH}:/setup/sonar-scanner/bin"

ENV JYTHON_HOME=/opt/jython-2.7.1
ENV PATH=${PATH}:${JYTHON_HOME}/bin
RUN wget https://repo1.maven.org/maven2/org/python/jython-installer/2.7.1/jython-installer-2.7.1.jar
RUN java -jar jython-installer-2.7.1.jar -s -d "${JYTHON_HOME}"

# COVERAGE
RUN wget https://files.pythonhosted.org/packages/85/d5/818d0e603685c4a613d56f065a721013e942088047ff1027a632948bdae6/coverage-4.5.4.tar.gz
RUN tar -xf coverage-4.5.4.tar.gz && cd coverage-4.5.4 && python setup.py install && jython setup.py install && cd .. && rm -rf coverage-4.5.4

# COLORAMA
RUN wget https://files.pythonhosted.org/packages/44/98/5b86278fbbf250d239ae0ecb724f8572af1c91f4a11edf4d36a206189440/colorama-0.4.4-py2.py3-none-any.whl
RUN jython -m pip install colorama-0.4.4-py2.py3-none-any.whl

# PY
RUN wget https://files.pythonhosted.org/packages/67/32/6fe01cfc3d1a27c92fdbcdfc3f67856da8cbadf0dd9f2e18055202b2dc62/py-1.10.0-py2.py3-none-any.whl
RUN jython -m pip install py-1.10.0-py2.py3-none-any.whl

# PYTEST
RUN wget https://files.pythonhosted.org/packages/35/3e/76e99f39c1cc04e9701d447a5667d9ec45f724ca11b6f5c797492339aef1/pytest-2.7.2-py2.py3-none-any.whl
RUN jython -m pip install pytest-2.7.2-py2.py3-none-any.whl

RUN sed -i '10,11d' ${JYTHON_HOME}/Lib/site-packages/_pytest/core.py

RUN jython -m pip -V && python -m pip -V && jython -m coverage --version


WORKDIR /myproject/

COPY mymodule.py sources/
COPY test_mymodule.py tests/

RUN jython -m coverage run -m pytest

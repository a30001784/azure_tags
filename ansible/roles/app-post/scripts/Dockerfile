FROM ubuntu:18.04

# Install required packages
RUN apt-get -y update && apt-get -y install \
    git \
    python-pip \
    unzip \
    wget

# Install Cython
RUN pip install Cython

# Set up working directories
RUN mkdir /usr/sap /work

# Download SAP NW RFC libraries
RUN wget -O /work/nwrfc750P_2-70002752.zip \
    "https://sapreleasefilesharing.blob.core.windows.net/sap-ptia-install/RFCLIB/Linux X86-64/nwrfc750P_2-70002752.zip?sp=r&st=2018-11-29T03:44:06Z&se=2018-12-29T11:44:06Z&spr=https&sv=2017-11-09&sig=C%2F19F33M2RT%2FveWoDrKrcEDKD5lUHPj2d4FfE7bIBzU%3D&sr=b"

# Extract lib files to SAP directory 
RUN unzip -d /usr/sap \
    /work/nwrfc750P_2-70002752.zip

# Create links to SAP libraries
RUN echo /usr/sap/nwrfcsdk/lib > /etc/ld.so.conf.d/nwrfcsdk.conf && \
    ldconfig

# Clone PyRFC GitHub repo
RUN git clone https://github.com/SAP/PyRFC.git /work/PyRFC

# Tell PyRFC installer where SAPNWRFC files are located
ENV SAPNWRFC_HOME=/usr/sap/nwrfcsdk

WORKDIR /work/PyRFC 

# Install PyRFC connector
RUN python ./setup.py bdist_wheel
RUN python ./setup.py install

# Test. If this command fails the image won't be created.
RUN python -c "from pyrfc import Connection"

# Copy python script and set permissions
ADD examples/clientPrintDescription.py /work/clientPrintDescription.py
RUN chmod +x /work/clientPrintDescription.py

# Python3
ENTRYPOINT [ "python", "/work/clientPrintDescription.py", "PFL_READ_PROFILE_FROM_DB" ]

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
    "https://aaasapautomationsa.blob.core.windows.net/sapptia/sapPTIA/nwrfcsdk750P_3-70002752.zip?sp=r&st=2019-05-03T03:55:14Z&se=2019-11-03T10:55:14Z&spr=https&sv=2018-03-28&sig=LGIiwFcYd%2Fe0HSFPFnkKwq753GzA8HJrkaePBVcFXv8%3D&sr=b"

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

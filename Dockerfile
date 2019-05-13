FROM centos:7

# Update packages and install the needful
RUN yum -y install epel-release
RUN yum -y update && yum -y install \
        ansible \
        python-pip \
        unzip
RUN yum clean all && \
    rm -rf /var/cache/yum

# Install Windows/Ansible dependencies
RUN pip2.7 install --upgrade pip && \
    pip2.7 install "pywinrm>=0.3.0" "ansible==2.7.0"

# Begin!
ENTRYPOINT [ "bash", "/docker-entrypoint.sh" ]
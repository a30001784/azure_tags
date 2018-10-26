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
    pip2.7 install "pywinrm>=0.3.0" "ansible==2.4.6"

# Download and install Terraform
RUN curl https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip -d /usr/bin

# Set up working directory
COPY . /working/.
WORKDIR /working

# Configure entrypoint
RUN chmod +x /working/docker-entrypoint.sh

# Begin!
ENTRYPOINT [ "/working/docker-entrypoint.sh" ]
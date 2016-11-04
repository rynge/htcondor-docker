FROM centos:centos6

MAINTAINER Lincoln Bryant <lincolnb@uchicago.edu>

# Build in one RUN
RUN 
    rpm --import http://research.cs.wisc.edu/htcondor/yum/RPM-GPG-KEY-HTCondor && \ 
    curl https://research.cs.wisc.edu/htcondor/yum/repo.d/htcondor-development-rhel6.repo > /etc/yum.repos.d/htcondor-development-rhel6.repo && \
    yum -y install condor && \
    yum -y install epel-release && \
    yum -y install http://repo.grid.iu.edu/osg/3.3/osg-3.3-el6-release-latest.rpm && \ # grab the OSG repo after installing development condor
    yum -y install openssh-clients \ 
                   osg-wn-client \
                   osg-wn-client-glexec \
                   redhat-lsb-core && \
    yum clean all 

# KNOBS and startup script
COPY condor_config.docker_image /etc/condor/config.d/
COPY start-condor.sh /usr/sbin/

# Grab the docker socket's GID and add that to groups, then add condor as a member of that group before starting condor.
ENTRYPOINT groupadd docker -g $(stat -c "%g" /var/run/docker.sock) && \
           usermod -g docker condor && \ 
           /usr/sbin/start-condor.sh

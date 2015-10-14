======================================
Docker container builder for Pacemaker
======================================

#Install
  1. Install dnsmasq for the resolving hostname of containers:
  
      `make dnsmasq_install`
  
  2. Build the docker image with RabbitMQ. The basis is the phusion/baseimage:
  
      `make all`

Using
-----
  1. Create test Pacemaker cluster (3 nodes: pcmk1, pcmk2, pcmk3):
  
      `make env`
  
  2. Remove Pacemaker cluster:
  
      `make env_rm`

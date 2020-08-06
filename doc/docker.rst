.. include:: vars.rst

.. _section-Intro:


Docker
*********

This document describes examples and configurations when you run your 
|RTI_CONNEXT_TM| applications with *Docker®*. 

Docker Overview
-----------------------
Docker is a tool that can package an application and its dependencies in 
a container that can run on any Linux machine. This enables flexibility 
and portability on where the application can run, whether on premises, 
public cloud, private cloud, bare metal, etc. Docker also provides mechanisms 
to control resource consumption and create virtual networks, etc.

Some people think containers are similar to virtual machines. 
Why? With a virtual machine, you can run applications along with their 
dependencies in a separate environment, and you can bundle a virtual machine 
into an image that you run on other host machines. So, what is the difference?

When you run a virtual machine, you virtualize a complete operating system. 
When you run a container, you use some of the Linux kernel capabilities to 
isolate the resources of your system (i.e. cgroups and namespaces). 
Processes and files in a container are not accessible by other containers. 
However, processes are still running on the same kernel (directly, without 
virtualization). In short, container technologies virtualize resources at 
operating-system level while a hypervisor-based virtual machine technologies 
virtualizes resources at hardware level.

Docker Networking
-----------------------
Docker networking is the most relevant topic to DDS, so we would like to 
cover this topic in a detailed manner. Docker’s networking subsystem is 
pluggable and provides built-in drivers. Depending on what you need, 
you can configure a network with one of the supported drivers. 
The built-in drivers include:

* **Host Driver**: This driver exposes the networking stack of the host machine 
  to a container. All networking interfaces of the host machine are directly 
  accessed from a container. 

* **Bridge Driver**: This is the default network driver. The bridge driver 
  creates a bridge network between the host and containers running in the 
  host machine. A bridge network allows containers connected to the same 
  bridge network to communicate, while providing isolation from containers 
  which are not connected to that bridge network. 

* **Overlay Driver**: The overlay networks create a virtual network used to 
  create a layer to abstract from the physical networks. An overlay network 
  interconnects multiple nodes (a multi-host network) and isolates this 
  network from the host machines. Overlay networks are usually created 
  automatically by container orchestrators such as Docker Swarm or Kubernetes, 
  to allow the communication between the containers.

* **MACVLAN Driver**: This driver exposes host interfaces 
  directly to the containers. With this driver, you can have 
  a single interface associated with multiple MAC and IP addresses using 
  MACVLAN subinterfaces. The containers are attached to MACVLAN subinterfaces. 
  So, if your host machine is connected to a network, you can map multiple IP 
  addresses to your host machine and use them in your Docker containers. 
  So, in other words, you can take an IP address from the IP’s of one of 
  the physical networks that are available in the host machine from the Docker 
  containers. In this case, it works as if your Docker containers were 
  connected directly to the network.

Docker and RTI Connext DDS
---------------------------
As described above, several network drivers are available for 
a Docker container. However, DDS communications between Docker containers 
do not work out of the box with some network drivers. This documentation 
will provide guidance on building and running RTI Connext DDS applications 
with Docker over the network drivers supported by Docker. 

*Note: Only the Linux architectures listed in the PAM are supported. 
This means that it is not guaranteed that other architectures will run 
(for example, Alpine Linux is not supported currently). Windows containers 
have not been tested with RTI Connext DDS.*

Creating a Docker Image with RTI Connext DDS
---------------------------------------------
In this example, we’ll create a Docker image that can build 
RTI Connext DDS applications. We’ll use Ubuntu 16.04 (x64) 
for the target operating system and assume that the host is also 
using a Linux OS. We’ll create an image named ``dds-build``. 
It will be relatively large because it holds the RTI Connext DDS installation 
and the Linux build tools.

*Note: The host can use a different version of a Linux, Windows, or Mac operating system.*

Creating the Build Image
====================================
We’ll create a Docker image, named ``dds-build``, that can build DDS applications. 
This image needs to include the DDS installation as well as build tools like 
make and gcc. The goal is to create an image that is capable of 
building any DDS application. When you use ``dds-build`` to compile your 
RTI Connext DDS application, you will need to mount your source-code directory 
as a volume in the Docker container. This process is explained in a separate 
article (LINK).

We’ll begin by creating a directory named ``mybuild`` (or whatever you prefer).
This directory will hold the build context for creating the image:

.. code-block:: bash

  $ mkdir mybuild

Now download the RTI Connext DDS host and target installation files and 
copy them to mybuild.  In this example, we use the following files:

.. code-block:: bash

  rti_connext_dds-5.3.0-pro-host-x64Linux.run
  rti_connext_dds-5.3.0-pro-target-x64Linux3gcc5.4.0.rtipkg

We now need to tell Docker what to do with these files.  
Create a file named ``Dockerfile`` in ``mybuild``, with the following content:

.. literalinclude:: ../examples/docker/build/Dockerfile
    :language: dockerfile

The mybuild directory should now contain these files:

.. code-block:: bash

  Dockerfile
  rti_connext_dds-5.3.0-pro-host-x64Linux.run
  rti_connext_dds-5.3.0-pro-target-x64Linux3gcc5.4.0.rtipkg

We’re now ready to actually build the first Docker image. 
Use these commands to build the image:

.. code-block:: bash

  $ cd mybuild
  $ docker build -t dds-build .

When Docker finishes running, your local Docker registry will have an image 
named ``dds-build``.  You can confirm this by running:

.. code-block:: bash

  $ docker image ls
  REPOSITORY  TAG         IMAGE ID        CREATED          SIZE
  dds-build   latest      f39efa68fcdf    16 seconds ago   1.37GB
  $

Congratulations! You have created a Docker image that can be used to build DDS applications.

Variation: Evals
=================
If you are using an evaluation version of RTI Connext DDS, 
you must follow a different process for creating your DDS build image.  
This is because the evaluation installer does not support unattended mode.

In order to use the evaluation version, first install it locally on 
your operating system.  (You must use the same operating system that will be 
used in the Docker DDS build image.)  For example, create a directory named 
``mybuild_eval`` and install RTI Connext DDS in this directory, so that the 
installation path is ``mybuild_eval/rti_connext_dds-5.3.0``.  
Then add the following Dockerfile to ``mybuild_eval``:

.. literalinclude:: ../examples/docker/eval/Dockerfile
    :language: dockerfile

Run the following command to build the image:

.. code-block:: bash

  $ cd mybuild_eval
  $ docker build -t dds-build-eval .

Then you can use the ``dds-build-eval`` image just as you would use the ``dds-build`` image 
described in Creating the Build Image (LINK), above.

Deploying an RTI Connext DDS Application with Docker
----------------------------------------------------

Communications with Bridge Driver
----------------------------------------------------

Communications with Host Driver
----------------------------------------------------

Communications with Overlay Driver and MACVLAN Driver
------------------------------------------------------
Overlay networks are usually created automatically by container orchestrators 
such as Docker Swarm or Kubernetes, to allow the communication between the containers.
Please refer to the Kubernetes section (NEED LINK) to use Docker with overlay driver. 

MACVLAN driver exposes host interfaces directly to the containers.
RTI Connext DDS applications work out of the box with MACVLAN driver. 
An example command to run with MACVLAN driver:

.. code-block:: bash

  $ docker network create -d macvlan --subnet=10.70.1.0/25 --ip-range=<IP range>/<mask> - -o parent=eth1 mynetwork
  $ docker run -ti --network=mynetwork rti /bin/bash


Communications over Shared Memory
----------------------------------------------------
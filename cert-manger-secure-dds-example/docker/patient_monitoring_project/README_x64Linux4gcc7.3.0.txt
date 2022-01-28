Welcome to your first Connext DDS example! 

This example was generated for architecture x64Linux4gcc7.3.0, using the
data type PatientMonitoring from PatientMonitoring.idl.
This example builds two applications, named PatientMonitoring_publisher and
PatientMonitoring_subscriber.

Simple Example
============
If you have generated this example using:
> rtiddsgen -example <arch> <idl>.idl
This is the simple example. This shows how to create a single DataWriter
and DataReader to send and receive data over Connext DDS.

Advanced Example
===============
If you have generated the advanced example using:
> rtiddsgen -example <arch> -exampleTemplate advanced <idl>.idl
The code is similar to the simple example, with a few key differences:
    - Both examples use WaitSets to block a thread until data is available.
      This is the safest way to get data, because it does not affect any
      middleware threads. In addition, the advanced example installs listeners
      on both the DataReader and DataWriter with callbacks that you can
      implement to accomplish a desired behavior. These listener callbacks
      are triggered for various events, such as discovering a matched
      DataWriter or DataReader. Listener callbacks are called back from
      a middleware thread, which you should not block.
    - The simple example sets is_default_qos=true in the XML file, and creates
      the DDS entities without specifying a profile. However, the advanced
      example sets is_default_qos=false, and specifies the QoS profile to use
      from the XML file when creating DDS entities. is_default_qos=false
      is recommended in a production application.

To Build this example:
======================
 
From your command shell, type:
> make -f makefile_PatientMonitoring_x64Linux4gcc7.3.0
This command will build a release executable.
 
To build a debug version instead:
> make -f makefile_PatientMonitoring_x64Linux4gcc7.3.0 DEBUG=1

To Modify the Data:
===================
To modify the data being sent, edit the PatientMonitoring_publisher.cxx
file where it says:
// Modify the data to be written here

To Run this Example:
====================
Make sure you are in the directory where the USER_QOS_PROFILES.xml file was
generated (the same directory this README file is in).
Run /home/epotters/rti_connext_dds-6.1.0/resource/scripts/rtisetenv_x64Linux4gcc7.3.0.bash
to make sure the Connext libraries are in the path, especially if you opened
a new command prompt window.
Run the publishing or subscribing application by typing:
> objs/x64Linux4gcc7.3.0/PatientMonitoring_publisher -d <domain_id> -s <sample_count>
> objs/x64Linux4gcc7.3.0/PatientMonitoring_subscriber -d <domain_id> -s <sample_count>

## Provisioning Certificates for DDS Secure

### Problem

You want to provision certifiactes for DDS Secure applications.

To deploy DDS Secure applications, you need security artifacts including (identity certificate, permission certificate, private key, signed governance/permission files) in place. These artifacts should be prepared before deploying containers in a Kubernetes cluster and provisioned as part of deployed containers. 

### Solution
cert-manager is a Kubernetes add-on to automate the management and issuance of certificates. We will use cert-manager to generate identity/permission CAs. Then, we will generate identity certificates with the identity CA using cert-manager. The identity certifiactes will be provisioned as part of a DDS Secure applicaiton container. The permission CA will be used to sign permission/governance files with OpenSSL commands. 

We will be following the steps in https://community.rti.com/static/documentation/connext-dds/6.1.0/doc/manuals/connext_dds_secure/getting_started_guide/cpp98/hands_on_4.html#

### Required Components:
* **Publisher(Alice)** and **Subscriber(Bob)** are example applications that need to exchange data. 
* **Identity CA Certificate** shared by all the DomainParticipants in your secure system 1. The Identity CA Certificate is used to authenticate the remote DomainParticipants, by verifying that the Identity Certificates are legitimate.
* **Permission CA Certificate** shared by all the DomainParticipants in your secure system. The Permissions CA Certificate is used to verify that Permissions and Governance Files are legitimate.
* **Governance File** shared by all the DomainParticipants in your secure system. The Governance File specifies which domains should be secured and how. It is signed by the Permissions CA.
* **Alice Identity Certificate** signed by the Identity CA. Bob participant will request this certificate to verify the identity of the local participant.
* **Alice Private Key** only known to the local participant. It is needed to complete the authentication process, which provides a way of verifying the identity and setting a shared secret.
* **Alice Permissions File** igned by the Permissions CA. This document specifies what Domains and Partitions the local participant can join and what Topics it can read/write.
* **Bob Identity Certificate** signed by the Identity CA. Alice participant will request this certificate to verify the identity of the local participant.
* **Bob Private Key** only known to the local participant. It is needed to complete the authentication process, which provides a way of verifying the identity and setting a shared secret.
* **Bob Permissions File** igned by the Permissions CA. This document specifies what Domains and Partitions the local participant can join and what Topics it can read/write.

### Build Docker images
To build the docker images for example applications, you will need to have Connext Secure 6.1.0. You can download the Connext evaliation version at https://www.rti.com/free-trial/dds-files. 

```
$ wget https://s3.amazonaws.com/RTI/Bundles/6.1.0/Evaluation/rti_connext_dds-6.1.0-lm-x64Linux4gcc7.3.0.run
```

After you install the downloaded Connext package, you can build the example application. 

```
$ cd patient_monitoring_project
$ make -f makefile_PatientMonitoring_x64Linux4gcc7.3.0
```

Then, you should locate the compiled example binary for Alice and Connext library files to the Docker build directory. 

```
$ cd ./alice
$ cp ../patient_monitoring_project/objs/x64Linux4gcc7.3.0/PatientMonitoring_publisher .
$ cp -rf $NDDSHOME/lib/x64Linux4gcc7.3.0 ./lib
```

Then, you should locate the compiled example binary for Bob and Connext library files to the Docker build directory. 

```
$ cd ./bob
$ cp ../patient_monitoring_project/objs/x64Linux4gcc7.3.0/PatientMonitoring_subscriber .
$ cp -rf $NDDSHOME/lib/x64Linux4gcc7.3.0 ./lib
```

Finally, you can build and push the Docker image for Alice.

```
$ cd ./alice
$ docker build -t kyoungho/dds_secure_pub
$ docker push kyoungho/dds_secure_pub
```

You can build and push the Docker image for Alice.

```
$ cd ./alice
$ docker build -t kyoungho/dds_secure_pub
$ docker push kyoungho/dds_secure_sub
```

### Steps

#### 1. Install cert-manager resources

`$ kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml`

#### 2. Create identity CA and permssions CA

Create identity/permission CAs using the `bootstrapCA.yaml` file:

` kubectl apply -f bootstrapCA.yaml`

#### 3. Create Alice certificate signed by identity CA
This will create a certificate that will be signed by your recently created CA.

`kubectl apply -f alice-cert.yaml `

#### 4. Create Bob certificate signed by identity CA

`kubectl apply -f bob-cert.yaml `

#### 5. Sign the permissions files

Save <pmiPermissionCaCert.pem> and <pmiPermissionCaKey.pem> to a temporary directory

`kubectl get secret permission-ca-root-secret -n sandbox -o jsonpath='{.data.tls\.crt}' | base64 -d > pmiPermissionCaCert.pem`

`kubectl get secret permission-ca-root-secret -n sandbox -o jsonpath='{.data.tls\.key}' | base64 -d > pmiPermissionCaKey.pem`

Then 

Sign the xml permission/governance files using your CA cert.pem

e.g., Sign your xml pmiGovernance.xml

`openssl smime -sign -in pmiGovernance.xml -text -out ./pmiSigned_pmiGovernance.p7s -signer pmiPermissionCaCert.pem -inkey pmiPermissionCaKey.pem`

e.g., Sign your xml pmiPermissionsAlice.xml 

`openssl smime -sign -in pmiPermissionsAlice.xml -text -out ./pmiSigned_pmiPermissionsAlice.p7s -signer pmiPermissionCaCert.pem -inkey pmiPermissionCaKey.pem`

e.g., Sign your xml pmiPermissionsBob.xml 

`openssl smime -sign -in pmiPermissionsBob.xml -text -out ./pmiSigned_pmiPermissionsBob.p7s -signer pmiPermissionCaCert.pem -inkey pmiPermissionCaKey.pem`

The instruction are in the documentation for more details

Now create the secret!

`kubectl create secret generic alice-pmi-signed -n sandbox --from-file=./pmiSigned_pmiGovernance.p7s --from-file=./pmiSigned_pmiPermissionsAlice.p7s`

`kubectl create secret generic bob-pmi-signed -n sandbox --from-file=./pmiSigned_pmiGovernance.p7s --from-file=./pmiSigned_pmiPermissionsBob.p7s`

#### 6. Create pods and attach secrets to the pods

Finally, create pods and mount your certificates ands private keys to the pods.

`kubectl apply -f secret-pod.yaml`

#### 7 Result

You should be able to communicate between two pods using Secure-dds

!! Make sure you are using the correct secret names for your mounted secrets !!

### RESOURCES

A simple guide to protect your secrets: 
https://waswani.medium.com/securing-secrets-in-kubernetes-c78c7bcd433

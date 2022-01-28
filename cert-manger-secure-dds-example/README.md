We will be following closely to the step plan of https://community.rti.com/static/documentation/connext-dds/6.1.0/doc/manuals/connext_dds_secure/getting_started_guide/cpp98/hands_on_4.html#
# Part 1
## 1.0 Preliminary Steps
Install cert-manager resources using the following command

`$ kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml`

and build the docker container for secure_dds

e.g: `docker build . -t secure_dds`

**NOTE**: Example dockerfile is shown in the repo

## 2.0 Create identity CA and Permssions CA
_In this step we will create 1 CA to represent both_


Create a CA using the `bootstrapCa-identity.yaml` file:

` kubectl apply -f bootstrapCA-identity.yaml`

## 3.0 Create Alice certificate signed by CA
This will create a certificate that will be signed by your recently created CA.

`kubectl apply -f alice-cert.yaml `



## 4.0 Sign the permissions files

https://community.rti.com/static/documentation/connext-dds/6.1.0/doc/manuals/connext_dds_secure/getting_started_guide/cpp98/hands_on_4.html#

Save <pmiIdentityCaCert> and <pmiIdentityCaKey> to a temporary directory

`kubectl get secret ca-root-secret -n sandbox -o jsonpath='{.data.tls\.crt}' | base64 -d > pmiIdentityCaCert.pem`

`kubectl get secret ca-root-secret -n sandbox -o jsonpath='{.data.tls\.key}' | base64 -d > pmiIdentityCaKey.pem`


Then 

Sign the xml governance files using your CA cert.pem



e.g. Sign your xml pmiGovernance.xml

`openssl smime -sign -in xml/pmiGovernance.xml -text -out ./pmiSigned_pmiGovernance.p7s -signer pmiIdentityCaCert.pem -inkey pmiIdentityCaKey.pem`

e.g. Sign your xml pmiPermissionsAlice.xml 

`openssl smime -sign -in xml/pmiPermissionsAlice.xml -text -out ./pmiSigned_pmiPermissionsAlice.p7s -signer pmiIdentityCaCert.pem -inkey pmiIdentityCaKey.pem`

The instruction are in the documentation for more details

Now create the secret!

`kubectl create secret generic pmi-signed -n sandbox --from-file=./pmiSigned_pmiGovernance.p7s --from-file=./pmiSigned_pmiPermissionsAlice.p7s`

## 5.0 Create and Attach secrets to pods

Finally, mount your certificates ands private keys to your pods.

`kubectl apply -f secret-pod.yaml`

## 7.0 Change USER_QOS_PROFILES.xml for the correct files


Update USER_QOS_PROFILES.xml to reflect your created files

Example

```
 <qos_profile name="Alice" base_name="BuiltinQosLib::Generic.Security" is_default_qos="true">
            <domain_participant_qos>
                <transport_builtin>
                    <mask>UDPv4</mask>
                </transport_builtin>
                <property>
                    <value>
                        <!-- Certificate Authorities -->
                        <element>
                            <name>dds.sec.auth.identity_ca</name>
                            <value>file:/etc/secret/identity-ca/ca/ca.crt</value>
                        </element>
                        <element>
                            <name>dds.sec.access.permissions_ca</name>
                            <value>file:/etc/secret/identity-ca/ca/ca.crt</value>
                        </element>
                        <!-- Participant Public Certificate and Private Key -->
                        <element>
                            <name>dds.sec.auth.identity_certificate</name>
                            <value>file:/etc/secret/identity-certificate/alice-key/tls.crt</value>
                        </element>
                        <element>
                            <name>dds.sec.auth.private_key</name>
                            <value>file:/etc/secret/private-key/alice-key/tls.key</value>
                        </element>
                        <!-- Signed Governance and Permissions files -->
                        <element>
                            <name>dds.sec.access.governance</name>
                            <value>file:/etc/secret/pmi-signed/pmiSigned_pmiGovernance.p7s</value>
                        </element>
                        <element>
                            <name>dds.sec.access.permissions</name>
                            <value>file:/etc/secret/pmi-signed/pmiSigned_pmiPermissionsAlice.p7s</value>
                        </element>
                    </value>
                </property>
            </domain_participant_qos>
        </qos_profile>

```

## 8.0 Result

You should be able to communicate between two pods using Secure-dds

!! Make sure you are using the correct secret names for your mounted secrets !!

### RESOURCES

A simple guide to protect your secrets: 
https://waswani.medium.com/securing-secrets-in-kubernetes-c78c7bcd433

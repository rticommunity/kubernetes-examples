We will be following closely to the step plan of https://community.rti.com/static/documentation/connext-dds/6.1.0/doc/manuals/connext_dds_secure/getting_started_guide/cpp98/hands_on_4.html#


In this example we will be restricting users to specific resources. This will give an example as to how to restrict 

# Part 1
## Step 1
First, say you are are a kubernetes manager. We created secret-keys for Alice, Bob and Mallory in namespace sandbox

`$ kubectl create secret generic alice-secret -n sandbox`
`$ kubectl create secret generic bob-secret -n sandbox`
`$ kubectl create secret generic mallory-secret -n sandbox`


## Step 2
Now that we have created secrets we would like to give read-only access to the secrets for Alice, Bob and Mallory. However we don't want each of them to see each others secrets.

Do do that we made roles and rolebindings to give certain permissions to each indivitual role

For Example, this is Alices Role and Rolebinding

```
# ALICE RBAC
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    name: Alice
    namespace: sandbox
rules:
  - apiGroups: ["*"]
    resources: ["certificates"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["*"]
    resources: ["secrets"]
    verbs: ["get", "list"]
    resourceNames: ["alice-secret"]
  - apiGroups: ["*"]
    resources: ["events"]
    verbs: ["create"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: Alice-binding
  namespace: sandbox
subjects:
  - kind: User # user can also be used
    name: Alice
roleRef:
  kind: Role
  name: Alice
  apiGroup: rbac.authorization.k8s.io

```

As you can see ALice is able to view her own secret is not able to see others.

Run
`$ kubectl apply -f rbac.yaml`

## Step 3

Let's test is Alice is able to access her secret


`$ kubectl get secrets alice-secret -n sandbox --as Alice`

```
NAME           TYPE     DATA   AGE
alice-secret   Opaque   0      26m
```
She is!

## STEP 4

Let's try to see if alice is able to access Bob's secret

`$ kubectl get secrets bob-secret -n sandbox --as Alice`

```
Error from server (Forbidden): secrets "bob-secret" is forbidden: User "Alice" cannot get resource "secrets" in API group "" in the namespace "sandbox"
```

Let's see if bob is able to view it

`$ kubectl get secrets bob-secret -n sandbox --as Bob`

```
NAME         TYPE     DATA   AGE
bob-secret   Opaque   0      4s
```

Great, bob is the only one able to view it.



### RESOURCES

A simple guide to protect your Secrets using RBAC:


For a userspace base approach follow this link: 

https://jeremievallee.com/2018/05/28/kubernetes-rbac-namespace-user.html



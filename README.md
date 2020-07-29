# prod-eks-cluster

# Prerequisites
 Please make sure following dependencies are met.

- [Install terraform](https://releases.hashicorp.com/terraform/0.12.28/)
- [Configure AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-linux-al2017.html) - make sure you configure AWS CLI with admin previliges 
- [AWS iam authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html) - Amazon EKS uses IAM to provide authentication to your Kubernetes cluster through the AWS IAM Authenticator for Kubernetes.


# Setup
```
$ git clone https://github.com/jengm22/prod-eks-cluster.git

$ cd prod-eks-cluster
```

# Initialize Terraform
```
$ terraform init
```

# Terraform Plan
The terraform plan command is used to create an execution plan. Always a good practice to run it before you apply it to see what resources will be created.

```
$ terraform plan

var.ssh_key_pair
  Enter SSH keypair name that already exist in the AWS account

```

# Apply changes
```
$ terraform apply will apply the execution plan
```

# Configure kubectl
```
**Note:** If AWS CLI and AWS iam authenticator setup correctly, the command below should setup kubeconfig file in ~/.kube/config in your system.

$ aws eks --region <AWS-REGION> update-kubeconfig --name <CLUSTER-NAME>
```

#### Verify EKS cluster
```
$ kubectl get svc
```

**Output:**
```
NAME             TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
svc/kubernetes   ClusterIP   10.100.0.1   <none>        443/TCP   1m
```

Once cluster is verified succesfully, its time to create a configMap to add the worker nodes into the cluster. A configured `output` with this template which will produce the configMap file content that you paste in *`aws-auth.yaml`*.

if you lost the output 'terraform output' will print back the configmap data

#### Add worker node
```
$ kubectl apply -f aws-auth.yaml
```

#### Nodes status - watch them joining the cluster
```
$ kubectl get no -w
```
**Note:-** You should be seeing nodes joining the cluster.

---
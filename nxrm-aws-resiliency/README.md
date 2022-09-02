<!--

    Sonatype Nexus (TM) Open Source Version
    Copyright (c) 2008-present Sonatype, Inc.
    All rights reserved. Includes the third-party code listed at http://links.sonatype.com/products/nexus/oss/attributions.

    This program and the accompanying materials are made available under the terms of the Eclipse Public License Version 1.0,
    which accompanies this distribution and is available at http://www.eclipse.org/legal/epl-v10.html.

    Sonatype Nexus (TM) Professional Version is available from Sonatype, Inc. "Sonatype" and "Sonatype Nexus" are trademarks
    of Sonatype, Inc. Apache Maven is a trademark of the Apache Software Foundation. M2eclipse is a trademark of the
    Eclipse Foundation. All other trademarks are the property of their respective owners.

-->

# Helm Chart for a Resilient Nexus Repository Deployment in AWS

This Helm chart configures the Kubernetes resources that are needed for a resilient Nexus Repository deployment on AWS as described in our documented [single-node cloud resilient deployment example using AWS](https://help.sonatype.com/repomanager3/planning-your-implementation/resiliency-and-high-availability/single-node-cloud-resilient-deployment-example-using-aws).

Use the checklist below to determine if this Helm chart is suitable for your deployment needs.

---

## When to Use This Helm Chart
Use this Helm chart if you are doing any of the following:
- Deploying Nexus Repository Pro to an AWS cloud environment with the desire for automatic failover across Availability Zones (AZs) within a single region
- Planning to configure a single Nexus Repository Pro instance within your Kubernetes/EKS cluster with two or more nodes spread across different AZs within an AWS region
- Using an external PostgreSQL database

> **Note**: A Nexus Repository Pro license is required for our resilient deployment options. Your Nexus Repository Pro license file must be stored externally as mounted from AWS Secrets AWS (required).

---

## Prerequisites for This Chart
In order to set up an environment like the one illustrated above and described in this section, you will need the following:

- Kubernetes 1.19+
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm 3](https://helm.sh/docs/intro/install/)
- A Nexus Repository Pro license
- An AWS account with permissions for accessing the following AWS services:
  - Elastic Kubernetes Service (EKS)
  - Relational Database Service (RDS) for PostgreSQL
  - Application Load Balancer (ALB)
  - CloudWatch
  - Simple Storage Service (S3)
  - Secrets Manager

You will also need to complete the steps below. See the referenced AWS documentation for detailed configuration steps. Also see [our resiliency documentation](https://help.sonatype.com/repomanager3/planning-your-implementation/resiliency-and-high-availability/single-node-cloud-resilient-deployment-example-using-aws) for more details about why these steps are necessary and how each AWS solution functions within a resilient deployment:
1. Configure an EKS cluster - [AWS documentation for managed nodes (i.e., EC2)](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html)
2. Create an Aurora database cluster - [AWS documentation for creating an Aurora database cluster](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.CreateInstance.html)
3. Deploy the AWS Load Balancer Controller (LBC) to your EKS cluster - [AWS documentation for deploying the AWS LBC to your EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)
4. Install AWS Secrets Store CSI drivers - You need to create an IAM service account using the ```eksctl create iamserviceaccount``` command. Before proceeding, read the points below as they contain important required steps to ensure this helm chart will work for you:  <br>
  - **You must include two additional command parameters when running the command**: ```--role-only``` and ```--namespace <nexusrepo namespace>```
    - It is important to include the ```--role-only``` option in the ```eksctl create iamserviceaccount``` command so that the helm chart manages the Kubernetes service account.  <br> 
  - **The namespace you specify to the ```eksctl create iamserviceaccount``` must be the same namespace into which you will deploy the Nexus Repository pod.**  <br>
    - Although the namespace does not exist at this point, you must specify it as part of the command. **Do not create that namespace manually beforehand**; the helm chart will create and manage it. 
    - You should specify this same namespace as the value of ```nexusNs``` in your values.yaml.  <br>
  - Follow the instructions provided in the [AWS Secrets Store CSI drivers documentation](https://github.com/aws/secrets-store-csi-driver-provider-aws/blob/main/README.md) to install the AWS Secrets Store CSI drivers; ensure that you follow the additional instructions in the bullets above when you reach the ```eksctl create iamserviceaccount``` command on that page.
5. Ensure that your EKS nodes are granted CloudWatchFullAccess and CloudWatchAgentServerPolicy IAM policies. This Helm chart will configure Fluentbit for log externalisation to CloudWatch.
  - [AWS documentation for setting up Fluentbit](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy-container-insights-EKS.html)

---

## External-dns

This helm chart uses [external-dns](https://github.com/kubernetes-sigs/external-dns) to create 'A' records in AWS Route 53 for our [Docker subdomain feature](https://help.sonatype.com/repomanager3/nexus-repository-administration/formats/docker-registry/docker-subdomain-connector).

See the ```external-dns.alpha.kubernetes.io/hostname``` annotation in the dockerIngress resource in the values.yaml.

### Permissions for external-dns

Open a terminal that has connectivity to your EKS cluster and run the following commands:
```

cat <<'EOF' >> external-dns-r53-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF


aws iam create-policy --policy-name "AllowExternalDNSUpdates" --policy-document file://external-dns-r53-policy.json


POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`AllowExternalDNSUpdates`].Arn' --output text)


EKS_CLUSTER_NAME=<Your EKS Cluster Name>


aws eks describe-cluster --name $EKS_CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text


eksctl utils associate-iam-oidc-provider --cluster $EKS_CLUSTER_NAME --approve

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
OIDC_PROVIDER=$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text | sed -e 's|^https://||')
```

Note: The value you assign to the 'EXTERNALDNS_NS' variable below should be the same as the one you specify in your values.yaml for namespaces.externaldnsNs
```
EXTERNALDNS_NS=nexus-externaldns

cat <<-EOF > externaldns-trust.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::$ACCOUNT_ID:oidc-provider/$OIDC_PROVIDER"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "$OIDC_PROVIDER:sub": "system:serviceaccount:${EXTERNALDNS_NS}:external-dns",
                    "$OIDC_PROVIDER:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
}
EOF

IRSA_ROLE="nexusrepo-external-dns-irsa-role"
aws iam create-role --role-name $IRSA_ROLE --assume-role-policy-document file://externaldns-trust.json 
aws iam attach-role-policy --role-name $IRSA_ROLE --policy-arn $POLICY_ARN

ROLE_ARN=$(aws iam get-role --role-name $IRSA_ROLE --query Role.Arn --output text)
echo $ROLE_ARN
```

2. Take note of the ROLE_ARN outputted last above and specify it in your values.yaml for serviceAccount.externaldns.role

## Deployment
1. Add the sonatype repo to your helm:
```helm repo add sonatype https://sonatype.github.io/helm3-charts/ ```   
2. Ensure you have updated your values.yaml with appropriate values for your environment.
  - Note that you can specify Ingress annotations via the values.yaml. 
  - If you wish to add [Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/), you can do so via kubectl. See the [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/) for specific commands.
  
3. Install the chart using the following:
  
```helm install nxrm sonatype/nxrm-aws-resiliency -f values.yaml```
  
4. Get the Nexus Repository link using the following:
  
```kubectl get ingresses -n nexusrepo```

---

## Health Check
You can use the following commands to perform various health checks:
  
See a list of releases:
  
  ```helm list```
  
 Check pods using the following:
  
  ```kubectl get pods -n nexusrepo```
  
Check the Nexus Repository logs with the following:
  
  ```kubectl logs <pod_name> -n nexusrepo nxrm-app```
  
Check if the pod is OK by using the following; you shouldn't see any error/warning messages:
  
  ```kubectl describe pod <pod_name> -n nexusrepo```
  
Check if ingress is OK using the following:
  
  ```kubectl describe ingress <ingress_name> -n nexusrepo```
  
Check that the Fluent Bit pod is sending events to CloudWatch using the following:

  ```kubectl logs -n amazon-cloudwatch <fluent-bit pod id>```
  
If the above returns without error, then check CloudWatch for the ```/aws/containerinsights/<eks cluster name>/nexus-logs``` log group, which should contain four log streams.

---

## Uninstall
To uninstall the deployment, use the following:
  
  ```helm uninstall nxrm```
  
After removing the deployment, ensure that the namespace is deleted and that Nexus Repository is not listed when using the following:
  
  ```helm list```

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

## Deployment
1. Add the sonatype repo to your helm:
```helm repo add sonatype https://sonatype.github.io/helm3-charts/ ```   
2. Ensure you have updated your values.yaml with appropriate values for your environment.
3. Install the chart using the following:
  
```helm install nxrm sonatype/nxrm-aws-resiliency -f values.yaml```
  
3. Get the Nexus Repository link using the following:
  
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

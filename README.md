#
# Copyright (c) 2008-present Sonatype, Inc.
#
# All rights reserved. Includes the third-party code listed at http://links.sonatype.com/products/nexus/pro/attributions
# Sonatype and Sonatype Nexus are trademarks of Sonatype, Inc. Apache Maven is a trademark of the Apache Foundation.
# M2Eclipse is a trademark of the Eclipse Foundation. All other trademarks are the property of their respective owners.
#

## Helm Charts for Sonatype Nexus Repository Manager 3

We provide Helm charts for two different deployment scenarios:

See the [AWS Single-Instance Resiliency Chart](https://github.com/sonatype/nxrm3-helm-repository/tree/main/aws-single-instance-resiliency) if you are doing the following:
* Deploying Nexus Repository Pro to an AWS cloud environment with the desire for automatic failover across Availability Zones (AZs) within a single region
* Planning to configure a single Nexus Repository Pro instance within your Kubernetes/EKS cluster with two or more nodes spread across different AZs within an AWS region
* Using an external PostgreSQL database (required)

See the [Single-Instance OSS/Pro Kubernetes Chart](https://github.com/sonatype/nxrm3-helm-repository/tree/main/single-inst-oss-pro-kubernetes) if you are doing the following:
* Using embedded OrientDB (required)
* Deploying either Nexus Repository Pro or OSS to an on-premises environment with bare metal/VM server (Node)
* Deploying a single Nexus Repository instance within a Kubernetes cluster that has a single Node configured

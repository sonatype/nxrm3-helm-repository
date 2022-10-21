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
# ⚠️ Archive Notice

As of October 24, 2023, we will no longer update or support the [Single-Instance OSS/Pro Kubernetes Chart](https://github.com/sonatype/nxrm3-helm-repository/tree/main/nexus-repository-manager).

## Helm Charts for Sonatype Nexus Repository Manager 3

We provide Helm charts for two different deployment scenarios:

See the [AWS Single-Instance Resiliency Chart](https://github.com/sonatype/nxrm3-helm-repository/tree/main/nxrm-aws-resiliency) if you are doing the following:
* Deploying Nexus Repository Pro to an AWS cloud environment with the desire for automatic failover across Availability Zones (AZs) within a single region
* Planning to configure a single Nexus Repository Pro instance within your Kubernetes/EKS cluster with two or more nodes spread across different AZs within an AWS region
* Using an external PostgreSQL database (required)

See the [Single-Instance OSS/Pro Kubernetes Chart](https://github.com/sonatype/nxrm3-helm-repository/tree/main/nexus-repository-manager) if you are doing the following:
* Using embedded OrientDB (required)
* Deploying either Nexus Repository Pro or OSS to an on-premises environment with bare metal/VM server (Node)
* Deploying a single Nexus Repository instance within a Kubernetes cluster that has a single Node configured

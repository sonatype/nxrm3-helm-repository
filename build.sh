#!/bin/sh
#
# Copyright (c) 2008-present Sonatype, Inc.
#
# All rights reserved. Includes the third-party code listed at http://links.sonatype.com/products/nexus/pro/attributions
# Sonatype and Sonatype Nexus are trademarks of Sonatype, Inc. Apache Maven is a trademark of the Apache Foundation.
# M2Eclipse is a trademark of the Eclipse Foundation. All other trademarks are the property of their respective owners.
#

helm plugin install https://github.com/quintush/helm-unittest

set -e

# lint yaml of charts
helm lint ./nxrm-aws-resiliency
helm lint ./nexus-repository-manager

# unit test
(cd ./nxrm-aws-resiliency; helm unittest -3 -t junit -o test-output.xml .)
(cd ./nexus-repository-manager; helm unittest -3 -t junit -o test-output.xml .)

# package the charts into tgz archives
helm package ./nxrm-aws-resiliency --destination docs
helm package ./nexus-repository-manager --destination docs

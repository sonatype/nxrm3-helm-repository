#!/bin/sh
#
# Sonatype Nexus (TM) Open Source Version
# Copyright (c) 2008-present Sonatype, Inc.
# All rights reserved. Includes the third-party code listed at http://links.sonatype.com/products/nexus/oss/attributions.
#
# This program and the accompanying materials are made available under the terms of the Eclipse Public License Version 1.0,
# which accompanies this distribution and is available at http://www.eclipse.org/legal/epl-v10.html.
#
# Sonatype Nexus (TM) Professional Version is available from Sonatype, Inc. "Sonatype" and "Sonatype Nexus" are trademarks
# of Sonatype, Inc. Apache Maven is a trademark of the Apache Software Foundation. M2eclipse is a trademark of the
# Eclipse Foundation. All other trademarks are the property of their respective owners.
#

helm plugin install --version "0.2.11" https://github.com/quintush/helm-unittest

set -e

# lint yaml of charts
helm lint ./nxrm-aws-resiliency

# unit test
(cd ./nxrm-aws-resiliency; helm unittest -3 -t junit -o test-output.xml .)

# package the charts into tgz archives
helm package ./nxrm-aws-resiliency --destination docs

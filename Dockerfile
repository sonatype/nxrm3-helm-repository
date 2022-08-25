#
# Copyright (c) 2008-present Sonatype, Inc.
#
# All rights reserved. Includes the third-party code listed at http://links.sonatype.com/products/nexus/pro/attributions
# Sonatype and Sonatype Nexus are trademarks of Sonatype, Inc. Apache Maven is a trademark of the Apache Foundation.
# M2Eclipse is a trademark of the Eclipse Foundation. All other trademarks are the property of their respective owners.
#

FROM docker-all.repo.sonatype.com/alpine/helm:3.9.3

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

RUN mkdir /.local /.cache && chmod 777 /.local /.cache


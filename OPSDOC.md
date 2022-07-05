<!--
Copyright (c) 2019-present Sonatype, Inc. All rights reserved.
Includes the third-party code listed at http://links.sonatype.com/products/clm/attributions.
"Sonatype" is a trademark of Sonatype, Inc.
-->

## Overview
Overview of the service: what is it, why do we have it, who are the primary
contacts, how to report bugs, links to design docs and other relevant
information.

### Public Facing Endpoints
The URLs (or IPs) and ports used by the service and what they are used for
(ALB? SSH? FTP?) and notes about any certificates and their location.

## Monitoring

Monitoring dashboards / logging / introspection & obseverbility info.

### Runbooks

A list of every alert your monitoring system may generate for this service and
a step-by-step "what do to when..." for each of them.

###  SLO
Service Level Objectives in a succinct format: a target value or range of
values for a service level that is measured by an SLI. A natural structure for
SLOs is thus SLI ≤ target, or lower bound ≤ SLI ≤ upper bound. For example, we
might decide that we will return Shakespeare search results "quickly," adopting
an SLO that our average search request latency should be less than 100
milliseconds.

For more detailed information, please check out the Service Level Objectives
doc. If you're still unsure of what your SLOs should be, please reach out to
the SREs at #ops-sre-chat. 

Optionally but recommended, have a section of monitoring and dashboards for SLO
tracking (see the auth-service OpsDoc for examples of dashboards).

## Build

How to build the software that makes the service. Where to download it from,
where the source code repository is, steps for building and making a package or
other distribution mechanisms. If it is software that you modify in any way
(open source project you contribute to or a local project) include instructions
for how a new developer gets started. Ideally the end result is a package that
can be copied to other machines for installation.

## Deploy

How to deploy the service. How to build something from scratch: RAM/disk
requirements, OS version and configuration, what packages to install, and so
on. If this is automated with a configuration management tool like ansible/etc,
then say so.

## Common Tasks

Step-by-step instructions for common things like provisioning
(add/change/delete), common problems and their solutions, and so on.

## DR
Where are backups of data stored?  What are disaster / data recovery
procedures?



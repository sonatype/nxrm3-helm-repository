/*
 * Copyright (c) 2008-present Sonatype, Inc.
 *
 * All rights reserved. Includes the third-party code listed at http://links.sonatype.com/products/nexus/pro/attributions
 * Sonatype and Sonatype Nexus are trademarks of Sonatype, Inc. Apache Maven is a trademark of the Apache Foundation.
 * M2Eclipse is a trademark of the Eclipse Foundation. All other trademarks are the property of their respective owners.
 */
@Library(['private-pipeline-library', 'jenkins-shared', 'nxrm-jenkins-shared']) _

dockerizedBuildPipeline(
  prepare: {
    githubStatusUpdate('pending')
  },
  buildAndTest: {
    sh './build.sh'
  },
  skipVulnerabilityScan: true,
  archiveArtifacts: 'docs/*',
  testResults: ['**/test-output.xml'],
  onSuccess: {
    nxrmBuildNotifications(currentBuild, env)
  },
  onFailure: {
    nxrmBuildNotifications(currentBuild, env)
  }
)

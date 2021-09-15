#!groovy
// -*- mode: groovy -*-

build('swag-anapi-v2', 'docker-host') {
    checkoutRepo()
    loadBuildUtils('build_utils')

    def pipeDefault
    def withWsCache
    def gitUtils
    runStage('load pipeline') {
        env.JENKINS_LIB = "build_utils/jenkins_lib"
        pipeDefault = load("${env.JENKINS_LIB}/pipeJavaLibInsideDocker.groovy")
        withWsCache = load("${env.JENKINS_LIB}/withWsCache.groovy")
        gitUtils = load("${env.JENKINS_LIB}/gitUtils.groovy")
    }

    pipeDefault() {

        runStage('install-deps') {
            withWsCache("node_modules") {
                sh 'make wc_install'
            }
        }

        runStage('validate-spec') {
            sh 'make wc_validate'
        }

        runStage('bundle') {
            sh 'make wc_build'
        }

        // Java
        runStage('build java client & server') {
            withCredentials([[$class: 'FileBinding', credentialsId: 'java-maven-settings.xml', variable: 'SETTINGS_XML']]) {
                if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME.startsWith('epic/')) {
                    sh 'make SETTINGS_XML=${SETTINGS_XML} BRANCH_NAME=${BRANCH_NAME} REPO_PUBLIC=${REPO_PUBLIC} java.openapi.deploy_client'
                    sh 'make SETTINGS_XML=${SETTINGS_XML} BRANCH_NAME=${BRANCH_NAME} REPO_PUBLIC=${REPO_PUBLIC} java.openapi.deploy_server'
                } else {
                    sh 'make SETTINGS_XML=${SETTINGS_XML} BRANCH_NAME=${BRANCH_NAME} java.openapi.compile_client'
                    sh 'make SETTINGS_XML=${SETTINGS_XML} BRANCH_NAME=${BRANCH_NAME} java.openapi.compile_server'
                }
            }
        }

        // Release
        if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME.startsWith('epic/')) {
            runStage('publish release bundle') {
                dir("web_deploy") {
                    gitUtils.push(commitMsg: "Generated from commit: $COMMIT_ID \n\non $BRANCH_NAME in $RBK_REPO_URL\n\nChanges:\n$COMMIT_MSG",
                            files: "*", branch: "release/$BRANCH_NAME", orphan: true)
                }
            }
        }

    }
}

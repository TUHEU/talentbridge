// Jenkinsfile — Talent Bridge Frontend
// Repo: talent_bridge_frontend
// ============================================================
pipeline {
    agent { label 'flutter' }

    options {
        timeout(time: 40, unit: 'MINUTES')
        timestamps()
        ansiColor('xterm')
        buildDiscarder(logRotator(numToKeepStr: '15', artifactNumToKeepStr: '5'))
        disableConcurrentBuilds(abortPrevious: true)
    }

    environment {
        FLUTTER_VERSION = '3.24.0'
        APP_NAME        = 'talent-bridge'
        SLACK_CH        = '#talent-bridge-frontend'
    }

    parameters {
        choice(
            name: 'BUILD_TARGET',
            choices: ['auto', 'debug-apk', 'release-apk', 'web', 'all'],
            description: 'What to build. auto = debug on PRs, release on main.'
        )
        string(
            name: 'API_BASE_URL',
            defaultValue: '',
            description: 'Override API base URL (leave blank to use credentials)'
        )
    }

    stages {

        // ────────────────────────────────────────────────────
        // STAGE 1 — Setup
        // ────────────────────────────────────────────────────
        stage('Setup') {
            steps {
                sh '''
                    flutter --version
                    flutter pub get
                    dart pub global activate junitreport
                '''
            }
        }

        // ────────────────────────────────────────────────────
        // STAGE 2 — Code Quality (parallel)
        // ────────────────────────────────────────────────────
        stage('Code Quality') {
            parallel {
                stage('Format Check') {
                    steps {
                        sh 'dart format --output=none --set-exit-if-changed lib/ test/'
                    }
                }
                stage('Static Analysis') {
                    steps {
                        sh 'flutter analyze --no-fatal-infos 2>&1 | tee analyze-report.txt'
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'analyze-report.txt',
                                             allowEmptyArchive: true
                        }
                    }
                }
            }
        }

        // ────────────────────────────────────────────────────
        // STAGE 3 — Tests (parallel suites)
        // ────────────────────────────────────────────────────
        stage('Tests') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh '''
                            flutter test test/unit/ \
                                --machine | tojunit \
                                --output unit-results.xml || \
                            flutter test test/unit/ \
                                --reporter=compact
                        '''
                    }
                    post {
                        always {
                            junit allowEmptyResults: true, testResults: 'unit-results.xml'
                        }
                    }
                }

                stage('Widget Tests') {
                    steps {
                        sh '''
                            flutter test test/widget/ \
                                --machine | tojunit \
                                --output widget-results.xml || \
                            flutter test test/widget/ \
                                --reporter=compact
                        '''
                    }
                    post {
                        always {
                            junit allowEmptyResults: true, testResults: 'widget-results.xml'
                        }
                    }
                }

                stage('Integration Tests') {
                    steps {
                        sh '''
                            flutter test test/integration/ \
                                --machine | tojunit \
                                --output integration-results.xml || \
                            flutter test test/integration/ \
                                --reporter=compact
                        '''
                    }
                    post {
                        always {
                            junit allowEmptyResults: true,
                                  testResults: 'integration-results.xml'
                        }
                    }
                }
            }
        }

        // ────────────────────────────────────────────────────
        // STAGE 4 — Coverage
        // ────────────────────────────────────────────────────
        stage('Coverage Report') {
            steps {
                sh 'flutter test --coverage --reporter=compact'
            }
            post {
                always {
                    publishHTML([
                        allowMissing:          true,
                        alwaysLinkToLastBuild: true,
                        keepAll:               true,
                        reportDir:             'coverage',
                        reportFiles:           'lcov.info',
                        reportName:            'Flutter Coverage Report'
                    ])
                }
            }
        }

        // ────────────────────────────────────────────────────
        // STAGE 5 — Build (parallel APK + Web)
        // ────────────────────────────────────────────────────
        stage('Build') {
            parallel {

                stage('Android Debug APK') {
                    when {
                        anyOf {
                            not { branch 'main' }
                            expression { params.BUILD_TARGET in ['debug-apk', 'all'] }
                        }
                    }
                    steps {
                        withCredentials([string(credentialsId: 'api-base-url', variable: 'API_URL')]) {
                            sh '''
                                flutter build apk --debug \
                                    --dart-define=BASE_URL=${API_URL}
                            '''
                        }
                    }
                    post {
                        success {
                            archiveArtifacts(
                                artifacts:   'build/app/outputs/flutter-apk/app-debug.apk',
                                fingerprint: true
                            )
                        }
                    }
                }

                stage('Android Release APK') {
                    when {
                        anyOf {
                            branch 'main'
                            expression { params.BUILD_TARGET in ['release-apk', 'all'] }
                        }
                    }
                    steps {
                        withCredentials([
                            file(credentialsId:   'android-keystore',         variable: 'KEYSTORE'),
                            string(credentialsId: 'android-key-alias',        variable: 'KEY_ALIAS'),
                            string(credentialsId: 'android-key-password',     variable: 'KEY_PASS'),
                            string(credentialsId: 'android-store-password',   variable: 'STORE_PASS'),
                            string(credentialsId: 'api-base-url',             variable: 'API_URL'),
                        ]) {
                            sh '''
                                cp $KEYSTORE android/app/keystore.jks
                                flutter build apk --release \
                                    --dart-define=BASE_URL=${API_URL} \
                                    --obfuscate \
                                    --split-debug-info=build/debug-info
                            '''
                        }
                    }
                    post {
                        success {
                            archiveArtifacts(
                                artifacts:   'build/app/outputs/flutter-apk/app-release.apk',
                                fingerprint: true
                            )
                        }
                    }
                }

                stage('Flutter Web') {
                    when {
                        anyOf {
                            branch 'main'
                            expression { params.BUILD_TARGET in ['web', 'all'] }
                        }
                    }
                    steps {
                        withCredentials([string(credentialsId: 'api-base-url', variable: 'API_URL')]) {
                            sh '''
                                flutter build web --release \
                                    --dart-define=BASE_URL=${API_URL} \
                                    --web-renderer canvaskit
                            '''
                        }
                    }
                    post {
                        success {
                            zip(
                                zipFile: 'talent-bridge-web.zip',
                                dir:     'build/web',
                                archive: true
                            )
                        }
                    }
                }
            }
        }

        // ────────────────────────────────────────────────────
        // STAGE 6 — App Bundle (Play Store, main only)
        // ────────────────────────────────────────────────────
        stage('App Bundle') {
            when { branch 'main' }
            steps {
                withCredentials([
                    file(credentialsId:   'android-keystore',       variable: 'KEYSTORE'),
                    string(credentialsId: 'android-key-alias',      variable: 'KEY_ALIAS'),
                    string(credentialsId: 'android-key-password',   variable: 'KEY_PASS'),
                    string(credentialsId: 'android-store-password', variable: 'STORE_PASS'),
                    string(credentialsId: 'api-base-url',           variable: 'API_URL'),
                ]) {
                    sh '''
                        cp $KEYSTORE android/app/keystore.jks
                        flutter build appbundle --release \
                            --dart-define=BASE_URL=${API_URL} \
                            --obfuscate \
                            --split-debug-info=build/debug-info
                    '''
                }
            }
            post {
                success {
                    archiveArtifacts(
                        artifacts:   'build/app/outputs/bundle/release/app-release.aab',
                        fingerprint: true
                    )
                }
            }
        }
    }

    post {
        success {
            script {
                def apk = env.BRANCH_NAME == 'main' ? 'release APK + AAB' : 'debug APK'
                slackSend(
                    channel: env.SLACK_CH, color: 'good',
                    message: """:white_check_mark: *Flutter Frontend* build #${env.BUILD_NUMBER} passed
Branch: `${env.BRANCH_NAME}` | Artifacts: ${apk} + Web
<${env.BUILD_URL}|View Build>"""
                )
            }
        }
        failure {
            slackSend(
                channel: env.SLACK_CH, color: 'danger',
                message: ":x: *Flutter Frontend* build #${env.BUILD_NUMBER} FAILED on `${env.BRANCH_NAME}` | <${env.BUILD_URL}|View>"
            )
            emailext(
                subject: "[FAIL] Talent Bridge Frontend #${env.BUILD_NUMBER}",
                body:    "Flutter build failed: ${env.BUILD_URL}",
                to:      'fahdil@example.com'
            )
        }
        always {
            cleanWs(cleanWhenNotBuilt: false, cleanWhenFailure: false)
        }
    }
}

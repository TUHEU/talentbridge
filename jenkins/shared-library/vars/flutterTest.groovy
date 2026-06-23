// jenkins/shared-library/vars/flutterTest.groovy
// Run flutter tests for a specific suite with JUnit reporting
def call(Map config = [:]) {
    def suite    = config.get('suite',   'test/')
    def xmlFile  = config.get('xmlFile', 'test-results.xml')
    def coverage = config.get('coverage', false)

    sh """
        flutter test ${suite} \
            --reporter=compact \
            ${coverage ? '--coverage' : ''} \
            2>&1 | tee flutter-test-output.txt
    """

    junit allowEmptyResults: true, testResults: xmlFile
}

//  a JenkinsFile to build iqtree
// paramters
//  1. git branch
// 2. git url


properties([
    parameters([
        booleanParam(defaultValue: false, description: 'Re-build CMAPLE?', name: 'BUILD_CMAPLE'),
        string(name: 'CMAPLE_BRANCH', defaultValue: 'main', description: 'Branch to build CMAPLE'),
        booleanParam(defaultValue: false, description: 'Download testing data?', name: 'DOWNLOAD_DATA'),
        booleanParam(defaultValue: false, description: 'Infer ML trees?', name: 'INFER_TREE'),
        string(name: 'MODEL', defaultValue: 'GTR', description: 'Substitution model'),
        booleanParam(defaultValue: false, description: 'Blengths fixed?', name: 'BLENGTHS_FIXED'),
        booleanParam(defaultValue: false, description: 'Do not reroot?', name: 'NOT_REROOT'),
        booleanParam(defaultValue: true, description: 'Compute supports for branches with a length of zero?', name: 'ZERO_LENGTH_BRANCHES'),
        booleanParam(defaultValue: false, description: 'Output alternative SPRs?', name: 'OUT_ALT_SPR'),
        booleanParam(defaultValue: false, description: 'Use CIBIV cluster?', name: 'USE_CIBIV'),
    ])
])
pipeline {
    agent any
    environment {
        NCI_ALIAS = "gadi"
        SSH_COMP_NODE = " "
        WORKING_DIR = "/scratch/dx61/tl8625/cmaple/ci-cd"
        DATA_DIR = "${WORKING_DIR}/data"
        ALN_DIR = "${DATA_DIR}/aln"
        TREE_DIR = "${DATA_DIR}/tree"
        SCRIPTS_DIR = "${WORKING_DIR}/scripts"
        BUILD_DIR = "${WORKING_DIR}/builds/build-default"
        CMAPLE_PATH = "${BUILD_DIR}/cmaple"
        ML_TREE_PREFIX = "ML_tree_"
        CMAPLE_SPRTA_TREE_PREFIX = "SPRTA_CMAPLE_tree_"
    }
    stages {
        stage('Init variables') {
            steps {
                script {
                    if (params.USE_CIBIV) {
                        NCI_ALIAS = "eingang"
                        SSH_COMP_NODE = " ssh -tt cox "
                        WORKING_DIR = "/project/AliSim/cmaple"
                        
                        DATA_DIR = "${WORKING_DIR}/data"
                        ALN_DIR = "${DATA_DIR}/aln"
                        TREE_DIR = "${DATA_DIR}/tree"
                        SCRIPTS_DIR = "${WORKING_DIR}/scripts"
                        BUILD_DIR = "${WORKING_DIR}/builds/build-default"
                        CMAPLE_PATH = "${BUILD_DIR}/cmaple"
                    }
                }
            }
        }
        stage("Build CMAPLE") {
            steps {
                script {
                    if (params.BUILD_CMAPLE) {
                        echo 'Building CMAPLE'
                        // trigger jenkins cmaple-build
                        build job: 'cmaple-build', parameters: [string(name: 'BRANCH', value: CMAPLE_BRANCH),
                        booleanParam(name: 'USE_CIBIV', value: USE_CIBIV),]

                    }
                    else {
                        echo 'Skip building CMAPLE'
                    }
                }
            }
        }
        stage("Download testing data & Infer ML trees") {
            steps {
                script {
                    if (params.DOWNLOAD_DATA || params.INFER_TREE) {
                        // trigger jenkins cmaple-tree-inference
                        build job: 'cmaple-tree-inference', parameters: [booleanParam(name: 'DOWNLOAD_DATA', value: DOWNLOAD_DATA),
                        booleanParam(name: 'INFER_TREE', value: INFER_TREE),
                        string(name: 'MODEL', value: MODEL),
                        booleanParam(name: 'USE_CIBIV', value: USE_CIBIV),
                        ]
                    }
                    else {
                        echo 'Skip inferring ML trees'
                    }
                }
            }
        }
        stage('Compute SPRTA by CMAPLE') {
            steps {
                script {
                    sh """
                        ssh -tt ${NCI_ALIAS} << EOF
                        
                        mkdir -p ${SCRIPTS_DIR}
                        exit
                        EOF
                        """
                    sh "scp -r scripts/* ${NCI_ALIAS}:${SCRIPTS_DIR}"
                    sh """
                        ssh -tt ${NCI_ALIAS} ${SSH_COMP_NODE}<< EOF

                                              
                        echo "Compute SPRTA by CMAPLE"
                        sh ${SCRIPTS_DIR}/cmaple_compute_sprta.sh ${ALN_DIR} ${TREE_DIR} ${CMAPLE_PATH} ${ML_TREE_PREFIX} ${CMAPLE_SPRTA_TREE_PREFIX} ${params.MODEL} ${params.BLENGTHS_FIXED} ${params.NOT_REROOT} ${params.ZERO_LENGTH_BRANCHES} ${params.OUT_ALT_SPR}
                        
                       
                        exit
                        EOF
                        """
                }
            }
        }
        stage ('Verify') {
            steps {
                script {
                    sh """
                        ssh -tt ${NCI_ALIAS} << EOF
                        cd  ${WORKING_DIR}
                        echo "Files in ${WORKING_DIR}"
                        ls -ila ${WORKING_DIR}
                        echo "Files in ${ALN_DIR}"
                        ls -ila ${ALN_DIR}
                        echo "Files in ${TREE_DIR}"
                        ls -ila ${TREE_DIR}
                        exit
                        EOF
                        """
                }
            }
        }


    }
    post {
        always {
            echo 'Cleaning up workspace'
            cleanWs()
        }
    }
}

def void cleanWs() {
    // ssh to NCI_ALIAS and remove the working directory
    // sh "ssh -tt ${NCI_ALIAS} 'rm -rf ${REPO_DIR} ${BUILD_SCRIPTS}'"
}
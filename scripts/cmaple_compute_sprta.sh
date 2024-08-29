#!bin/bash

###### handle arguments ######

ALN_DIR=$1 # aln dir
TREE_DIR=$2 # tree dir
CMAPLE_PATH=$3 # path to CMAPLE executable
CMAPLE_PARAMS=$4 # CMAPLE params
ML_TREE_PREFIX=$5 # The prefix of ML trees
CMAPLE_SPRTA_TREE_PREFIX=$6 # The prefix of trees with SPRTA computed by CMAPLE


### pre steps #####



############

for aln_path in "${ALN_DIR}"/*.maple; do
	aln=$(basename "$aln_path")
    echo "Compute SPRTA for the tree ${ML_TREE_PREFIX}${aln}.treefile inferred from ${aln}"
    cd ${ALN_DIR} && ${CMAPLE_PATH} -aln ${aln} -t ${TREE_DIR}/${ML_TREE_PREFIX}${aln}.treefile -pre ${CMAPLE_SPRTA_TREE_PREFIX}${aln} ${CMAPLE_PARAMS}
done
                        
echo "Moving the trees to ${TREE_DIR}"
mkdir -p ${TREE_DIR}
mv ${ALN_DIR}/${CMAPLE_SPRTA_TREE_PREFIX}*treefile ${TREE_DIR}
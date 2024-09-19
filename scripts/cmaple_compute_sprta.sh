#!bin/bash

###### handle arguments ######

ALN_DIR=$1 # aln dir
TREE_DIR=$2 # tree dir
CMAPLE_PATH=$3 # path to CMAPLE executable
ML_TREE_PREFIX=$4 # The prefix of ML trees
CMAPLE_SPRTA_TREE_PREFIX=$5 # The prefix of trees with SPRTA computed by CMAPLE
MODEL=$6 # Substitution model
BLENGTHS_FIXED=$7 # keep blengths fixed or not
ZERO_LENGTH_BRANCHES=$8 # compute supports for branches with a length of zero
CMAPLE_PARAMS="-sprta -overwrite -search FAST" # CMAPLE params

BL_FIXED_OPT=""
if [ "${BLENGTHS_FIXED}" = true ]; then
  BL_FIXED_OPT=" -blfix"
fi

ZERO_LENGTH_BRANCHES_OPT=""
if [ "${ZERO_LENGTH_BRANCHES}" = true ]; then
  ZERO_LENGTH_BRANCHES_OPT=" --zero-branch-supp"
fi

### pre steps #####



############

for aln_path in "${ALN_DIR}"/*.maple; do
	aln=$(basename "$aln_path")
    echo "Compute SPRTA for the tree ${ML_TREE_PREFIX}${aln}.treefile inferred from ${aln}"
    
    echo "cd ${ALN_DIR} && ${CMAPLE_PATH} -aln ${aln} -t ${TREE_DIR}/${ML_TREE_PREFIX}${aln}.treefile -pre ${CMAPLE_SPRTA_TREE_PREFIX}${aln} ${CMAPLE_PARAMS} ${BL_FIXED_OPT} ${ZERO_LENGTH_BRANCHES_OPT}"
    cd ${ALN_DIR} && ${CMAPLE_PATH} -aln ${aln} -t ${TREE_DIR}/${ML_TREE_PREFIX}${aln}.treefile -m ${MODEL} -pre ${CMAPLE_SPRTA_TREE_PREFIX}${aln} ${CMAPLE_PARAMS} ${BL_FIXED_OPT} ${ZERO_LENGTH_BRANCHES_OPT}
done
                        
echo "Moving the trees to ${TREE_DIR}"
mkdir -p ${TREE_DIR}
# remove old results
rm -f ${TREE_DIR}/${CMAPLE_SPRTA_TREE_PREFIX}*treefile*
# copy new results
mv ${ALN_DIR}/${CMAPLE_SPRTA_TREE_PREFIX}*treefile.nexus ${TREE_DIR}
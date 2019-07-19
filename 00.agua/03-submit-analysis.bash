WATER_MODELS="spc spce tip3p tip4p tip4pew tip5p opc"

for MODEL in ${WATER_MODELS} ; do

    sed s/MODEL/${MODEL}/ TEMPLATE_ANALYSIS.SGE | qsub

done

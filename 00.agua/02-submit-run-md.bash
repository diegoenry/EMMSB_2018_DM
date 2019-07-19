#WATER_MODELS="spc spce tip3p tip4p tip4pew tip5p opc"
WATER_MODELS="tip4pew"

for MODEL in ${WATER_MODELS} ; do

    sed s/MODEL/${MODEL}/ TEMPLATE.SGE | qsub

done

WATER_MODELS="spc spce tip3p tip4p tip5p opc opc3"

for MODEL in ${WATER_MODELS} ; do

    sed s/MODEL/${MODEL}/ TEMPLATE.SGE | qsub

done

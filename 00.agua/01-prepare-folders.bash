# Config ----------------------------------------------------------------------
WATER_MODELS="spc spce tip3p tip4p tip5p opc opc3"
base_dir=$PWD

# Source GROMACS
source /home/dgomes/software/gmx2019.3/bin/GMXRC.bash

# Functions -------------------------------------------------------------------
create_folder() {
if [ ! -d ${folder} ] ; then
       mkdir -p ${folder}
fi       
}

build_box() {
cd ${folder}

# Write "fake" topology file
cat << EOF >| topol.top
#include "oplsaa.ff/forcefield.itp"
#include "oplsaa.ff/${model}.itp"

[ System ]
${model}

[ Molecules ]
EOF

# Define template water box
case ${model} in
"spc"|"spce"|"tip3p"|"opc")  
    template_box="spc216"
	;;
"tip4p|opc3") 
	template_box="tip4p"

	;;
"tip5p") 
	template_box="tip5p"
	;;
esac

# actually generate box
gmx_d solvate -cs ${template_box} -p topol.top -o box.gro -box 3 3 3

}


# Program ---------------------------------------------------------------------
for model in ${WATER_MODELS} ; do
    folder=${base_dir}/${model}
    create_folder
    build_box
done




# Config ----------------------------------------------------------------------
WATER_MODELS="spc spce tip3p tip4p tip5p opc opc3"
protocol="min min2 eql eql2 prd"

base_dir=${PWD}

# Source GROMACS
source /home/dgomes/software/gmx2019.3/bin/GMXRC.bash

# Functions -------------------------------------------------------------------
run_mdrun() {
	
	case ${run} in 
	"min")
		prev="box"
		extra_flag=""
	;;
	"min2"|"eql")
		extra_flag="-t ${prev}.trr"
	;;
	*)
		extra_flag="-t ${prev}.cpt"
	
	esac

	    gmx grompp -maxwarn 1 -v -f ${base_dir}/mdp/${run}.mdp -c ${prev}.gro -p topol.top -o ${run}.tpr ${extra_flag}
	    gmx mdrun -deffnm ${run} &> ${run}.job

}

run_simulation() {
	
	for run in ${protocol} ; do
	    run_mdrun
	    prev=${run}
	done

}

# Program ---------------------------------------------------------------------
for model in ${WATER_MODELS} ; do

    folder=${base_dir}/${model}

	cd ${folder}

    echo $PWD
    run_simulation

done




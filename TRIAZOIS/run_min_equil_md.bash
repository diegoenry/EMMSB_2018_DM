#/bin/bash

# Ativa o AMBER
source ~/software/amber18/amber.sh


run_dir=${PWD}                # Pasta aonde estou rodando minhas coisas
init="${run_dir}/ionized"     # Nome da topologia (system.prmtop)
prev="${run_dir}/ionized"     # Nome inicial para os arquivos (system.rst7, system.prmtop ...)

# Função para rodar o sander
run_sander() {
mpirun -np 8 sander.MPI -O \
  -i ${run_dir}/amber_inputs/${input}.in \
  -o ${run}.out \
  -r ${run}.rst7 \
-inf ${run}.mdinfo \
  -p ${init}.prmtop \
  -c ${prev}.rst7 \
-ref ${prev}.rst7
}

run_pmemd() {
mpirun -n 8 pmemd.MPI -O \
  -i ${run_dir}/amber_inputs/${input}.in \
  -o ${run}.out \
  -r ${run}.rst7 \
-inf ${run}.mdinfo \
  -p ${init}.prmtop \
  -c ${prev}.rst7 \
-ref ${prev}.rst7 
}


run_pmemd_cuda() {
pmemd.cuda -O \
  -i ${run_dir}/amber_inputs/${input}.in \
  -o ${run}.out \
  -r ${run}.rst7 \
-inf ${run}.mdinfo \
  -p ${init}.prmtop \
  -c ${prev}.rst7 \
-ref ${prev}.rst7 
}


# Verifica a existencia dos arquivos de entrada
check_files() {

# No TLEAP nos criamos o "system.rst7", mas ao longo do projeto o ${prev} é ".rst7"
if [ ${run_type} == "minimimization" ] ; then
    file_list="${run_dir}/amber_inputs/${input}.in ${prev}.rst7 ${init}.prmtop"
else
    file_list="${run_dir}/amber_inputs/${input}.in ${prev}.rst7 ${init}.prmtop"
fi

for file_name in ${file_list} ; do
    if [ ! -f ${file_name}  ] ; then
       echo "[Error] ${file_name} not found" 
       exit 0
    fi
done
}

# 1 - Verifica se a pasta que eu quero rodar existe
# 2 - Se nao existir, cria 
# 3 - Vai para lá.
check_folder() {
if [ ! -d "${run_dir}/${run_type}" ] ; then
    mkdir -p ${run_dir}/${run_type}
fi

if [ -d "${run_dir}/${run_type}" ] ; then
    cd ${run_dir}/${run_type}
else
    echo "[Error] can't acces folder ${run_dir}/${run_type}"
fi
}


#--------------------------------------------------------------------
# O programa
#--------------------------------------------------------------------
# Step 1 - Minimization
run_type="minimimization"
check_folder
for run in "min" ; do
    input=${run}
    check_files
    run_sander
    prev=${run}
done


# Step 2 - Equilibration
prev=${run_dir}/${run_type}/${prev}
run_type=equilibration
check_folder
for run in "heat" "density" "equil" ; do
    input=${run}
    check_files
    case ${run} in 
	    "density"|"equil") run_pmemd_cuda ;;
	    "heat") run_pmemd ;;
    esac
    prev=${run}
done


# Step 3 - Production
# A produção acontece em 3 replicas, cada uma salva em um "run_type"

prev=${run_dir}/equilibration/equil

input="prod"   # Na producao o "input" é fixo, e se chama prod

for run_type in "prod1 prod2 prod3" ; 

    check_folder

    for part in $(seq 1 10) ; do
        check_files
        run=prod_${part}
        run_pmemd_cuda
        prev=${run}
    done

done



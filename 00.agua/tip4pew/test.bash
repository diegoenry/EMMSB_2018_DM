#!/bin/bash
#$ -N tip4pew
#$ -S /bin/bash
#$ -q all.q@compute-1-*
##$ -pe orte 16
#$ -cwd
#$ -o tip4pew.out
#$ -e tip4pew.err

#
# Configuracao ----------------------------------------------------------------
#

# Nome do modelo de agua
model="tip4pew"

# Lista de protocolos
protocolos="min min2 eql eql2 prd"

# Pasta raiz 
base_dir=/home/dgomes/water_md/

# Source GROMACS variables and PATHS
source ~/software/gmx2019.3/bin/GMXRC.bash 

# Extra PATH, required at CLUSTER.MMC.UFJF.BR
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/share/apps/OpenBLAS/lib/


#
# Funcoes de analise ----------------------------------------------------------
#

# Cria o indice (index.ndx) contendo os atomos OW e HW1.
make_index() {
gmx make_ndx -f prd.tpr -o index.ndx <<EOF
a OW
a HW1
q
EOF
}

# Calcula o numero de ligacoes Hidrogenio (hbnum.xvg) entra as moleculas de agua (grupo SOL)
calc_hbonds() {
gmx hbond -s prd.tpr -f prd.xtc -n index.ndx -num hbnum.xvg -xvg none <<EOF
SOL
SOL
EOF
}

# Calcula o mean squared displacement (msd.xvg) para as moleculas de agua (grupo SOL)
calc_msd() {
gmx msd -s  prd.tpr -f prd.xtc -o msd.xvg -xvg no <<EOF
SOL
EOF
}

# Calcula a funcao de distrubuicao radial entre OW e OW (rdf_D2O.xvg), e entre OW e HW1 (rdf_HDO.xvg)
# Essa e a mesma ordem do espectro de difracao de neutrons. 
calc_rdf() {
gmx rdf -s prd.tpr -f prd.xtc -xvg none -ref OW -sel OW  -o rdf_D2O.xvg
gmx rdf -s prd.tpr -f prd.xtc -xvg none -ref OW -sel HW1 -o rdf_HDO.xvg
}


# "Corrige" as condicoes periodicas de contorno, gerando uma trajetoria sem "quebras" de moleculas
fix_pbc() {
gmx trjconv -s prd.tpr -f prd.xtc -o prd_pbc.xtc -pbc mol <<EOF
System
EOF
}

calc_energies() {
gmx energy -f prd.edr -o energy.xvg -xvg none <<EOF
Potential
Temperature
Pressure
Density
q
EOF
}

#
# Programa --------------------------------------------------------------------
#

# Passo 1 - Vai para a pasta onde estao os arquivos
cd ${base_dir}/tip4pew/

# Passo 2 - faz os calculos.
calc_energies   ; # energy.xvg - Potential, Temperature, Pressure, Density
make_index      ; # index.ndx  - Indice
calc_hbonds     ; # hbnum.xvg  - Numero de H-bonds
calc_msd        ; # msd.xvg    - Mean Squared Displacement e Difusao
calc_rdf        ; # rdf_D2O.xvg, rdf_HDO.xvg - g(r)

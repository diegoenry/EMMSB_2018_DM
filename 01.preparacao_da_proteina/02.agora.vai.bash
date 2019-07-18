#!/bin/bash

#Executa o pdb2gmx passando as opcoes:
# 6 - Campo de forcas CHARMM 
# 1 - Modelo de agua TIP3P

gmx pdb2gmx -f proteina.pdb -p proteina.top -o proteina.gro -ignh <<EOF
6
1
EOF

gedit proteina.gro & 
gedit proteina.top &
vmd -e proteina.vmd 

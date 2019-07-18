#!/bin/bash


echo "Qual comando executar ? 

1 - Erro #1 problemas com atomos de Hidrogenio 
    gmx pdb2gmx -f 1ohr.pdb 

2 - Erro #2 problemas com residuos ( Residue 7 named GLN ... ) 
    gmx pdb2gmx -f 1ohr.pdb -ignh 
" 

read opt

case ${opt} in 
 1)
    gmx pdb2gmx -f 1ohr.pdb ;;
 2)
    gmx pdb2gmx -f 1ohr.pdb -ignh  ;;

esac


# Converte a topologia do format GROMACS para o formato AMBER format
# 
# @author Diego E. B. Gomes - dgomes@pq.cnpq.br
# 
#

import parmed as pmd

# Passo 1 - Carrega a topologia e coordenadas iniciais.
gmx_top = pmd.load_file('complexo.top', xyz='complexo.gro')

# Remove Agua e ions
gmx_top.strip(':SOL,NA,CL')

# Salva a topologia no formato AMBER
gmx_top.save('complexo.prmtop', format='amber')

# Salva as coordenadas no formato AMBER
gmx_top.save('complexo.rst7', format='rst7')

# Sai do programa
quit()

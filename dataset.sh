#!/bin/bash

root_dir=$(dirname "$(readlink -f "$0")")

check_exit_code( )
{
  if (( $? != 0 )); then
    err=$1
    msg=$2
    if [[ "$msg" == "" ]]; then
      msg="Unknown error"
    fi
    echo "ERROR: $msg"
    exit $err
  fi
}

# Prepare Directory
mkdir -p dataset; cd dataset

# Download, Extract, and Process STMV
wget https://zenodo.org/records/11087335/files/stmv_gmx_v2.tar.gz -O stmv.tar.gz
tar -xvf stmv.tar.gz; mv stmv_gmx_v2 stmv
${root_dir}/apps/gromacs/bin/gmx_mpi grompp -f stmv/pme_nvt.mdp -p stmv/topol.top -c stmv/conf.gro -o stmv/pme_nvt_2025.tpr
${root_dir}/apps/gromacs/bin/gmx_mpi grompp -f stmv/rf_nvt.mdp -p stmv/topol.top -c stmv/conf.gro -o stmv/rf_nvt_2025.tpr

# Download, Extract, and Process Grappa
#wget https://zenodo.org/records/11087335/files/grappa-46M.tar.bz2 -O grappa.tar.bz2
#tar -xvf grappa.tar.bz2; mv grappa-46M grappa
#${root_dir}/apps/gromacs/bin/gmx_mpi grompp -f grappa/pme.mdp -p grappa/topol.top -c grappa/conf.gro -o grappa/pme_grappa_2025.tpr
#${root_dir}/apps/gromacs/bin/gmx_mpi grompp -f grappa/rf.mdp -p grappa/topol.top -c grappa/conf.gro -o grappa/rf_grappa_2025.tpr



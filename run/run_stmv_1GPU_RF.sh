#!/bin/bash

root_dir=${PWD%/*}
script_name="${0}"
run_name=$(basename "${script_name%.*}")
timestamp="$(date +%Y%m%d_%H%M%S)"

export AMD_DIRECT_DISPATCH=1
export GMX_ENABLE_DIRECT_GPU_COMM=1
export GMX_GPU_DD_COMMS=1
export GMX_FORCE_GPU_AWARE_MPI=1
export GMX_FORCE_UPDATE_DEFAULT_GPU=1

${root_dir}/apps/openmpi/bin/mpirun \
     -np 1 \
     --mca pml ucx \
     --mca spml ucx  \
     --mca osc ucx \
     --mca btl ^vader,tcp,openib,uct \
     --map-by node \
     --rank-by slot \
     --bind-to none \
     ${root_dir}/apps/gromacs/bin/gmx_mpi mdrun \
        -g ${run_name}_${timestamp}.log \
        -e ${run_name}_${timestamp}.edr \
        -ntomp 10 \
        -dlb no \
        -pin on \
        -nb gpu \
        -update gpu \
        -bonded gpu \
        -gpu_id 0 \
        -noconfout \
        -notunepme \
        -s ${root_dir}/dataset/stmv/rf_nvt_2025.tpr \
        -nstlist 300 \
        -nsteps 100000 \
        -resetstep 90000 \
        -v 
root_dir=${PWD%/*}


for run_script in ${root_dir}/run/*; do 
run_name=$(basename "${run_script%.*}")
./run_workload_monitor.sh "./amd_mi300x_power_clock_temp.sh 1 ${run_name}.csv"     "./amd_mi300x_hbm3.sh 1 ${run_name}.csv"     "./amd_mi300x_xgmi.sh 1 ${run_name}.csv"     "${run_script}" 
done
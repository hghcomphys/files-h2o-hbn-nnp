
sh rename.sh
cp systems/w-hbn-rlx.lmp.$1 w-hbn-rlx.lmp && rm -f nnp.data && mpirun -np 4 lmp_mpi < md.nnp.in 
python ../lammps_to_runner.py nnp.data input.data

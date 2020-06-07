#!/usr/bin/env bash

for n in $(seq 1 1 3)
do
  cd $n
  cp ../md.nnp.rerun.in .
  sh rename.sh 
  rm -f nnp.data && mpirun -np 4 lmp_mpi < md.nnp.rerun.in
  python ../../../lammps_to_runner.py nnp.data input.data
  cd ..
done

echo "Done."

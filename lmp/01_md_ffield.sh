rm -f ffield.data input.data && lmp_serial < md.ffield.in
python ../lammps_to_runner.py ffield.data input.data.ffield

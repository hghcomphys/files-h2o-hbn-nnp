#!/usr/bin/env bash

for n in 16 18 20 24 27 29 31 33 35 40 46 56 64 73 84 95 103
do
	cd w$n
	qsub submit_lammps_nnp.sh
	cd ..
done


#!/usr/bin/env bash

rm -rf RUN
mkdir RUN
cd RUN
for n in 16 18 20 24 27 29 31 33 35 40 46 56 64 73 84 95 103
do
	#rm -rf w$n
	mkdir w$n
	cd w$n
	cp ../../md.nnp.in .
	cp ../../input.nn .
	cp ../../scaling.data .
	cp ../../weights.001.data .
	cp ../../weights.005.data .
	cp ../../weights.007.data .
	cp ../../weights.008.data .
	cp ../../systems/w-hbn-rlx.lmp.w$n w-hbn-rlx.lmp
	cp ../../submit_lammps_nnp.sh .
	cd ..
	cp ../02_submit_runs.sh ./submit_all.sh
done
cd ../


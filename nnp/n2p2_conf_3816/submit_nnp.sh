#!/bin/bash


#PBS -q q24h

#PBS -N wat-nnp

#PBS -l walltime=24:00:00

#PBS -l nodes=6:ppn=20

#PBS -o stdout

#PBS -e stderr


cd $PBS_O_WORKDIR  

echo "Job started:" '/bin/date'


#module purge
module load intel
module load intltool
module load GSL
module load Eigen
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/data/antwerpen/202/vsc20298/n2p2-master/lib/

cd $PBS_O_WORKDIR

mpd > mpd.out &

sleep 5s

mpirun -np 120 /data/antwerpen/202/vsc20298/n2p2-master/bin/nnp-scaling 100 > log.scaling.out 
/data/antwerpen/202/vsc20298/n2p2-master/bin/nnp-prune range 1E-4
mpirun -np 120 /data/antwerpen/202/vsc20298/n2p2-master/bin/nnp-train > log.train.out
mpirun -np 120 /data/antwerpen/202/vsc20298/n2p2-master/bin/nnp-dataset 1
/data/antwerpen/202/vsc20298/n2p2-master/bin/nnp-prune sensitivity 0.5
rm -f function.data train.data test.data train-log.out trainforces.*.out testforces.*.out

echo .Job finished: . `/bin/date`

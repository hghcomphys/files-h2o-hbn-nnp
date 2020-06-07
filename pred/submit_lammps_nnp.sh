#!/bin/bash


#PBS -q q24h

#PBS -N wat-nnp-pred

#PBS -l walltime=24:00:00

#PBS -l nodes=1:ppn=20

#PBS -l mem=20GB

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

rm -f nnp.data
mpirun -np 20 /data/antwerpen/202/vsc20298/lammps-16Mar18/src/lmp_mpi <  md.nnp.in  > md.out

echo .Job finished: . `/bin/date`


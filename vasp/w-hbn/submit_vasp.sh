#!/bin/bash


#PBS -q q1h

#PBS -N water-vasp

#PBS -l walltime=1:00:00

#PBS -l nodes=1:ppn=20

#PBS -l mem=55GB

#PBS -o stdout

#PBS -e stderr


cd $PBS_O_WORKDIR  

echo "Job started:" '/bin/date'


#module purge
module load VASP

cd $PBS_O_WORKDIR

mpd > mpd.out &

sleep 5s

mpirun -np 20 vasp_gam >> log.vasp.out

echo .Job finished: . `/bin/date`

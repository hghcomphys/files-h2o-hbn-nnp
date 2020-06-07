#!/usr/bin/env bash

echo "delete run directories..."
rm -rf run*

echo "Unzip files..."
unzip RUN.zip

echo "submit files..."
for n in $(seq $1 1 $2)
do
    cd run$n
    cp ../cleanup.sh .
    cp ../submit_vasp.sh .
    cp ../INCAR .
    cp ../KPOINTS .
    cp ../POTCAR .
    #cp ../vdw_kernel.bindat .
    qsub submit_vasp.sh
    cd ..
done
echo "Done."

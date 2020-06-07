#!/usr/bin/env bash

rm -f input.data
echo removed input.data

for n in $(seq $1 1 $2)
do
  cp dataset/run$n/POSCAR .
  cp dataset/run$n/OUTCAR .

  python ../vasp_to_runner.py input.data.0
  cat input.data.0 >> input.data
done

echo number of sample: $n
rm -f input.data.0 *CAR

echo "Done."

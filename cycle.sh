#!/bin/bash

# script name
script="loop over proteins"

# number of mandatory args
margs=2

# run example
function example {
    echo -e "example:\n$script -f1 VAL1 -f2 VAL2"
}

# script descrtiption
function description {
    echo -e "\n  Ciclo su tutte i file pdb contenuti nella cartella indicata\n"
}

# help 
function help {
  description
    echo -e "MANDATORY:"
    echo -e "  -pdb,               Directory of the PDB files to simulate (full path)"
    echo -e "  -venv,              Python virtualenv (full path)"
    echo -e "OPTION:"
    echo -e "  -o,                 Output path (full path; default current)"
  example
}




pdb=
venv=
output=${PWD}


# define flags
while [ "$1" != "" ];
  do
    case $1 in
      -pdb              )   shift; pdb=$1;;
      -o                )   shift; output=$1;;
      -venv             )   shift; venv=$1;;
      -h | --help       )   help; exit;;
      *         )   shift; echo "Wrong flag"; exit;;
    esac
    shift;
  done


                    ## main

f="${pdb##*/}"
fname="${f%.pdb}"

pdb_files=$pdb/*.pdb

for ff in $pdb_files
do
bash auto.sh -pdb $ff -venv $venv -o $output
done


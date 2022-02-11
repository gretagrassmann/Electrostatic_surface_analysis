#!/bin/bash

# script name
script="bph_electrostatic_surface"

# number of mandatory args
margs=2

# run example
function example {
    echo -e "example:\n$script -f1 VAL1 -f2 VAL2"
}

# script descrtiption
function description {
    echo -e "\n  Descrivi in poche righe il tuo script\n"
}

# help 
function help {
  description
    echo -e "MANDATORY:"
    echo -e "  -pdb,               PDB to simulate (full path)"
    echo -e "  -venv,              Python virtualenv (full path)"
    echo -e "OPTION:"
    echo -e "  -o,                 Output path (full path; default current)"
  example
}

## Ensures that the number of passed args are at least equals
## to the declared number of mandatory args.
## It also handles the special case of the -h or --help arg.
#function margs_precheck {
#  if [ $2 ] && [ $1 -lt $margs ]; then
#    if [ $2 == "--help" ] || [ $2 == "-h" ]; then
#      help
#      exit
#    else
#      echo "Error! Missing pdb"
#      exit 1 # error
#    fi
#  fi
#}

## Ensures that all the mandatory args are not empty
#function margs_check {
#  if [ $# -lt $margs ]; then
#    echo "Error! Missing pdb"
#    exit 1 # error
#  fi
#}

#margs_precheck $# $1

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

#margs_check $pdb

#basename "$pdb"
#fname="$(basename -- $pdb)"

f="${pdb##*/}"
fname="${f%.pdb}"

echo ${fname}


## main

mkdir -p -- ${output}/pdb2pqr
mkdir -p -- ${output}/apbs
mkdir -p -- ${output}/dms
mkdir -p -- ${output}/electrostatic_surfaces

. ${venv}/bin/activate

cd ${output}

# pdb2pqr and apbs


pdb2pqr30 --apbs-input=./${fname}.in -ff=CHARMM ${pdb} ./${fname}.pqr
apbs --output-file=./${fname}.dx ./${fname}.in
# apbs in alcune versioni salva come pqr.dx, in altre come pqr-PE0.dx
if test -f ${output}/apbs/${fname}.pqr-PE0.dx; then
    mv ${output}/apbs/${fname}.pqr-PE0.dx ${output}/apbs/${fname}.pqr.dx
fi


mv *.in *.log *.pqr ${output}/pdb2pqr
mv *.mc *.dx ${output}/apbs

# dms
dms ${pdb} -n -a -o ${output}/dms/${fname}.dms
awk 'sub(/.{14}/, "& ")' ${output}/dms/${fname}.dms > ${output}/dms/${fname}_2.dms

Rscript ../egrid.R ${output}/dms/${fname}_2.dms ${output}/apbs/${fname}.pqr.dx ${output}/electrostatic_surfaces/

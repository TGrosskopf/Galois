#!/bin/bash

echo -e "USAGE: ./run_cc.sh config1 2\n"
appname="connected-components"

if [ -z ${GALOIS_BUILD} ];
then
  echo "GALOIS_BUILD not set; Please point it to the top level directory where Galois is built"
  exit
else
  echo "Using ${GALOIS_BUILD} for Galois build to run ${appname}"
fi

if [ -z ${INPUT_DIR} ];
then
  echo "INPUT_DIR not set; Please point it to the directory with .gr graphs"
  exit
else
  echo "Using ${INPUT_DIR} for inputs for ${appname}"
fi

inputDir="${INPUT_DIR}"
execDir="${GALOIS_BUILD}/lonestar/analytics/cpu/${appname}"
echo ${execDir}

configType=$1
numRuns=$2

if [ -z $configType ];
then
  configType="config1"
fi
if [ -z $numRuns ];
then
  numRuns=1
fi
if [ ${configType} == "config1" ];
then
  echo "Running ${appname} with config1"
  export GOMP_CPU_AFFINITY="0-31"
  export KMP_AFFINITY="verbose,explicit,proclist=[0-31]"
  Threads=32
else
  Threads=64
fi

extension=sgr
exec="connected-components-cpu"
algo="Afforest"
echo "Logs will be available in ${execDir}/logs/${input}"
if [ ! -d "${execDir}/logs/" ];
 then
   mkdir -p ${execDir}/logs/
fi

if [ ${configType} == "config1" ];
then
  for run in $(seq 1 ${numRuns})
  do
    for input in "kron" "road" "urand" "web" "twitter"
    do
      echo "Running on ${input}"
      filename="${appname}_${input}_algo_${algo}_${configType}_Run${run}"
      statfile="${filename}.stats"
      ${execDir}/${exec} -algo=$algo -t=${Threads} $inputDir/GAP-${input}.${extension} -statFile=${execDir}/logs/${statfile} &> ${execDir}/logs/${filename}.out
    done
  done
fi

if [ ${configType} == "config2" ];
then
  for run in $(seq 1 ${numRuns})
  do
    for input in "kron" "road" "urand" "web" "twitter"
    do
      echo "Running on ${input}"
      if [ ${input} == "web" ];
      then algo="EdgetiledAfforest"
      fi
      filename="${appname}_${input}_algo_${algo}_${configType}_Run${run}"
      statfile="${filename}.stats"
      ${execDir}/${exec} -algo=$algo -t=${Threads} $inputDir/GAP-${input}.${extension} -statFile=${execDir}/logs/${statfile} &> ${execDir}/logs/${filename}.out
    done
  done
fi

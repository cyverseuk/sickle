#!/bin/bash

function debug {
  echo "creating debugging directory"
mkdir .debug
for word in ${rmthis}
  do
    if [[ "${word}" == *.sh ]] || [[ "${word}" == lib ]]
      then
        mv "${word}" .debug;
      fi
  done
}

rmthis=`ls`
echo ${rmthis}

ARGSU=" ${qual-type} ${qual-threshold} ${length-threshold} ${no-fiveprime} ${truncate-n} ${gzip-output}"
READ1U="${pair1}"
READ2U="${pair2}"
INPUTSU="${pair1}, ${pair2}"
echo "arguments are "${ARGSU}
echo "first input file is "${READ1U}
echo "second input file, if provided, is "${READ2U}
echo "inputs are "${INPUTSU}

OU1="trimmed_${pair1}"
OU2="trimmed_${pair2}"
OUS="trimmed_single.fq"
if [ -n "${gzip-output}" ]
  then
    OU1+=".gz"
    OU2+=".gz"
    OUS+=".gz"
fi
CMDLINEARG="sickle pe ${qual-threshold} ${length-threshold} ${no-fiveprime} ${truncate-n} ${gzip-output} "
if [ -n "${pair2}" ]
  then
    CMDLINEARG+="-f ${pair1} -r ${pair2} ${qual-type} -o ${OU1} -p ${OU2} -s ${OUS}"
  else
    CMDLINEARG+="-c ${pair1} ${qual-type} -m ${OU1} -s ${OUS}"
fi

echo ${CMDLINEARG};
chmod +x launch.sh

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/sickle:v1.33 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments                          = ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTSU}, launch.sh >> lib/condorSubmitEdit.htc
#echo transfer_output_files = output >> lib/condorSubmitEdit.htc
cat /mnt/data/apps/sickle_pe/lib/condorSubmit.htc >> lib/condorSubmitEdit.htc

less lib/condorSubmitEdit.htc

jobid=`condor_submit -batch-name ${PWD##*/} lib/condorSubmitEdit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

debug

exit 0

#!/bin/bash


#### TASH

ARGS=$(getopt -a --options m:hg:t:v: --long "Fmcai:,help,gyrus:,table:,version:" -- "$@")
eval set -- "$ARGS"
Fmcai=0
help="false"
gyrus=1
table=2
version=7

while true; do
  case "$1" in
    -m|--Fmcai)
      Fmcai=$2
      shift 2;;
    -h|--help)
      help="true"
      shift;;
    -g|--gyrus)
      gyrus=$2
      shift 2;;
    -t|--table)
      table=$2
      shift 2;;
    -v|--version)
      version=$2
      shift 2;;
    --)
      break;;
     *)
      printf "Unknown option %s\n" "$1"
      exit 1;;
  esac
done

if [ $help == true ]; then
  echo '------------ Welcome! ------------'
  echo -e "TASH Toolbox for Heschl's gyrus.\nBefore starting remember to set the TASH output folder as\n\n export TASH_DIR=PathToYourForlderHere\n\nUsage: TASH_complete_v1.sh [-h] [-m] [-g] [-v] [-t]\n\noptional arguments:\n    -h --help\n    -t [1-2] compute the TASH tables and extract information from others ROIs. You can insert value 1 if you want only the table form TASH or 2 if you want to compute stats on other regions including all brain analysis. Default option is set to 2\n    -v [5-6-7] input freesurfer version you used to run recon-all [available options are 5,6 or 7]. Default one is 7\n    -m [0-1-2] value to run also the MCAI analysis. 0 means no running MCAI, 1 means MCAI and TASH, 2 means ONLY MCAI. IMPORTANT> to run MCAI with flag == 2 it means that at some point TASH was run on the dataset of interest.  Default set to 0 no MCAI\n    -g [1-2-3 etc.] which gyrus you want to run MCAI on. Default 1 (first). IT REQUIRES -m to be greater than 0" 
  exit 1
fi

if [ -z ${TASH_DIR+x} ]; then 
  echo "TASH_DIR is unset. Plese set the TASH directory. See function helper"
  exit 1
else 
  echo "TASH_DIR is set to '$TASH_DIR'"
fi

cd TASH_Complete

if (( $Fmcai < 2 )); then

	echo '-----------------'
	echo '-----------------'
	echo 'Some Freesurfer preprocessing!'
	echo '-----------------'
	echo '-----------------'

	chmod +x TASH_tcsh.csh
	tcsh -c "./TASH_tcsh.csh"

	echo '-----------------'
	echo '-----------------'
	echo 'Segmenting masks!'
	echo '-----------------'
	echo '-----------------'

	matlab -nojvm -nodesktop -r 'try; TASH_segmentation_complete; catch; end; quit'

	echo '-----------------'
	echo '-----------------'
	echo 'Getting Stats on the masks!'
	echo '-----------------'
	echo '-----------------'

	chmod +x TASH_tcsh2_complete.csh
	tcsh -c "./TASH_tcsh2_complete.csh"

	echo '-----------------'
	echo '-----------------'
	echo 'Plotting!'
	echo '-----------------'
	echo '-----------------'

	if (( $version < 7 )); then 
	  echo "Running TASH based on older freesurfer version"
	  matlab -nojvm -nodesktop -r 'try; TASH_output_complete; catch; end; quit'
	else 
	  echo "Running TASH based on freesurfer 7"
	  matlab -nojvm -nodesktop -r 'try; TASH_output_complete_v7; catch; end; quit'
	fi
	echo '-----------------'
	echo '-----------------'
	echo 'Getting the Tables!'
	echo '-----------------'
	echo '-----------------'


	if (( $table < 2 )); then 
	  echo "Getting the tables of TASH only"
	  matlab -nojvm -nodesktop -r 'try; GD_to_csv_all_gyri(1); catch; end; quit'
	else 
	  echo "Getting the tables of TASH and others ROI"
	  chmod +x GD_run_aseg_freesurfer.sh
	  ./GD_run_aseg_freesurfer.sh
	  chmod +x GD_run_apar_freesurfer.sh
	  ./GD_run_apar_freesurfer.sh
	  matlab -nojvm -nodesktop -r 'try; GD_to_csv_all_gyri(2); catch; end; quit'
	fi
fi

if (( $Fmcai > 0 )); then
  echo "Running MCAI"
  matlab -nodesktop -r "try; MCAI('$gyrus'); catch; end; quit"
fi



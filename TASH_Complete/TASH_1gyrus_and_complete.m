# TASH
chmod +x TASH_tcsh.csh
./TASH_tcsh.csh
matlab -nojvm -nodesktop -r 'try; TASH_segmentation; catch; end; quit'
chmod +x TASH_tcsh2.csh
./TASH_tcsh2.csh
matlab -nojvm -nodesktop -r 'try; TASH_output; catch; end; quit'
matlab -nojvm -nodesktop -r 'try; TASH_segmentation_complete; catch; end; quit'
chmod +x TASH_tcsh2_complete.csh
./TASH_tcsh2_complete.csh
matlab -nojvm -nodesktop -r 'try; TASH_output_complete; catch; end; quit'

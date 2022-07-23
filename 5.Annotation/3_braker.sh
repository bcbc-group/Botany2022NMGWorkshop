#!/bin/sh
###############################################################
# pipeline for running braker on bam files   #
#                                                             #
# usage:                                                      #
#                                                             #
#      2_braker.sh $base_dir $CPU                             #
#                                                             #
###############################################################

cd $1

#Installing biopython in case biopython is not available
#pip3 install biopython

#moving gm_key to accessible directory
cd 
wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1yMTsYGO4hso9XCfJs-no2zrjBTz2waSs' -O gm_key_64.gz
gunzip gm_key_64.gz 
mv gm_key_64 .gm_key

#copying Augustus config file to create species parameters
mkdir $HOME/augustus
cp -r Augustus/config $HOME/augustus

#untar braker 
tar -xvf v2.1.6.tar.gz

#compile bamtools
cd /home/user/bamtools/build && make install

#paths to export for software
export PATH=/home/user/BRAKER-2.1.6:/home/user/BRAKER-2.1.6/scripts:$PATH
export AUGUSTUS_CONFIG_PATH=$HOME/augustus/config
export AUGUSTUS_BIN_PATH=/home/user/Augustus/bin
export AUGUSTUS_SCRIPTS_PATH=/home/user/Augustus/scripts
export TMPDIR=$HOME/tmp
export GENEMARK_PATH=/home/user/gmes_linux_64_4/
export BAMTOOLS_PATH=/home/user/bamtools/build/bin
export DIAMOND_PATH=/home/user/
export HTSLIB_INSTALL_DIR=/home/user/htslib-1.13/

#install missing library
cpan List::MoreUtils

#mv to annotation working dir
cd ~/annotation/
mkdir braker_out

#get prepared files
cp ../work/data/iplant/home/shared/Botany2020NMGWorkshop/annotation/2transfer/contig_15_masked.fasta .

braker.pl --genome=contig_15_masked.fasta --bam=SRR5046448_contig15.sort.bam \
--softmasking --workingdir=./braker_out --cores 2 --gm_max_intergenic 100000 --skip_fixing_broken_genes &> test1

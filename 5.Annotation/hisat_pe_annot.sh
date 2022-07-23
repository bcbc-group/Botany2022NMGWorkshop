#!/bin/sh
###############################################################
# pipeline for running hisat2 on paired end files   #
#                                                             #
# usage:                                                      #
#                                                             #
#      hisat_pe_annot.sh $base_dir $CPU                       #
#                                                             #
###############################################################

cd $1

#make a dir for your output and copy or symlink some files there
#mkdir /scratch/annotation_output
#cd /scratch/annotation_output
#cp /scratch/Botany2020NMGWorkshop/annotation/2transfer/contig_15.fasta .
#ln -s /scratch/Botany2020NMGWorkshop/annotation/2transfer/*.fastq .

#install hisat2
sudo apt-get -y install hisat2

#index reference fasta file; We will use only contig_15 for demo purposes
cp work/data/iplant/home/shared/Botany2020NMGWorkshop/annotation/tutorial/contig_15.fasta annotation/
cd annotation
hisat2-build contig_15.fasta contig_15

#map RNA-seq reads to reference genome fasta file
cp ../work/data/iplant/home/shared/Botany2020NMGWorkshop/annotation/tutorial/*.fastq .
cp ../work/data/iplant/home/shared/Botany2020NMGWorkshop/annotation/2transfer/*.fastq .

for file in `dir -d *_1.fastq` ; do

    samfile=`echo "$file" | sed 's/_1.fastq/.sam/'`
    file2=`echo "$file" | sed 's/_1.fastq/_2.fastq/'`

     hisat2 --max-intronlen 100000 --dta -p 6 -x contig_15 -1 $file -2 $file2 -S $samfile

done

sudo apt-get -y install parallel
ls *.sam |parallel --gnu -j 1 samtools view -Sb -o {.}.bam {}
ls *.bam |parallel --gnu -j 1 samtools sort -o {.}.sort.bam {}

#run stringtie to get gtf files of transcript annotations
for file in `dir -d *sort.bam` ; do

    outdir=`echo "$file" |sed 's/.bam/.gtf/'`

    /opt/stringtie/stringtie --rf -p 7 -o $outdir $file

done

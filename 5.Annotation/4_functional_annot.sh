#!/bin/sh

#remove proteins with internal “.”

#run InterProScan
apt install default-jre    #may need to remove some things to make room
screen -L /scratch/interproscan-5.51-85.0/interproscan.sh -f TSV -goterms -iprlookup -pa -i maker1_proteins.fasta -o IPS.output -cpu 20
#show example here: /scratch/annotation_output/test_run2/contig_15.maker.output

#filter out transposons
grep -f transposons.list all_IPS.out |cut -f1 > IPS_tran.list

#run Diamond
diamond blastp -d /databases/Trembl_04-17-19/uniprot_trembl.dmnd -q maker_prot_complete.fasta -o diamond_trembl.out --evalue 0.00000000000000000001

sort -k1,1 -k12,12nr -k11,11n diamond_trembl.out |sort -u -k1,1 --merge > tophits.out

cat inc_tophiht.out tophits.out |awk '$11 < 0.00000000000000000001 {print $0}' > all_tophits_e20.out

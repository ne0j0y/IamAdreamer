#!/bin/ksh

mv FILE_STATS.txt FILE_STATS.txt.tmp

echo "----------------------File was generated on `date`--------------------" >> FILE_STATS.txt
echo >> FILE_STATS.txt
echo >> FILE_STATS.txt
echo >> FILE_STATS.txt
echo >> FILE_STATS.txt
echo "######################################################################################" >> FILE_STATS.txt

for a in 610_CDR 613_CDR 620_CDR 560_CDR 570_CDR 580_CDR 590_CDR 610_SDR 613_SDR 620_SDR 560_SDR 570_SDR 580_SDR 590_SDR
do

if [ -f $a*gz ]; then

#### To get the final sequence from the previous run

vSearchFile="Final Sequence for the file type "$a
finseq=$(awk -v serstr="$vSearchFile" '$0 ~ serstr {getline; print}' FILE_STATS.txt.tmp)

echo "Total number of files of type $a:" >> FILE_STATS.txt

ls -1a $a*gz | awk -F"_" 'NR>=1{arr[$1$2]++}END{for (a in arr) print arr[a]}' >> FILE_STATS.txt

### finding the starting sequence

echo "Starting Sequence for the file type "$a":" >> FILE_STATS.txt

ls -1a $a*gz | awk -F"_" '{print $3}' | awk -F"." '{print $1}'| awk 'NR == 1 || $3 > max {line = $0; max = $1}END{print line}' >> FILE_STATS.txt

### finding the ending sequence

echo "Final Sequence for the file type "$a":" >> FILE_STATS.txt
ls -1a $a*gz | awk -F"_" '{print $3}' | awk -F"." '{print $1}'| awk 'NR == 1 || $3 < min {line = $0; min = $1}END{print line}' >> FILE_STATS.txt

### finding the missing sequence
echo "Missing Files for the file type "$a":" >> FILE_STATS.txt
ls -1a $a*gz | awk -F"_" '{print $3}' | awk -F"." '{print $1}'|awk -v p="$finseq" '$1!=p+1{print p+1"-"$1-1}{p=$1;print "No Missing Files"}' >> FILE_STATS.txt

echo "######################################################################################" >> FILE_STATS.txt

else
echo "No Files Exists of type $a"  >> FILE_STATS.txt

echo "######################################################################################" >> FILE_STATS.txt
fi

done

rm FILE_STATS.txt.tmp

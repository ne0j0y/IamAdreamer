#!/bin/ksh

mv FILE_STATS.txt FILE_STATS.txt.tmp

echo "----------------------File was generated on `date`--------------------" >> FILE_STATS.txt
echo >> FILE_STATS.txt
echo >> FILE_STATS.txt
echo >> FILE_STATS.txt
echo >> FILE_STATS.txt
echo "######################################################################################" >> FILE_STATS.txt

for a in 610_CDR 613_CDR 620_CDR 560_CDR 570_CDR 580_CDR 590_CDR 610_SDR 613_SDR 620_SDR 560_SDR 570_SDR 580_SDR 590_SDR CNUM
do

#### To get the final sequence from the previous run

vSearchFile="Final Sequence for the file type "$a
finseq=$(awk -v serstr="$vSearchFile" '$0 ~ serstr {getline; print}' FILE_STATS.txt.tmp)


if [ -f $a*gz ] || [ -f $a*DAT ]; then

echo "Total number of files of type $a:" >> FILE_STATS.txt
if [ $a == "CNUM" ]; then

	ls -1a $a*DAT | awk -F"_" 'NR>=1{arr[$1$2]++}END{for (a in arr) print arr[a]}' >> FILE_STATS.txt
else

	ls -1a $a*gz | awk -F"_" 'NR>=1{arr[$1$2]++}END{for (a in arr) print arr[a]}' >> FILE_STATS.txt
fi

### finding the starting sequence

echo "Starting Sequence for the file type "$a":" >> FILE_STATS.txt
if [ $a == "CNUM" ]; then

	ls -1a $a*DAT | awk -F"_" '{print $5}' |awk -F"." '{print $1}'| awk 'NR == 1 || $1 < min {line = $0; min = $1}END{print line}' >> FILE_STATS.txt
else
	ls -1a $a*gz | awk -F"_" '{print $3}' | awk -F"." '{print $1}'| awk 'NR == 1 || $1 < min {line = $0; min = $1}END{print line}' >> FILE_STATS.txt
fi

### finding the ending sequence

echo "Final Sequence for the file type "$a":" >> FILE_STATS.txt
if [ $a == "CNUM" ]; then

	ls -1a $a*DAT | awk -F"_" '{print $5}' | awk -F"." '{print $1}'| awk 'NR == 1 || $1 > max {line = $0; max = $1}END{print line}' >> FILE_STATS.txt
else
	ls -1a $a*gz | awk -F"_" '{print $3}' | awk -F"." '{print $1}'| awk 'NR == 1 || $1 > max {line = $0; max = $1}END{print line}' >> FILE_STATS.txt
fi

### finding the missing sequence
echo "Missing Files for the file type "$a":" >> FILE_STATS.txt
if [ $a ==  "CNUM" ]; then

	vMiss=$(ls -1a $a*DAT | awk -F"_" '{print $5}' | awk -F"." '{print $1}'| awk -v p="$finseq" '$1!=p+1{print p+1"-"$1-1}{p=$1}')

else

	vMiss=$(ls -1a $a*gz | awk -F"_" '{print $3}' | awk -F"." '{print $1}'|awk -v p="$finseq" '$1!=p+1{print p+1"-"$1-1}{p=$1}') 
fi
if [ -z "$vMiss" ]; then
	echo "No Missing Files" >> FILE_STATS.txt
else
	echo $vMiss >> FILE_STATS.txt
fi

echo "######################################################################################" >> FILE_STATS.txt

else
echo "No Files Exists of type $a"  >> FILE_STATS.txt
echo "Final Sequence for the file type "$a":" >> FILE_STATS.txt
echo $finseq >> FILE_STATS.txt

echo "######################################################################################" >> FILE_STATS.txt
fi

done

rm FILE_STATS.txt.tmp

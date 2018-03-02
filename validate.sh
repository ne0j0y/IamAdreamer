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

#### To get the starting sequence from the previous run

vSearchFile="Starting Sequence for the file type "$a
startseq=$(awk -v serstr="$vSearchFile" '$0 ~ serstr {getline; print}' FILE_STATS.txt.tmp)

#### To get the total number of files from the previous run

vSearchFile="Total number of files of type "$a
totfiles=$(awk -v serstr="$vSearchFile" '$0 ~ serstr {getline; print}' FILE_STATS.txt.tmp)


if [ -f $a*gz ] || [ -f $a*DAT ]; then

echo "Total number of files of type $a:" >> FILE_STATS.txt
if [ $a == "CNUM" ]; then

	vCurrTotFiles=$(ls -1a $a*DAT | awk -F"_" 'NR>=1{arr[$1$2]++}END{for (a in arr) print arr[a]}') 
else

	vCurrTotFiles=$(ls -1a $a*gz | awk -F"_" 'NR>=1{arr[$1$2]++}END{for (a in arr) print arr[a]}') 
fi
echo $vCurrTotFiles >> FILE_STATS.txt


### finding the starting sequence. If the missing files from the previous run are present they will not be considered for finding the starting sequence.

echo "Starting Sequence for the file type "$a":" >> FILE_STATS.txt


if [ "$vCurrFinSeq" -eq "$finseq" ] && [ "$vCurrTotFiles" -eq "$totfiles" ]; then   ##### To handle multiple runs with the same set of files.

        vSrchFileFirstSeq="Starting Sequence for the file type "$a
        vStartSeq=$(awk -v serstr="$vSrchFileFirstSeq" '$0 ~ serstr {getline; print}' FILE_STATS.txt.tmp)
        echo $vStartSeq >> FILE_STATS.txt
else

	if [ $a == "CNUM" ]; then

		vCurrStartSeq=$(ls -1a $a*DAT | awk -F"_" '{print $5}' |awk -F"." '{print $1}'| awk -v preSeq="$finseq" 'BEGIN{pVal=preSeq;mVal=999999} $1 >= pVal && $1 <= mVal {line = $0; mVal = $1}END{print line}')
	else
		vCurrStartSeq=$(ls -1a $a*gz | awk -F"_" '{print $3}' | awk -F"." '{print $1}'| awk -v preSeq="$finseq" 'BEGIN{pVal=preSeq;mVal=999999} $1 >= pVal && $1 <= mVal {line = $0; mVal = $1}END{print line}') 
	fi

	echo $vCurrStartSeq >> FILE_STATS.txt

fi

### finding the ending sequence

echo "Final Sequence for the file type "$a":" >> FILE_STATS.txt
if [ $a == "CNUM" ]; then

	vCurrFinSeq=$(ls -1a $a*DAT | awk -F"_" '{print $5}' | awk -F"." '{print $1}'| awk 'NR == 1 || $1 > max {line = $0; max = $1}END{print line}') 
else
	vCurrFinSeq=$(ls -1a $a*gz | awk -F"_" '{print $3}' | awk -F"." '{print $1}'| awk 'NR == 1 || $1 > max {line = $0; max = $1}END{print line}')
fi

echo $vCurrFinSeq >> FILE_STATS.txt 

### finding the missing sequence
echo "Missing Files for the file type "$a":" >> FILE_STATS.txt
if [ "$vCurrFinSeq" -eq "$finseq" ] && [ "$vCurrTotFiles" -eq "$totfiles" ]; then   ##### To handle multiple runs with the same set of files.

	vSrchFileMissSeq="Missing Files for the file type "$a
	vMissSeq=$(awk -v serstr="$vSrchFileMissSeq" '$0 ~ serstr {getline; print}' FILE_STATS.txt.tmp)
	echo $vMissSeq >> FILE_STATS.txt

else
	if [ $a ==  "CNUM" ]; then

		vMiss=$(ls -1a $a*DAT | awk -F"_" '{print $5}' | awk -F"." '{print $1}'| awk -v min="$finseq" 'BEGIN{p=min} $1!=p+1 && $1>min {print p+1"-"$1-1}{if ($1>min) p=$1}') #### Handled the missing sequences in case of old files by adding $1 > p

	else
		vMiss=$(ls -1a $a*gz | awk -F"_" '{print $3}' | awk -F"." '{print $1}'|awk -v min="$finseq" 'BEGIN{p=min} $1!=p+1 && $1>min {print p+1"-"$1-1}{if ($1>min) p=$1}') #### Handled the missing sequences in case of old files by adding $1 > p 
	fi
	if [ -z "$vMiss" ]; then
		echo "No Missing Files" >> FILE_STATS.txt
	else
		echo $vMiss >> FILE_STATS.txt
	fi
fi

echo "######################################################################################" >> FILE_STATS.txt

else
echo "No Files Exists of type $a"  >> FILE_STATS.txt
echo "Final Sequence for the file type "$a":" >> FILE_STATS.txt
echo $finseq >> FILE_STATS.txt

echo "######################################################################################" >> FILE_STATS.txt
fi

done

echo "File Stats for today" | mail -a FILE_STATS.txt -s "File Stats_$(date)" marika.hager@optus.com.au Shonali.Patil@optus.com.au marika.hager@optiva.com neo.joy@optiva.com
rm FILE_STATS.txt.tmp

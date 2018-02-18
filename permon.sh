#!/bin/ksh

######## For capturing the details of cvtengine
ps -eo pid,pcpu,pmem,rss,vsz,command |grep cvtengine|awk '{print strftime("%D %H:%M:%S",systime()), $0}' > mediation_`date +"%Y%m%d"`.txt


##### For capturing the details of collector
ps -eo pid,pcpu,pmem,rss,vsz,command |grep ibCollect|awk '{print strftime("%D %H:%M:%S",systime()), $0}' > collector_`date +"%Y%m%d"`.txt


##### Collecting the free memory and swap

free | awk '{print strftime("%D %H:%M:%S",systime()), $0}' > memtmp.txt

vfree=`cat memtmp.txt | grep buffers/cache | awk '{print $1,$2,$6}'`

vswap=`cat memtmp.txt | grep Swap | awk '{print $6}'`

vfull=$vfree" "$vswap

echo $vfull >> memory_`date +"%Y%m%d"`.txt


##### Formatting the collector file.
awk -F" " '{$2=$1" " $2;}{print $2,$3,$4,$5,$6,$7,a[split($NF,a,"/")],"collector"}' OFS=',' collector_`date +"%Y%m%d"`.txt > ctmp.txt

if [[ -f `date +"%Y%m%d"`.tmp.txt ]]; then
        awk -F"," '{sub(".xml","",$7);print $0}' OFS=","  ctmp.txt >> `date +"%Y%m%d"`.tmp.txt
else
        awk 'BEGIN {print "date,pid,pcpu,pmem,rss,vsz,switch,module"}' >> `date +"%Y%m%d"`.tmp.txt
        awk -F"," '{sub(".xml","",$7);print $0}' OFS=","  ctmp.txt >> `date +"%Y%m%d"`.tmp.txt
fi


####Formatting the mediation file.

awk -F" " '{$2=$1" " $2;}{print $2,$3,$4,$5,$6,$7}' OFS="," mediation_`date +"%Y%m%d"`.txt > mtmp.txt

while read v_psline    ##read each line of the ps file
do
	## storing the second field in the variable v_pid
	v_pid=`echo $v_psline|awk -F "," '{print $2}'`
	while read v_logline    ## read each line of the log file.
	do
	if [[ $v_logline =~ $v_pid ]] && [[ ! $v_logline =~ Starting ]] ; then  ## if the pid is present in the line of the log file.
		
		v_swi_id=`echo $v_logline|awk -F " " '{print $6}'|tr -d '[]'`   ##pick the switch id from the 6th field
		#awk -v var1="$v_pid" -v var2="$v_time" -v var3="$v_swi_id" '{FS=","} {OFS=","} { if($2=var1 && $1==var2 && $14=="") {print $0 var3}} ' `date +"%Y%m%d"`.txt >> `date +"%Y%m%d"`.tmp.txt
		echo $v_psline|awk -v var1="$v_swi_id" '{FS=","} {print $0 ","var1",mediation"}' >> `date +"%Y%m%d"`.tmp.txt	##append the switch id at the end of the line.
		break
	
	fi
	done < /opt/inbill/log/mediation/pro-med1.mediation_log_file.log 
done < mtmp.txt

################mapping over for mediation

######## To rename the previous days tmp.txt file to .txt file.
v_yday_file=`expr $(date +"%Y%m%d") - 1`
if [[ -f $v_yday_file.tmp.txt ]]; then
        mv $v_yday_file.tmp.txt  $v_yday_file.txt
fi




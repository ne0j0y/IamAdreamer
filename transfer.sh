#!/bin/ksh

move_files()
{

cd /opt/redknee/home/plt76p1/mngdservSFTP 

echo "Proceed with $1 File (y/n):"
read vYesno

if [ $vYesno == 'y' ]; then

vCnt=`ls $1* 2>/dev/null |wc -l`

if [ $vCnt -ne 0 ]; then

        mv $1* $2

        status=$?

        if [ $status -eq 0 ];then

                echo "$1 successfully moved to destination path"
                if [ $1 == "CNUM" ]; then

                        cd $2
                        chmod 777 $1*
                fi
        else

                echo " Could not move $1 file to destination  path"
        fi

else
        echo " No $1 files to move"

fi
fi

}


run_collector()
{
echo "Proceed with running collector process on $1 File (y/n):"
read vYesno

if [ $vYesno == 'y' ]; then

	ibCollect -d -e $2
fi
}

cd /opt/redknee/home/plt76p1/mngdservSFTP

/opt/redknee/home/plt76p1/mngdservSFTP/validate.sh

status=$?

if [ $status -eq 0 ];then

        echo " File stats generated" 
else

        echo "File Stats not generated. Manual check required"

fi


move_files CNUM /opt/redknee/home/plt76p1/inbill/ldr
move_files 560_SDR /opt/redknee/home/plt76p1/inbill/ldr/sdr/560
move_files 580_SDR /opt/redknee/home/plt76p1/inbill/ldr/sdr/580
move_files 570_SDR /opt/redknee/home/plt76p1/inbill/ldr/sdr/570/original/done/tmp
move_files 590_SDR /opt/redknee/home/plt76p1/inbill/ldr/sdr/590/original/done/tmp
move_files 610_SDR /opt/redknee/home/plt76p1/inbill/ldr/sdr/610/original/done/tmp
move_files 613_SDR /opt/redknee/home/plt76p1/inbill/ldr/sdr/613/original/done/tmp
move_files 620_SDR /opt/redknee/home/plt76p1/inbill/ldr/sdr/620/original/done/tmp

run_collector 570_SDR /opt/redknee/home/plt76p1/inbill/ldr/sdr/sdrTmpCol570.xml
run_collector 620_SDR /opt/redknee/home/plt76p1/inbill/ldr/sdr/sdrTmpCol620.xml
run_collector 610_SDR /opt/redknee/home/plt76p1/inbill/ldr/sdr/sdrTmpCol610.xml
run_collector 590_SDR /opt/redknee/home/plt76p1/inbill/ldr/sdr/sdrTmpCol590.xml
run_collector 613_SDR /opt/redknee/home/plt76p1/inbill/ldr/sdr/sdrTmpCol613.xml


move_files 560_CDR /opt/redknee/home/plt76p1/inbill/cdr/560/original/done/tmp
move_files 570_CDR /opt/redknee/home/plt76p1/inbill/cdr/570/original/done/tmp
move_files 580_CDR /opt/redknee/home/plt76p1/inbill/cdr/580/original/done/tmp
move_files 590_CDR /opt/redknee/home/plt76p1/inbill/cdr/590/original/done/tmp
move_files 610_CDR /opt/redknee/home/plt76p1/inbill/cdr/610/original/done/tmp
move_files 620_CDR /opt/redknee/home/plt76p1/inbill/cdr/620/original/done/tmp


run_collector 570_CDR /opt/redknee/home/plt76p1/inbill/cdr/cdrTmpCol570.xml
run_collector 580_CDR /opt/redknee/home/plt76p1/inbill/cdr/cdrTmpCol580.xml
run_collector 590_CDR /opt/redknee/home/plt76p1/inbill/cdr/cdrTmpCol590.xml
run_collector 620_CDR /opt/redknee/home/plt76p1/inbill/cdr/cdrTmpCol620.xml
run_collector 610_CDR /opt/redknee/home/plt76p1/inbill/cdr/cdrTmpCol610.xml
run_collector 560_CDR /opt/redknee/home/plt76p1/inbill/cdr/cdrTmpCol560.xml



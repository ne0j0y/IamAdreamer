#!/bin/ksh

cd /opt/redknee/home/plt76p1/inbill/ldr 

vFile=$(ls -ltr CNUM*| tail -1 | awk '{print $9}')

sqlplus -s <<RTE
$IB_RTE_CONN_STR

set serveroutput on
DECLARE
 vres          VARCHAR2(100);
 parm_values   lib_name_value_tabtyp := lib_name_value_tabtyp();
 parm_arr      lib_string_pkg.string_arrtype;
 p_ldr_action  lib_string_pkg.string_type := 'Load';
 parm_defs     lib_string_pkg.string_type;
 pk_ldr_rec    ldr_iadmin_pkg.ldr_rectype;
 parm_val      lib_string_pkg.string_type;
 p_ldr_abbr    lib_string_pkg.string_type := 'CNUM_DELTA';
 sep_pos       NUMBER(10);
 varchar_index NUMBER(10);
BEGIN
 pk_ldr_rec := ldr_iadmin_pkg.get_details(p_ldr_abbr);
 parm_arr  := ldr_iadmin_pkg.parse_parm_defs(parm_defs, p_ldr_abbr);

 parm_values.EXTEND;
 parm_values(1) := lib_name_value_objtyp('FILENAME','$vFile');
 parm_values.EXTEND;
 parm_values(2) := lib_name_value_objtyp('IGNORE_BATCH_SEQ', 'Y');

 vres := ldr_iadmin_pkg.start_ldr_process(ldr_abbr_in=>p_ldr_abbr,ldr_action_in=> p_ldr_action,parm_values_in=> parm_values,block_in=> TRUE);

EXCEPTION

WHEN OTHERS THEN NULL;

END;
/

RTE

sqlplus -s <<WUI
$IB_WUI_CONN_STR

VARIABLE vLdrSucc number;

set serveroutput on


DECLARE

tot_insert_rec number(9);
tot_update_rec number(9);
tot_delete_rec number(9);


BEGIN

:vLdrSucc := 5;

SELECT t.tot_insert_recs,t.tot_update_recs,t.tot_delete_recs into tot_insert_rec,tot_update_rec,tot_delete_rec  FROM prd_ldr_table_stats t LEFT OUTER JOIN ib\$process_jrnl p ON p.process_key = t.process_key where trunc(p.start_dttm) = trunc(sysdate) and p.process_instance = 'CNUM_DELTA' ;

if ( tot_insert_rec = 0 and tot_update_rec = 0 and tot_delete_rec = 0 ) then

:vLdrSucc := 7;
end if; 


EXCEPTION

WHEN NO_DATA_FOUND THEN :vLdrSucc := 7; 

WHEN OTHERS THEN  :vLdrSucc := 7; 

END;
/

EXIT  :vLdrSucc

WUI


cnum_res=$(echo $?)

echo $cnum_res

if [ $cnum_res -eq 7 ] ; then

echo "$vFile not loaded successfully. Check immediately" | mail -s "CNUM File Status" neo.joy@optiva.com nabakumar.b@optiva.com

else

echo "$vFile loaded successfully" | mail -s "CNUM File Status" neo.joy@optiva.com nabakumar.b@optiva.com

fi	 

 

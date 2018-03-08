#!/bin/ksh

sqlplus -s <<EOF $IB_RTE_CONN_STR

set linesize 300;
set pagesize 5000;
set colsep ,
column FRG_EVENT_SRC_KEY format 999 
column SWI_ID format a15
column FRG_FILE_STATUS_CODE format 99 
column SUM(CONVERTED_RECS) format 9999999999 
column SUM(LOADED_RECS) format 9999999999
column SUM(DUP_RECS) format 9999999999 
column FILE_TYPE format a5
column BUNDLE_CODE format 9999
column BUNDLE_ABBR format a10
column BUNDLE_SVC_ID format a20
spool daily_rec_stats.csv 
prompt "-----------------------------------FRG Record Stats------------------------------";
SELECT FRG_EVENT_SRC_KEY,SWI_ID,trunc(first_submitted_dttm) AS "DATE",FRG_FILE_STATUS_CODE,SUM(converted_recs) AS "TOTAL_CONVERTED_RECS",SUM(loaded_recs) AS "TOTAL_LOADED_RECS",SUM(dup_recs) AS "TOTAL_DUPLICATE_RECS" FROM prd_frg_file_jrnl WHERE file_key >=(SELECT MIN(file_key) FROM prd_frg_file_jrnl WHERE trunc(first_submitted_dttm) >= (select trunc(sysdate,'mm') from dual)) GROUP BY frg_event_src_key, swi_id,trunc(first_submitted_dttm), frg_file_status_code order by swi_id,trunc(first_submitted_dttm);

prompt "-----------------------------------SDR Loader Stats------------------------------";

select "FILE_TYPE", "REQ_DTTM", "BUNDLE_CODE", "BUNDLE_ABBR", "BUNDLE_SVC_ID", "COUNT(*)" FROM (select substr(file_name,8,3) as "FILE_TYPE", trunc(req_dttm) as "REQ_DTTM", a.bundle_code, bundle_abbr, bundle_svc_id, count(*) from prd_subs_bundle_req a, ref_bundle b, ref_bundle_df c where a.bundle_code = b.bundle_code and b.bundle_code = c.bundle_code and req_dttm >= (select trunc(sysdate,'mm') from dual)  group by substr(file_name,8,3), trunc(req_dttm), a.bundle_code, bundle_abbr, bundle_svc_id order by substr(file_name,8,3));
spool off;

EOF

echo "Record Stats for today" | mail -a daily_rec_stats.csv -s "FRG and SDR record stats" marika.hager@optus.com.au Shonali.Patil@optus.com.au matthew.lewis@optus.com.au marika.hager@optiva.com neo.joy@optiva.com

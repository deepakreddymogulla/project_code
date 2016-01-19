/***

Author: Deepak Reddy Mogulla

Script: 		To process incident json data and store json output in Elastic
DataSource: 	Data from ServiceNow
Run Interval:	Every 15 minutes

***/

REGISTER hdfs://sandbox.hortonworks.com:8020/user/root/oozie_scripts/jars/elephant-bird-core-4.1.jar;
REGISTER hdfs://sandbox.hortonworks.com:8020/user/root/oozie_scripts/jars/elephant-bird-pig-4.1.jar;
REGISTER hdfs://sandbox.hortonworks.com:8020/user/root/oozie_scripts/jars/elephant-bird-hadoop-compat-4.1.jar;
REGISTER hdfs://sandbox.hortonworks.com:8020/user/root/oozie_scripts/jars/GetMonthString.jar;
REGISTER hdfs://sandbox.hortonworks.com:8020/user/root/oozie_scripts/jars/GetAgeBucket.jar;
REGISTER hdfs://sandbox.hortonworks.com:8020/user/root/oozie_scripts/jars/elasticsearch-hadoop-2.0.0.jar;

a = LOAD 'hdfs://sandbox.hortonworks.com:8020/user/root/oozie_scripts/json_data.json' USING com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad') as (raw:map[]);

b = FOREACH a GENERATE FLATTEN(raw#'result') as (data:map[]);

c = FOREACH b GENERATE FLATTEN(data#'number') AS number:chararray, FLATTEN(data#'assignment_group') AS assignment_group:chararray, FLATTEN(data#'u_business_service') AS business_service:chararray, FLATTEN(data#'u_configuration_item') AS configuration_item:chararray, FLATTEN(data#'approval') AS approval:chararray, FLATTEN(data#'closed_at') AS closed:chararray, FLATTEN(data#'sys_created_on') AS created:chararray, FLATTEN(data#'business_duration') AS duration:chararray, FLATTEN(data#'u_month') AS month:chararray, FLATTEN(data#'opened_at') AS opened:chararray, FLATTEN(data#'priority') AS priority:int, FLATTEN(data#'severity') AS severity:int, FLATTEN(data#'short_description') AS short_description:chararray, FLATTEN(data#'state') AS state:int, FLATTEN(data#'sys_updated_on') AS updated:chararray, FLATTEN(data#'u_user_name') AS username:chararray, ToString(CurrentTime(),'yyyy-MM-dd HH:mm:ss') AS sys_load_date:chararray;

open_tickets = FILTER c BY closed=='';

close_tickets = FILTER c BY closed!='';



closed_d = FOREACH close_tickets GENERATE SUBSTRING(number,4,11) AS id:chararray, number AS number:chararray, assignment_group, business_service, configuration_item, approval,  ToDate(closed,'yyyy-MM-dd HH:mm:ss') as closed_dt:datetime, ToDate(created,'yyyy-MM-dd HH:mm:ss') as created_dt:datetime, duration, month, ToDate(opened,'yyyy-MM-dd HH:mm:ss') as opened_dt:datetime, priority, severity, short_description, state, ToDate(updated,'yyyy-MM-dd HH:mm:ss') as updated_dt:datetime, username, ToDate(sys_load_date,'yyyy-MM-dd HH:mm:ss') as sys_load_date:datetime;

closed_e = FOREACH closed_d GENERATE id, number, assignment_group, business_service, configuration_item, approval, closed_dt, created_dt, duration, month, opened_dt, priority, severity, short_description, state, updated_dt, username, sys_load_date, GetMonth(closed_dt) AS closed_month:chararray, GetMonth(opened_dt) AS opened_month:chararray,  GetYear(opened_dt) AS opened_year:chararray, GetYear(closed_dt) AS closed_year:chararray, SUBSTRING((chararray)GetYear(opened_dt),2,4) AS half_open_year:chararray, SUBSTRING((chararray)GetYear(closed_dt),2,4) AS half_close_year:chararray, (SecondsBetween(closed_dt, opened_dt)/(long)(3600*24)) AS incident_duration:long;

closed_f = FOREACH closed_e GENERATE id, number, assignment_group, business_service, configuration_item, approval, closed_dt, created_dt, duration, month, opened_dt, priority, severity, short_description, state, updated_dt, username, sys_load_date, CONCAT(getmonthstring.GetMonthString(opened_month),' ',opened_year) AS open_month_year:chararray, CONCAT(getmonthstring.GetMonthString(closed_month),' ',closed_year) AS close_month_year:chararray, CONCAT(getmonthstring.GetMonthString(opened_month),' \'',half_open_year) AS f_open_month_year:chararray, CONCAT(getmonthstring.GetMonthString(closed_month),' \'',half_close_year) AS f_close_month_year, opened_year AS open_year, getmonthstring.GetMonthString(opened_month) AS open_month:chararray, closed_year AS close_year, getmonthstring.GetMonthString(closed_month) AS close_month:chararray, incident_duration, getagebucket.GetIAgeBucket(incident_duration) AS i_age_bucket:chararray, getagebucket.GetSAgeBucket(incident_duration) AS s_age_bucket:chararray;




opened_d = FOREACH open_tickets GENERATE SUBSTRING(number,4,11) AS id:chararray, number AS number:chararray, assignment_group, business_service, configuration_item, approval,  null as closed_dt:datetime, ToDate(created,'yyyy-MM-dd HH:mm:ss') as created_dt:datetime, duration, month, ToDate(opened,'yyyy-MM-dd HH:mm:ss') as opened_dt:datetime, priority, severity, short_description, state, ToDate(updated,'yyyy-MM-dd HH:mm:ss') as updated_dt:datetime, username, ToDate(sys_load_date,'yyyy-MM-dd HH:mm:ss') as sys_load_date:datetime;

opened_e = FOREACH opened_d GENERATE id, number, assignment_group, business_service, configuration_item, approval, closed_dt, created_dt, duration, month, opened_dt, priority, severity, short_description, state, updated_dt, username, sys_load_date, null AS closed_month:chararray, GetMonth(opened_dt) AS opened_month:chararray,  GetYear(opened_dt) AS opened_year:chararray, null AS closed_year:chararray, SUBSTRING((chararray)GetYear(opened_dt),2,4) AS half_open_year:chararray, null AS half_close_year:chararray;

opened_f = FOREACH opened_e GENERATE id, number, assignment_group, business_service, configuration_item, approval, closed_dt, created_dt, duration, month, opened_dt, priority, severity, short_description, state, updated_dt, username, sys_load_date, CONCAT(getmonthstring.GetMonthString(opened_month),' ',opened_year) AS open_month_year:chararray, null AS close_month_year:chararray, CONCAT(getmonthstring.GetMonthString(opened_month),' \'',half_open_year) AS f_open_month_year:chararray, null AS f_close_month_year, opened_year AS open_year, getmonthstring.GetMonthString(opened_month) AS open_month:chararray, closed_year AS close_year,  null AS close_month:chararray, null AS incident_duration:long, 'Open' AS i_age_bucket:chararray, 'Open' AS s_age_bucket:chararray;


union_d = UNION opened_f, closed_f;

/*** STORE union_e INTO 'output2.json' USING JsonStorage(); ***/
STORE union_d INTO 'hdfs://sandbox.hortonworks.com:8020/user/root/oozie_scripts/output' USING PigStorage();

/***
count_chk1 = GROUP union_d ALL;
count_chk2 = FOREACH count_chk1 GENERATE COUNT(union_d);

f1 = FOREACH closed_e GENERATE incident_duration, getagebucket.GetIAgeBucket(incident_duration) AS i_age_bucket:chararray, getagebucket.GetSAgeBucket(incident_duration) AS s_age_bucket:chararray;
***/




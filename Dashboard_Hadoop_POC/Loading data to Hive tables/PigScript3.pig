REGISTER /root/hive_try_local/elephant-bird-core-4.1.jar;
REGISTER /root/hive_try_local/elephant-bird-pig-4.1.jar;
REGISTER /root/hive_try_local/elephant-bird-hadoop-compat-4.1.jar;
REGISTER /root/hive_try_local/GetMonthString.jar;

/*** a = LOAD 'cmdo8.json' USING com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad') as (raw:map[]); ***/
a = LOAD '/root/json_data.json' USING com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad') as (raw:map[]);
b = FOREACH a GENERATE FLATTEN(raw#'result') as (data:map[]);
c = FOREACH b GENERATE FLATTEN(data#'opened_at') AS opened:chararray;
d = FOREACH c GENERATE ToDate(opened,'yyyy-MM-dd HH:mm:ss') as opened_dt:datetime;
e = FOREACH d GENERATE GetMonth(opened_dt) AS opened_month:chararray;
f = FOREACH e GENERATE getmonthstring.GetMonthString(opened_month) AS open_month:chararray;
dump f;
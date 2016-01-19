REGISTER /root/hive_try_local/elephant-bird-core-4.1.jar;
REGISTER /root/hive_try_local/elephant-bird-pig-4.1.jar;
REGISTER /root/hive_try_local/elephant-bird-hadoop-compat-4.1.jar;
REGISTER /root/hive_try_local/GetMonthString.jar;

a = LOAD '/root/json_data.json' USING com.twitter.elephantbird.pig.load.JsonLoader('-nestedLoad') as (raw:map[]);
b = FOREACH a GENERATE FLATTEN(raw#'result') as (data:map[]);
/*** c = FOREACH b GENERATE FLATTEN(data#'skills') AS skills:chararray, FLATTEN(data#'closed_at') AS closed_at:datetime, FLATTEN(data#'number') AS number:chararray, FLATTEN(data#'category') AS category:chararray; ***/
c = FOREACH b GENERATE FLATTEN(data#'number') AS number:chararray, FLATTEN(data#'assignment_group') AS assignment_group:chararray, FLATTEN(data#'u_business_service') AS business_service:chararray, FLATTEN(data#'u_configuration_item') AS configuration_item:chararray, FLATTEN(data#'approval') AS approval:chararray, FLATTEN(data#'closed_at') AS closed:datetime, FLATTEN(data#'sys_created_on') AS created:datetime, FLATTEN(data#'business_duration') AS duration:chararray, FLATTEN(data#'u_month') AS month:chararray, FLATTEN(data#'opened_at') AS opened:datetime, FLATTEN(data#'priority') AS priority:int, FLATTEN(data#'severity') AS severity:int, FLATTEN(data#'short_description') AS short_description:chararray, FLATTEN(data#'state') AS state:int, FLATTEN(data#'sys_updated_on') AS updated:datetime, FLATTEN(data#'u_user_name') AS username:chararray;
describe c;

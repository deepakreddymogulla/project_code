#!/bin/bash

#https://aaaietest2.service-now.com/api/now/table/incident?sysparm_query=assignment_group=b45492c4bd4c810099fcc124cdcb90a4


curl --compressed -H "Accept: application/json" --user hchart:charts123 -X GET https://aaaietest2.service-now.com/api/now/table/incident?sysparm_query=assignment_group=b45492c4bd4c810099fcc124cdcb90a4 > /root/hive_try_local/cron_data_1.json

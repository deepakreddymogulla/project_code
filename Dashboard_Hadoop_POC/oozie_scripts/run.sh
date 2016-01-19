#!/bin/bash
# Shell script to run all the Oozie jobs

# Make sure to delete any old files on HDFS before moving the new ones
echo ---deleting old files
hdfs dfs -rm /user/root/oozie_scripts/*
hdfs dfs -rm /user/root/oozie_scripts/output/*
hdfs dfs -rm /user/root/oozie_scripts/jars/*
#hdfs dfs -rm /user/oozie/share/lib/*

# Place all the files in HDFS
echo ---moving all files to HDFS
hdfs dfs -put /root/hive_try_local/oozie_scripts/json_data.json /user/root/oozie_scripts
hdfs dfs -put /root/hive_try_local/oozie_scripts/jars/* /user/root/oozie_scripts/jars
hdfs dfs -put /root/hive_try_local/oozie_scripts/coord.xml /user/root/oozie_scripts
hdfs dfs -put /root/hive_try_local/oozie_scripts/wf_inci_test.xml /user/root/oozie_scripts
hdfs dfs -put /root/hive_try_local/oozie_scripts/job.properties /user/root/oozie_scripts
hdfs dfs -put /root/hive_try_local/oozie_scripts/PigScript4.pig /user/root/oozie_scripts/
#hdfs dfs -put /root/hive_try_local/oozie_scripts/jars/* /user/oozie/share/lib
#hdfs dfs -put /home/hdfs/oozie_scripts/WF_Split_Files.xml /user/hdfs/oozie_scripts
#hdfs dfs -put /root/Documents/oozie_scripts/* /oozie_scripts 

#Validate coord_job
echo --validating coord
oozie validate /root/hive_try_local/oozie_scripts/coord.xml

#Validate wf_job
echo --validating workflow
oozie validate /root/hive_try_local/oozie_scripts/wf_inci_test.xml

# Run the job 
echo ---running the oozie job 
oozie job -oozie http://192.168.75.134:11000/oozie/ -config /root/hive_try_local/oozie_scripts/job.properties -run

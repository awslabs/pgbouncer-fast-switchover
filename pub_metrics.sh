#!/bin/bash
netstat=$(mktemp)

while true
do
  netstat -an| grep tcp| awk '{print $NF}'|sort | uniq -c | awk '{printf "%s %s\n",$2,$1}' > $netstat
  value=$(cat $netstat | grep ESTABLISHED | awk '{print $2}')
  [[ ! -z "$value" ]] && { metric="ESTABLISHED"; aws cloudwatch put-metric-data --metric-name $metric --namespace pgbouncer --value $value; }

  value=$(cat $netstat | grep LISTEN | awk '{print $2}')
  [[ ! -z "$value" ]] && { metric="LISTEN"; aws cloudwatch put-metric-data --metric-name $metric --namespace pgbouncer --value $value; }

  value=$(cat $netstat | grep TIME_WAIT | awk '{print $2}')
  [[ ! -z "$value" ]] && { metric="TIME_WAIT"; aws cloudwatch put-metric-data --metric-name $metric --namespace pgbouncer --value $value; }

  value=$(cat $netstat | grep SYN_RECV | awk '{print $2}')
  [[ ! -z "$value" ]] && { metric="SYN_RECV"; aws cloudwatch put-metric-data --metric-name $metric --namespace pgbouncer --value $value; }

  value=$(cat $netstat | grep LAST_ACK | awk '{print $2}')
  [[ ! -z "$value" ]] && { metric="LAST_ACK"; aws cloudwatch put-metric-data --metric-name $metric --namespace pgbouncer --value $value ; }

  value=$(cat $netstat | grep CLOSE_WAIT | awk '{print $2}')
  [[ ! -z "$value" ]] && { metric="CLOSE_WAIT"; aws cloudwatch put-metric-data --metric-name $metric --namespace pgbouncer --value $value ; }
  sleep 60
done

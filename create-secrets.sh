#!/bin/sh
KUBE_NAMESPACE="default"
cd `dirname $0`
secret_files=`find . -name "pgbouncer.secrets"`
for file in $secret_files
do
  basename="$(basename $file)"
  kubectl create secret generic "${basename%.*}" --namespace="$KUBE_NAMESPACE" --from-env-file="$file" -o yaml --dry-run=client| tee "${basename%.*}.yml" | kubectl apply -f -
done

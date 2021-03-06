#!/usr/bin/env bash

pod=$(kubectl get pods --all-namespaces -o="name" | grep --invert-match postgres  | grep acme | cut -d "/" -f2)

kubectl delete pod $pod --force --grace-period=0

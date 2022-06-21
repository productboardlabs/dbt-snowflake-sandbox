#!/bin/bash

if [ "$1" == "clean" ]; then
  echo "Running SANDBOX_CLEAN macro"
  dbt run-operation sandbox_clean
  exit $?
fi

echo "Running SANDBOX_MODELS macro"

old="$IFS"
IFS=','
str="$*"
IFS=$old

dbt run-operation sandbox_models --args "{models: [$str]}"

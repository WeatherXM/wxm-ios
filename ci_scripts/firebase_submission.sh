#!/bin/sh
while getopts "p:k:t:" arg; do
  case $arg in
    p) ipa=$OPTARG;;
    k) app_id=$OPTARG;;
    t) token=$OPTARG;;
  esac
done

echo "Starting distribution of IPA to Firebase"
./firebase-tools-macos appdistribution:distribute "${ipa}" --app "${app_id}" --token "${token}" --groups "qa-group"

echo "Upload Symbols"

#!/usr/bin/env bash

rm -rf Info
mkdir -p Info
cd Formula || exit
for formula in *.rb
do
  JSON_INFO=$(brew info --json "${formula}")
  echo "${JSON_INFO}" | jq '.[0]? // .' >../Info/"${formula/%rb/json}"
done
git add -A
git commit -m "Update JSON info"

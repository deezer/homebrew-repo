#!/usr/bin/env bash

rm -rf Info
mkdir -p Info
cd Formula
for formula in *.rb; do
    brew info --json "$formula" | jq '.[0]? // .' > ../Info/${formula/%rb/json}
done
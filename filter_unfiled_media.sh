#!/usr/bin/env bash

sort -k2 <(echo $1 | tr " " "\n" | nl) <(echo $2| tr " " "\n" | nl) \
  | uniq -uf1 \
  | awk '{print $1}'

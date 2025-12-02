#!/usr/bin/env bash
i="$1"
o="dist/${i#src/}"
perl -pe 's/\s*#.*$//g; s/(?<!;)\n//g; s/;$//g; s/\t//g' "$i" > "$o"
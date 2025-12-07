#!/usr/bin/env bash
shopt -s expand_aliases
alias yq="yq --yaml-fix-merge-anchor-to-spec=true"
i="$1"
o="dist/${1#src/}"
o="${o%.yml}"
case "${1#*.}" in
	yml)o="$o.json";;
	*);;
esac
yq -p yaml -o json "$i" > "$o"
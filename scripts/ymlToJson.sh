#!/usr/bin/env bash
shopt -s expand_aliases
alias yq="yq --yaml-fix-merge-anchor-to-spec=true"
i="$1"
o="dist/${i#src/}"
case "${i#*.}" in
	yml)o="${o%.yml}.json";;
	mcmeta.yml)o="${o%.yml}";;
	*);;
esac
yq -p yaml -o json "$i" > "$o"
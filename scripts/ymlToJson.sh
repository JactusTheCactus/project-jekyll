#!/usr/bin/env bash
i="$1"
o="dist/${i#src/}"
case "${i#*.}" in
	yml)o="${o%.yml}.json";;
	mcmeta.yml)o="${o%.yml}";;
	*);;
esac
yq -p yaml -o json "$i" > "$o"
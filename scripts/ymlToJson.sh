#!/usr/bin/env bash
shopt -s expand_aliases
alias yq="yq --yaml-fix-merge-anchor-to-spec=true"
yq -p yaml -o json "$1" > "$(
	o="dist/${1#src/}"
	o="${o%.yml}"
	case "${1#*.}" in
		yml)echo "$o.json";;
		*)echo "$o";;
	esac
)"
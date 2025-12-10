#!/usr/bin/env bash
shopt -s expand_aliases
alias yq="yq --yaml-fix-merge-anchor-to-spec=true"
exec >> logs/yml.log 2>& 1
if ! grep -qw "$(echo "$1" | perl -pe 's|\./(.*?)\.yml|$1|g')" .ymlignore
	then yq -p yaml -o json "$1" \
		| jq -c "." \
		> "$(echo "$1" | perl -pe '
			s|src|dist|g;
			s|yml|json|g;
			s|(\.\w+)\.json|$1|g;
		')"
fi
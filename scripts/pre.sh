#!/usr/bin/env bash
set -euo pipefail
shopt -s expand_aliases
alias yq="yq --yaml-fix-merge-anchor-to-spec=true"
exec > "logs/pre.log" 2>& 1
data="$(yq -p yaml -o json "data.yml" | jq "del(.[0])")"
echo "$data" | jq -c ".[]" | while read -r m; do
	m="$(echo "$m" | jq --tab ".")"
	re=(
		's/"\]/",1]/g'
		's/,(\d)/, $1/g'
		's/0/true/g'
		's/1/false/g'
	)
	r=""
	for i in "${re[@]}"; do
		r+="$i;"
	done
	a="$(echo "$m" \
		| jq ".abilities" \
		| jq ". |= map(tojson)" \
		| perl -pe "$r" \
	)"
	g=""
	g_="$(echo "$m" | jq -r ".blood")"
	if [[ "$g_" = "null" ]]; then
		g_="$(echo "$m" | jq -r ".name")"
	fi
	g+="custom_name=\"$g_ Blood\","
	g_="$(echo "$m" | jq -c ".desc")"
	if [[ "$g_" != "null" ]]; then
		g+="lore=$g_,"
	fi
	g_="$(echo "$m" | jq -r ".name")"
	g+="custom_model_data={$( \
		echo strings:[${g_,,}] \
	)},"
	g+="consumable={consume_seconds:0}"
	t_="$(echo "$m" | jq -r ".name")"
	t="dist/datapacks/Project: Jekyll/data/jekyll/function/mob/${t_,,}/give.mcfunction"
	d="give @p minecraft:dragon_breath[$g]"
	re=(
		's/\w+=(?:\[\]|\{\}|""),//g'
	)
	r=""
	for i in "${re[@]}"; do
		r+="$i;"
	done
	echo "$(echo "give @p minecraft:dragon_breath[$g]" \
		| perl -pe "$r" \
	)" > "$t"
done
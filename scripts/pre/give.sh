#!/usr/bin/env bash
set -euo pipefail
shopt -s expand_aliases
alias yq="yq --yaml-fix-merge-anchor-to-spec=true"
exec > "logs/pre.log" 2>& 1
get() {
	echo "$1" | jq -r ".${2:-}"
}
void() {
	if [[ "$1" = "null" ]]
		then echo "${2:-N/A}"
		else echo "$1"
	fi
}
yq data/data.yml \
		-p yaml \
		-o json \
		| jq -c ".[]" \
		| while read -r m
do
	m="$(echo "$m" | jq --tab ".")"
	t="dist/datapacks/Project: Jekyll/data/jekyll/function/mob/$(
		t_="$(echo "$m" | jq -r ".name")"
		echo "${t_,,}"
	)/give.mcfunction"
	echo "give @p minecraft:dragon_breath[custom_name=\"$(
		g_="$(get "$m" "blood")"
		void "$(echo "$m" | jq -r ".blood")" "$(echo "$m" | jq -r ".name")"
	) Blood\",$(
		g_="$(echo "$m" | jq -c ".desc")"
		if [[ "$g_" != "null" ]]
			then echo "lore=$g_,"
		fi
	)custom_model_data={$(
		g_="$(echo "$m" | jq -r ".name")"
		echo "strings:[${g_,,}]"
	)},consumable={consume_seconds:0}]" > "dist/datapacks/Project: Jekyll/data/jekyll/function/mob/$(
		t_="$(echo "$m" | jq -r ".name")"
		echo "${t_,,}"
	)/give.mcfunction"
done
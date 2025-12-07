#!/usr/bin/env bash
shopt -s expand_aliases
alias yq="yq --yaml-fix-merge-anchor-to-spec=true"
exec > logs/pre.log 2>& 1
data="$(yq -p yaml -o json data.yml | jq "del(.[0])")"
echo "$data" | jq -c '.[]' | while read -r i; do
	echo "$i" | jq -c '.' | while read -r m; do
		m="$(echo "$m" | jq --tab .)"
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
		re=(
			's/"\[/[/g'
			's/\]"/]/g'
			's/\\"/"/g'
		)
		r=""
		for i in "${re[@]}"; do
			r+="$i;"
		done
		m="$(echo "$m" \
			| jq ".abilities = $a" \
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
		g+="custom_model_data={strings:[${g_,,}]},"
		g+="consumable={consume_seconds:0}"
		t="dist/"
		t+="datapacks/"
		t+="Project: Jekyll/"
		t+="data/"
		t+="jekyll/"
		t+="function/"
		t+="mob/"
		t_="$(echo "$m" | jq -r ".name")"
		t+="${t_,,}/"
		t+="give.mcfunction"
		echo "give @p minecraft:dragon_breath[$g]" > "$t"
	done
done
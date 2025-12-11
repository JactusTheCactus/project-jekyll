#!/usr/bin/env bash
set -euo pipefail
shopt -s expand_aliases
alias yq="yq --yaml-fix-merge-anchor-to-spec=true"
exec > "logs/pre/init.log" 2>& 1
get() {
	echo "$1" | jq -r ".${2:-}"
}
void() {
	if [[ "$1" = "null" ]]
		then echo "${2:-N/A}"
		else echo "$1"
	fi
}
yq data/data.yml -p yaml -o json | jq -c ".[]" | while read -r m
	do
		echo "$(
			echo "$m" | jq -c ".effects[]" | while read -r e
				do
					echo "effect give @s minecraft:$(
						echo "$e" | jq -r ".[0]"
					) infinite $(
						echo "$e" | jq ".[1] // 99"
					) true"
			done
			echo "effect give @s minecraft:instant_health 10 99 true"
			echo "$m" | jq -c ".gear[]?" | while read -r g
				do
					echo "item replace entity @p $(
						echo "$g" | jq -r ".slot"
					) with $(
						echo "$g" | jq -r ".item"
					)[$(
						echo "$g" | jq ".enchantments += [\"minecraft:enchantments={binding_curse:1}\"]" | jq ".enchantments[]" | while read -r n
							do printf "%s," $(echo "$n" | jq -r ".")
						done | perl -pe 's|,$||'
					)"]
			done
			name="$(echo "$m" | jq -r ".name")"
			echo "advancement revoke @s only jekyll:$name $name"
			echo "title @p title \"You are now a $(echo "$name" | perl -pe 's|^(.)(.*)$|\u$1\L$2|g')\""
		)" > "dist/datapacks/Project: Jekyll/data/jekyll/function/mob/$(
			echo "$m" | jq -r ".name" | perl -pe 's|(.*)|\L$1|g'
		)/init.mcfunction"
done
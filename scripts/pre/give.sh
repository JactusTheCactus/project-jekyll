#!/usr/bin/env bash
set -euo pipefail
yml() {
	yq \
		--yaml-fix-merge-anchor-to-spec=true \
		"$@"
}
exec > "logs/pre/give.log" 2>& 1
get() {
	echo "$1" | jq -r ".${2:-}"
}
void() {
	if [[ "$1" = "null" ]]
		then echo "${2:-}"
		else echo "$1"
	fi
}
yml data/data.yml -p yaml -o json \
	| jq -c ".[]" \
	| while read -r m
do echo "give @p minecraft:dragon_breath[custom_name=\"$(
	void "$(get "$m" "blood")" "$(get "$m" "name")" \
		| perl -pe 's|\b(\w)|\u$1|g'
) Blood\",lore=$(echo "$m" | jq -c ".desc"),custom_model_data={strings:[$(get "$m" "name")]},consumable={consume_seconds:0}]" \
	| perl -pe 's|lore=null,||g' \
	> "dist/datapacks/Project: Jekyll/data/jekyll/function/mob/$(get "$m" "name")/give.mcfunction"
done
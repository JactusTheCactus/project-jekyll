#!/usr/bin/env bash
set -euo pipefail
shopt -s expand_aliases
alias yq="yq --yaml-fix-merge-anchor-to-spec=true"
exec > README.md
cat << EOF
# Project: Jekyll
\`Project: Jekyll\` is a datapack for \`Minecraft: Java Edition 1.21.10\`.
The end-goal is to add many monsters to The game, along with drops that the player consumes to gain their abilities.
## Features
- [ ] Monsters
- [x] Items that give the powers of monsters
## Monsters
EOF
DATA="$(yq -p yaml -o json data.yml | jq "del(.[0])")"
echo "$DATA" | jq -c '.[]' | while read -r i; do
	void() {
		else="${2:-null}"
		in="$(echo "$i" | jq -r .$1)"
		if [[ "$in" = "null" ]]; then
			out="$else"
		else
			out="$in"
		fi
		echo "$out"
	}
	name="$(echo "$i" | jq -r ".name")"
	mob="$(echo "$i" | jq -r ".mob")"
	case $mob in
		0)mob="x";;
		*)mob=" ";;
	esac
	base="$(void base)"
	title="- [$mob] $name"
	if [[ "$base" != "null" ]]; then
		title+=" (Based off of \`$base\`)"
	fi
	echo $title
	blood="$(void blood $name)"
	echo -e "\t- \`$blood Blood\`"
	abilities="$(echo "$i" | jq -r ".abilities")"
	echo "$abilities" | jq -c '.[]' | while read -r ability; do
		echo -e "\t\t- $ability"
	done
done
cat << EOF
## Use
Currently, as there are no mobs to drop these items, they are given at the start.
If they aren't, \`/reload\` will clear your inventory / potion effects & give the items
***
## Notes
The name, \`Project: Jekyll\`, comes from \`The Strange Case of Dr. Jekyll & Mr. Hyde\`
EOF
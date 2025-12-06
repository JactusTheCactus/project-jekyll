#!/usr/bin/env bash
set -euo pipefail
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
DATA="$(yq -p yaml -o json data.yml)"
DATA="$(echo "$DATA" | jq "del(.[0])")"
echo "$DATA" | jq -c '.[]' | while read -r i; do
	name="$(echo "$i" | jq -r ".name")"
	mob="$(echo "$i" | jq -r ".mob")"
	case $mob in
		true)mob="x";;
		false)mob=" ";;
	esac
	base="$(echo "$i" | jq -r ".base")"
	if [[ -z $base ]]; then
		base=N/A
	fi
	echo "- [$mob] $name (Based off of \`$base\`)"
	blood="$(echo "$i" | jq -r ".blood")"
	echo -e "\t- \`$blood Blood\`"
	abilities="$(echo "$i" | jq -r ".abilities")"
	echo "$abilities" | jq -c '.[]' | while read -r a; do
		ability="$(echo "$a" | jq -r ".[0]")"
		complete="$(echo "$a" | jq -r ".[1]")"
		case $complete in
			true)complete="x";;
			*)complete=" ";;
		esac
		echo -e "\t\t- [$complete] $ability"
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
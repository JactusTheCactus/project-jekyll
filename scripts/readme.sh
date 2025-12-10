#!/usr/bin/env bash
set -euo pipefail
yml() {
	yq --yaml-fix-merge-anchor-to-spec=true "$@"
}
exec > logs/readme.log 2>& 1
el() {
	e=${1:-span}
	t=${@:2}
	id=""
	while [[ $e =~ '#' ]]
		do
			id=$(echo $e | perl -nE 'say $1 if /#([\w\d]*\b)/')
			e=$(echo $e | perl -pe 's|#[\w\d]*\b||')
	done
	classes=()
	while [[ $e =~ '.' ]]
		do
			classes+=($(echo $e | perl -nE 'say $1 if /\.([\w\d]*\b)/'))
			e=$(echo $e | perl -pe 's|\.[\w\d]*\b||')
	done
	e=${e:-span}
	tag="$(echo "<$e id=\"$id\" class=\"${classes[@]}\">" | perl -pe '
		s/\s*(?:id|class)=""//g')$t</$e>"
	case $e in
		br|hr)o="<$e/>";;
		html)o="<!DOCTYPE html>$tag";;
		*)o=$tag;;
	esac
	echo -n $o
}
void() {
	if [[ -z ${2++} ]]
		then [[ $1 != null ]] || return 1
		else
			if [[ $1 != null ]]
				then echo $1
				else echo $2
			fi
	fi
}
get() {
	echo "$1" | jq -r .$2
}
cap() {
	perl -pe 's|\b(\w)(\w*)\b|\u$1\L$2|g'
}
md() {
	perl -pe '
		s/\s*(?:id|class)=".*?"\s*//g;
		s|<(span)>(.*?)</\1>|$2|g;
	'
}
title="Project: Jekyll"
body=$(
	el h1 $title
	el p $(el q.title $title) is a datapack for $(el q Minecraft: Java Edition 1.21.10). The end-goal is to add many monsters to the game, along with drops that the player consumes to gain their abilities.
	el h2 Features
	el ul $(
		el li Monsters
		el li Items that give the powers of monsters
	)
	el h2 Monsters
	el dl $(
		yml data/data.yml -p yaml -o json \
			| jq -c .[] \
			| while read -r i
		do
			el div.monster $(
				name=$(get "$i" name | cap)
				base=$(get "$i" base | cap)
				blood=$(void $(get "$i" blood) $name | cap)
				abilities=$(get "$i" abilities[] | cap)
				el dt.name $name
				if void "$base"
					then el dd.base Based off of $(el .mob $base)
				fi
				el dd.blood $(void $blood $name) Blood
				el dd.abilities $(el ul $(echo "$abilities" | while read -r ability
					do el li.ability $ability
				done))
			)
		done
	)
	el h2 Use
	el p Currently, as there are no mobs to drop these items, they are given at the start. If they "aren't," $(el code /reload) will clear your inventory / potion effects "&" give the items
	el h2 Notes
	el p The name, $(el q.title $title,) comes from $(el q The Strange Case of Dr. Jekyll "&" Mr. Hyde)
)
el html $(
	el head $(
		el title $title
		el style $(npx sass style.scss --style=compressed)
	)
	el body $body
) > index.html
echo $body | md > README.md
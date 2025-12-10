#!/usr/bin/env bash
set -euo pipefail
shopt -s expand_aliases
flag() {
	for f in "$@"
		do [[ -e ".flags/$f" ]] || return 1
	done
}
find src \( -name "*.json" -o -name "*.mcmeta" \) -delete
NAME="Project: Jekyll"
DIRS=(
	dist
	logs
	logs/trees
)
DOCS=src/main/docs
LOG=logs/mc.log
for i in "${DIRS[@]}"
	do
		rm -rf "$i" || :
		mkdir -p "$i"
done
find . -name "*.json" -delete
exec > "$LOG" 2>& 1
alias yq="yq --yaml-fix-merge-anchor-to-spec=true"
alias tree="tree -F"
script() {
	./scripts/$1.sh "${@:2}"
}
for i in src/*
	do cp -r "$i" dist
done
script pre/give
find . -name "*.yml" -print0 | while IFS= read -r -d '' f
	do script ymlToJson "$f"
done
find dist -name "*.yml" -delete
if flag local
	then
		MC="$HOME/.minecraft"
		ROOT="$MC/saves/Project_ Jekyll"
		V="1.21.10"
		VER="$MC/versions/$V/$V"
		copyTexture() {
			cp \
				"$VER/assets/minecraft/textures/item/$1.png" \
				"dist/resourcepacks/$NAME/assets/minecraft/textures/item/${2:-$1}.png"
		}
		cp -r "$VER.jar" "$VER.zip"
		unzip -o "$VER.zip" -d "$VER" > /dev/null
		rm "$VER.zip"
		EGGS=(
			"blaze|demon"
			"bat|dhampir"
			"dolphin|mermaid"
			"wolf|wirwulf"
		)
		for n in "${EGGS[@]}"
			do copyTexture "${n%%|*}_spawn_egg" "${n##*|}"
		done
		copyTexture dragon_breath
		rm -r "$VER"
		find "$ROOT/datapacks" -maxdepth 1 -mindepth 1 -exec rm -r {} \;
		cp -r dist/datapacks/* "$ROOT/datapacks/"
		cp -r dist/resourcepacks/* "$MC/resourcepacks"
fi
find dist -empty -delete
for i in data resource
	do (
		cd "dist/${i}packs"
		tree "$NAME" -o "../../logs/trees/$i.tree"
	)
done
script readme
find logs -empty -delete
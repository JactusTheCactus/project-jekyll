#!/usr/bin/env bash
set -euo pipefail
shopt -s expand_aliases
flag() {
	for f in "$@"; do
		[[ -e ".flags/$f" ]] || return 1
	done
}
NAME="Project: Jekyll"
DIRS=(
	dist
	logs
	logs/trees
)
DOCS=src/main/docs
LOG=logs/mc.log
for i in "${DIRS[@]}"; do
	rm -rf "$i" || :
	mkdir -p "$i"
done
exec > $LOG 2>& 1
alias yq="yq --yaml-fix-merge-anchor-to-spec=true"
alias tree="tree -F"
for f in scripts/*; do
	f="${f#scripts/}"
	f="${f%.sh}"
	s=./scripts/$f.sh
	chmod +x $s
	eval "$f=$s"
done
for i in src/*; do
	cp -r $i dist
done
$pre
find src -name "*.yml" -exec $ymlToJson {} \;
find dist -name "*.yml" -delete
copyTexture() {
	cp \
		"$HOME/.minecraft/versions/1.21.10/1.21.10/assets/minecraft/textures/item/$1.png" \
		"dist/resourcepacks/Project: Jekyll/assets/minecraft/textures/item/${2:-$1}.png"
}
if flag local; then
	MC="$HOME/.minecraft"
	ROOT="$MC/saves/Project_ Jekyll"
	VER="$MC/versions/1.21.10/1.21.10"
	cp -r "$VER.jar" "$VER.zip"
	unzip -o "$VER.zip" -d "$VER" > /dev/null
	rm "$VER.zip"
	EGGS=(
		"blaze|demon"
		"bat|dhampir"
		"dolphin|mermaid"
		"wolf|wirwulf"
	)
	for n in "${EGGS[@]}"; do
		copyTexture "${n%%|*}_spawn_egg" "${n##*|}"
	done
	copyTexture dragon_breath
	rm -r "$VER"
	find "$ROOT/datapacks" -maxdepth 1 -mindepth 1 -exec rm -r {} \;
	cp -r dist/datapacks/* "$ROOT/datapacks/"
	cp -r dist/resourcepacks/* "$MC/resourcepacks"
fi
find dist -empty -delete
for i in data resource; do
	(
		cd "dist/${i}packs"
		tree "$NAME" -o "../../logs/trees/$i.tree"
	)
done
$readme
find logs -empty -delete
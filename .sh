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
)
DOCS=src/main/docs
LOG=logs/mc.log
for i in "${DIRS[@]}"; do
	rm -rf "$i" || :
	mkdir -p "$i"
done
exec > $LOG 2>& 1
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
find src -name "*.yml" -exec $ymlToJson {} \;
find dist -name "*.yml" -delete
if flag local; then
	MC="$HOME/.minecraft"
	ROOT="$MC/saves/Project_ Jekyll"
	VER="$MC/versions/1.21.10/1.21.10"
	cp -r "$VER.jar" "$VER.zip"
	unzip -o "$VER.zip" -d "$VER" > /dev/null
	rm "$VER.zip"
	EGGS=(
		"blaze|demon"
		"evoker|dhampir"
		"wolf|werewolf"
	)
	for n in "${EGGS[@]}"; do
		i="${n%%|*}_spawn_egg"
		o="${n##*|}"
		$copyTextures "$i" "$o"
	done
	rm -r "$VER"
	cp -r dist/datapacks/* "$ROOT/datapacks/"
	cp -r dist/resourcepacks/* "$MC/resourcepacks"
fi
find dist -empty -delete
for i in data resource; do
	(
		cd "dist/${i}packs"
		tree "$NAME" -F
	) > logs/$i.log
done
$README
if ! [[ -s $LOG ]]; then
	rm $LOG
	touch logs/.gitkeep
fi
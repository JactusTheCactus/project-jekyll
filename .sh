#!/usr/bin/env bash
set -euo pipefail
shopt -s expand_aliases
flag() {
	for f in "$@"; do
		[[ -e ".flags/$f" ]] || return 1
	done
}
DIRS=(
	dist
	logs
)
DOCS=src/main/docs
ROOT="$HOME/.minecraft/saves/Project_ Jekyll"
for i in "${DIRS[@]}"; do
	rm -rf "$i" || :
	mkdir -p "$i"
done
exec > logs/mc.log 2>& 1
for f in scripts/*; do
	f="${f#scripts/}"
	f="${f%.sh}"
	eval "$f=./scripts/$f.sh"
done
for i in src/*; do
	cp -r $i dist
done
find src \
	-name "*.yml" \
	-exec $ymlToJson {} \;
find src \
	-name "*.mcfunction" \
	-exec $mcfuncFMT {} \;
find dist \
	-type f \
	-name "*.yml" \
	-exec rm {} \;
if flag local; then
	find "$ROOT/datapacks" -type f -exec rm {} \;
	cp -r dist/* "$ROOT/datapacks/"
fi
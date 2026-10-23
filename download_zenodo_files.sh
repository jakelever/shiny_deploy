#!/bin/bash
# Download files from a Zenodo record into a directory, uncompressing any that are gzipped.
# usage: download_zenodo_files.sh record.json outdir name1.tsv [name2.tsv ...]
# record.json is the Zenodo API response for the record (e.g. /api/records/<concept id>, which
# redirects to the latest version). Each name matches a file in the record either as is or with .gz.
set -euo pipefail

record=$1
outdir=$2
shift 2

id=$(jq -r '.id' $record)
modified=$(jq -r '.modified' $record)
echo "Using Zenodo record $id (modified $modified)"

for name in "$@"; do
	key=$(jq -r --arg n "$name" '.files[].key | select(. == $n or . == ($n + ".gz"))' $record | head -n 1)
	if [ -z "$key" ]; then
		echo "ERROR: $name not found in Zenodo record $id"
		exit 1
	fi

	curl -fL -o $outdir/$key https://zenodo.org/records/$id/files/$key
	if [[ $key == *.gz ]]; then
		gunzip -f $outdir/$key
	fi
	touch -d "$modified" $outdir/$name
done

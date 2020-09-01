#!/bin/bash

set -e

function debug() {
	if [[ -n "${DEBUG}" ]]; then
		echo "$@"
	fi
}

TMP_DIR="/var/tmp/encode.$$.$RANDOM"
debug "Using '${TMP_DIR}' for temporary output"
function cleanup {
	debug "Removing temporary files"
	rm -rf "${TMP_DIR}"
}

trap handle_hup SIGHUP
trap handle_int SIGINT

DROP="./test"
if [[ -d "${1}" ]]; then
	DROP="${1}"
fi
debug "Looking for files in '${DROP}'"

DEST="./dest"
if [[ -d "${2}" ]]; then
	DEST="${2}"
fi
debug "Files will be moved to '${DEST}'"

function setvars() {
	local stashed_dir="$(pwd)"
	cd ${DROP}
	local dir="$(dirname "${1:2}")"
	local name="$(basename "${1}")"
	INPUT_FILE="${dir}/${name}"
	TEMP_FILE="${TMP_DIR}/${dir}/${name}"
	OUTPUT_FILE="${DEST}/${dir}/${name}"
	cd "${stashed_dir}"
}

function doencode() {
	debug "transcode '${INPUT_FILE}' -> '${TEMP_FILE}'"
	debug "mv '${TEMP_FILE}' '${OUTPUT_FILE}'"
}

find ${DROP} -type f | while read filename; do
	setvars "${filename}"
	doencode
done

cleanup


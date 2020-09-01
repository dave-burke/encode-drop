#!/bin/bash

set -e

function debug() {
	if [[ -n "${DEBUG}" ]]; then
		echo "$@"
	fi
}

TMP_DIR="/var/tmp/encode.$$.$RANDOM"
debug "Using '${TMP_DIR}' for temporary output"
mkdir -p "${TMP_DIR}"

function cleanup {
	debug "Removing temporary files"
	rm -rf "${TMP_DIR}"
}

trap cleanup SIGHUP SIGINT
if [[ -z "${DEBUG}" ]]; then
	trap cleanup ERR
fi

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

function init() {
	debug "***** INIT ${1} *****"
	local dir="$(dirname "${1#${DROP}/}")"
	local name="$(basename "${1}")"

	INPUT_FILE="${DROP}/${dir}/${name}"

	mkdir -p "${TMP_DIR}/${dir}"
	TEMP_FILE="${TMP_DIR}/${dir}/${name}"


	mkdir -p "${DEST}/${dir}"
	OUTPUT_FILE="${DEST}/${dir}/${name}"
}

function doencode() {
	debug "***** ENCODE ${INPUT_FILE} *****"
	cp -v "${INPUT_FILE}" "${TEMP_FILE}"
}

function finalize() {
	debug "***** FINALIZE ${INPUT_FILE} *****"
	mv -v "${TEMP_FILE}" "${OUTPUT_FILE}"
	rm -v "${INPUT_FILE}"
}

find ${DROP} -type f | while read filename; do
	init "${filename}"
	doencode
	finalize
done

cleanup


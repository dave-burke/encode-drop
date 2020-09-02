#!/bin/bash

set -e

function debug() {
	if [[ -n "${DEBUG}" ]]; then
		echo "$@"
	fi
}

function usage() {
	echo "$(basename ${0})" [input dir] [output dir] [flags]
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

if [[ -d "${1}" ]]; then
	DROP="${1}"
	shift
else
	usage && exit 1
fi
debug "Looking for files in '${DROP}'"

if [[ -d "${1}" ]]; then
	DEST="${1}"
	shift
else
	usage && exit 1
fi
debug "Files will be moved to '${DEST}'"

ARGS=$@

function init() {
	local dir="$(dirname "${1#${DROP}/}")"
	local name="$(basename "${1}")"

	INPUT_FILE="${DROP}/${dir}/${name}"

	mkdir -p "${TMP_DIR}/${dir}"
	TEMP_FILE="${TMP_DIR}/${dir}/${name}"


	mkdir -p "${DEST}/${dir}"
	OUTPUT_FILE="${DEST}/${dir}/${name}"

	debug "* INPUT  ${INPUT_FILE}"
	debug "* TEMP   ${TEMP_FILE}"
	debug "* OUTPUT ${OUTPUT_FILE}"
}

if type doencode > /dev/null; then
	debug "Using hooked doencode function"
else
	function doencode() {
		transcode --output "${TEMP_FILE}" --add-subtitle=all $ARGS "${INPUT_FILE}"
	}
fi

function finalize() {
	mv -v "${TEMP_FILE}" "${OUTPUT_FILE}"
	rm -v "${INPUT_FILE}"
}

find ${DROP} -type f | while read filename; do
	init "${filename}"
	doencode
	finalize
done

cleanup


detective() {
	if (( $# < 2 )); then
		echo 'Usage: detective COMMAND [ARGUMENTS...] EVIDENCE_FILE' >&2
		return 2
	fi

	local evidence="${!#}"
	local -a command=( "${@:1:$#-1}" )

	(
		printf '\ns '
		printf '%q ' "${command[@]}"
		printf '\n'

		if "${command[@]}"; then
			result=0
		else
			result=$?
		fi

		printf '\n[exit status: %d]\n' "$result"
		exit "$result"
	) 2>&1 | tee -a -- "$evidence"

	local -a statuses=( "${PIPESTATUS[@]}" )
	if (( statuses[0] !=0 )); then
		return "${statuses[0]}"
	fi
	return "${statuses[1]}"
}

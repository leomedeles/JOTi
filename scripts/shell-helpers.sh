JOTI_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

labpython() {
	if (( $# < 1 )); then
		echo "Usage: labpython NAMESPACE [PYTHON_ARGUMENTS...]" >&2
		return 2
	fi

	local namespace="$1"
	shift
	
	sudo ip netns exec "$namespace" \
		"$JOTI_ROOT/.venv/bin/python" "$@"
}

source "$JOTI_ROOT/scripts/detective.sh"

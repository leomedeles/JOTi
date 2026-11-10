#!/usr/bin/env bash
set -euo pipefail

# Network changes require root.
if [[ $EUID -ne 0 ]]; then
	echo "Run this script with sudo."
	exit 1
fi

namespaces=(ot-client ot-other ot-field ot-fw)
bridge="br-ot-ops"
busy=0

# Inspect every existing namespace before deleting anything.
for ns in "${namespaces[@]}"; do
    [[ -e "/run/netns/$ns" ]] || continue

    if ! pids=$(ip netns pids "$ns"); then
        echo "Could not inspect $ns; stopping." >&2
        exit 1
    fi

    if [[ -n "$pids" ]]; then
        echo "Processes are still running inside $ns:" >&2
        printf '%s\n' "$pids" >&2
        busy=1
    fi
done

if (( busy )); then
    echo "Stop those processes and retry. Nothing was deleted." >&2
    exit 1
fi

for ns in "${namespaces[@]}"; do
    if [[ -e "/run/netns/$ns" ]]; then
        ip netns delete "$ns" || exit 1
    fi
done

if ip link show dev "$bridge" >/dev/null 2>&1; then
    ip link delete dev "$bridge" type bridge || exit 1
fi

remaining=0

for ns in "${namespaces[@]}"; do
    if [[ -e "/run/netns/$ns" ]]; then
        echo "Cleanup incomplete: namespace $ns remains." >&2
        remaining=1
    fi
done

if ip link show dev "$bridge" >/dev/null 2>&1; then
    echo "Cleanup incomplete: bridge $bridge remains." >&2
    remaining=1
fi

if (( remaining )); then
    exit 1
fi

echo "Cleanup complete: all four lab namespaces and the bridge are absent."

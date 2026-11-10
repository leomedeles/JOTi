#!/usr/bin/env bash
set -euo pipefail

# Network changes require root.
if [[ $EUID -ne 0 ]]; then
	echo "Run this script with sudo."
	exit 1
fi

# Refuse to build over an existing lab.
for ns in ot-fw ot-client ot-other ot-field; do
	if [[ -e "/run/netns/$ns" ]]; then
		echo "Namespace $ns already exists. Stoping."
		exit 1
	fi
done

for interface in br-ot-ops fw-field field-fw \
	fw-ops sw-fw client-ops sw-client other-ops sw-other; do
	if ip link show dev "$interface" >/dev/null 2>&1; then
		echo "Interface $interface already exists. Stopping."
		exit 1
	fi
done

# Create the simulated computers and their internal loopback paths.
for ns in ot-fw ot-client ot-other ot-field; do
	ip netns add "$ns"
	ip -n "$ns" link set lo up
done

# Create the field cable and place its ends
ip link add fw-field type veth peer name field-fw
ip link set fw-field netns ot-fw
ip link set field-fw netns ot-field
ip -n ot-fw link set fw-field up
ip -n ot-field link set field-fw up

# Create the operations switch (bridge).
ip link add br-ot-ops type bridge
ip link set br-ot-ops up

# Connect the router and both clients to the switch.
for role in fw client other; do
	ip link add "$role-ops" type veth peer name "sw-$role"
	ip link set "$role-ops" netns "ot-$role"
	ip link set "sw-$role" master br-ot-ops
	ip link set "sw-$role" up
	ip -n "ot-$role" link set "$role-ops" up
done

# Assign interface addresses
ip -n ot-fw addr add 10.77.20.1/24 dev fw-ops
ip -n ot-fw addr add 10.77.40.1/24 dev fw-field
ip -n ot-client addr add 10.77.20.10/24 dev client-ops
ip -n ot-other addr add 10.77.20.20/24 dev other-ops
ip -n ot-field addr add 10.77.40.11/24 dev field-fw

# Give endpoints directions to the opposite subnet.
ip -n ot-client route add 10.77.40.0/24 via 10.77.20.1
ip -n ot-other route add 10.77.40.0/24 via 10.77.20.1
ip -n ot-field route add 10.77.20.0/24 via 10.77.40.1

# Locate firewall.nft relative to this script.
FIREWALL_FILE="$(dirname -- "$0")/../firewall.nft"

# Keep forwarding disabled until the firewall loads successfully.
ip netns exec ot-fw sysctl -w net.ipv4.ip_forward=0

if ! ip netns exec ot-fw nft -f "$FIREWALL_FILE"; then
    echo "Firewall loading failed; IPv4 forwarding remains disabled." >&2
    exit 1
fi

# Allow the router to pass IPv4 pacjets between interfaces
ip netns exec ot-fw sysctl -w net.ipv4.ip_forward=1

echo "Network created. Modbus server is not started."

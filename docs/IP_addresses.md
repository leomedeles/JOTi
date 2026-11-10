| Device / namespace | Interface | IPv4 address | Purpose |
|---|---|---|---|
| Other / `ot-other` | `other-ops` | `10.77.20.20/24` | Unauthorized client |
| Client / `ot-client` | `client-ops` | `10.77.20.10/24` | Modbus client |
| Router / `ot-fw` | `fw-ops` | `10.77.20.1/24` | Router interface toward client |
| Router / `ot-fw` | `fw-field` | `10.77.40.1/24` | Router interface toward field device |
| Field device / `ot-field` | `field-fw` | `10.77.40.11/24` | Modbus server, TCP port 502 |

| Device | Destination network | Next hop | Outgoing interface |
|---|---|---|---|
| Other | `10.77.40.0/24` | `10.77.20.1` | `other-ops` |
| Client | `10.77.40.0/24` | `10.77.20.1` | `client-ops` |
| Router | `10.77.20.0/24` | Directly connected | `fw-ops` |
| Router | `10.77.40.0/24` | Directly connected | `fw-field` |
| Field device | `10.77.20.0/24` | `10.77.40.1` | `field-fw` |
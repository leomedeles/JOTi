# Routed Modbus lab validation

Verified after deleating and rebuilding all lab namespaces and the bridge:
- network-up.sh recreated the topology succesfully.
- firewall.nft loaded sucessfully inside ot-fw
- ot-client read modbus registers
- ot-other could not connect to modbus server
- ot-other could still ping the field device

Current firewall policy: accept by default, with one explicit block for ot-other accessing 10.77.40.11 on TCP 502.

## Allowlist verification

Replaced initial blacklist with a default-drop forwarding policy

verified:
- ot-client can read Modbus registers
- ot-other cannot
- both can ping the field device
- firewall counters show permitted and dropped traffic

only the specified Modbus and ping flow, including ther replies are permitted through ot-fw.
Client identity is matched by IP address
A clean rebuild is not yet tested.

Additional allowlist test:
- ot-client TCP connection to field port 1502 timed out
- the final firewall drop counter increased during test
- this confirms that ot-client is not granted unrestricted access

## Clean rebuild with allowlist

verified after deleting and rebuilding the lab:
- saved allowlist loaded successfully
- ot-client read modbus registers
- ot-other could not access Modbus
- Both clients could ping the field device

Boundary observtion:
- a modbus read originating inside the ot-fw succeeded
- forwading policy does not restrict router-originated traffic

## Modbus service failure and recovery

With the field server stopped:
- No tcp port listener in 502 inside 0t-field
- ping from ot-client successed
- modbus client failed to connect

After restarting field server:
- TCP port 502 listener returnes
- ot-client read registers
- no network or firewall changed were nedded

Conclusion: IP reachability does not prove application availability

Evidence:
- evidence/service-stopped.txt
- evidence/service-recovered.txt

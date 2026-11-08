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

## Missing return route

Fault; removed ot-flied's route to 10.77.20.0/24

Observed:
- The modbus client time out
- A TCP SYN from ot-client reached the field interface
- Restoring the retung route restored reading modbus registers
- no server restart or firewall change needed

Conclusion: communication needs a working path in both directions.
A timeout alone does not identify wheather routing or filtering caused it

Evidence: evidence/missing-return-route.txt

## Incorrect firewall source address

Fault: changed the permitted Modbus source from 10.77.20.10 to .99

observed:
- legitimate client timed out
- its SYN appeared on fw-ops ingress.
- no corresponding SYN appeared on fw-field egress.
- modbus allow counter remained zero while the drop counter increased

recovery:
- reload the saved firewall.nft
- ot-client read registers
- ot-other rmained blocked

Conclusion: valid syntax does not guarantee a correct access policy

Evidence: evidence/wrong-fw-source.txt

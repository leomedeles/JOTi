# Routed Modbus lab validation

Verified after deleating and rebuilding all lab namespaces and the bridge:
- network-up.sh recreated the topology succesfully.
- firewall.nft loaded sucessfully inside ot-fw
- ot-client read modbus registers
- ot-other could not connect to modbus server
- ot-other could still ping the field device

Current firewall policy: accept by default, with one explicit block for ot-other accessing 10.77.40.11 on TCP 502.

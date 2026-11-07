from pymodbus.client import ModbusTcpClient

client = ModbusTcpClient("10.77.40.11", port=502, timeout=3)
try:
	if not client.connect():
		raise SystemExit("TCP connection failed")

	response = client.read_holding_registers(
			address=0,
			count=3,
			device_id=1,
	)

	if response.isError():
		raise SystemExit(f"Modbus error: {response}")

	print("Registers: ", response.registers)

finally:
	client.close()

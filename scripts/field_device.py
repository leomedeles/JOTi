from pymodbus.server import StartTcpServer
from pymodbus.simulator import DataType, SimData, SimDevice

def main():
	registers = SimData(
		address=0,
		values=[2300, 500, 1],
		datatype=DataType.REGISTERS,
		readonly=True,
	)
	device = SimDevice(
		id=1,
		simdata=[registers])

	print("Starting field device on 10.77.40.11:502", flush=True)
	StartTcpServer(
		context=device,
		address=("10.77.40.11", 502),
	)

if __name__ == "__main__":
	main()

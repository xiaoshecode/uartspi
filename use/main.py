"""Send four-byte UART loopback packets; requires a connected FPGA."""

import argparse
import random


def generate_random_hexnum():
    return random.randint(0, 255)


def list_to_hex_string(list_data):
    return bytes(list_data).hex()


def serial_use(test_duration, port="COM4", baudrate=9600, timeout=1, serial_factory=None):
    """Return the number of exact loopback replies and always close the port."""
    if test_duration <= 0:
        raise ValueError("test_duration must be positive")
    if serial_factory is None:
        import serial

        serial_factory = serial.Serial
    valid_data_num = 0
    with serial_factory(
        port=port, baudrate=baudrate, bytesize=8, parity="O", stopbits=1, timeout=timeout
    ) as connection:
        for _ in range(test_duration):
            packet = bytes(generate_random_hexnum() for _ in range(4))
            connection.write(packet)
            result = connection.read(4)
            print("input data is:", packet.hex())
            print("result data is:", result.hex())
            if packet == result:
                valid_data_num += 1
    return valid_data_num


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", default="COM4")
    parser.add_argument("--baudrate", type=int, default=9600)
    parser.add_argument("--count", type=int, default=100)
    args = parser.parse_args()
    if args.count <= 0 or args.baudrate <= 0:
        parser.error("--count and --baudrate must be positive")
    valid = serial_use(args.count, port=args.port, baudrate=args.baudrate)
    print(f"Valid packets: {valid}/{args.count} ({valid / args.count:.2%})")


if __name__ == "__main__":
    main()

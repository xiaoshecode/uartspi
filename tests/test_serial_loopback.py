import contextlib
import importlib.util
import io
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location("uart_client", Path(__file__).parents[1] / "use/main.py")
client = importlib.util.module_from_spec(spec)
spec.loader.exec_module(client)


class Connection:
    def __init__(self, **kwargs):
        self.closed = False
        self.packet = b""

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.closed = True

    def write(self, packet):
        self.packet = packet

    def read(self, count):
        return self.packet[:count]


class SerialLoopbackTest(unittest.TestCase):
    def test_loopback_closes_port(self):
        connection = Connection()
        with contextlib.redirect_stdout(io.StringIO()):
            valid = client.serial_use(3, serial_factory=lambda **kwargs: connection)
        self.assertEqual(valid, 3)
        self.assertTrue(connection.closed)

    def test_failure_closes_port(self):
        connection = Connection()
        def fail(count):
            raise OSError("read failed")
        connection.read = fail
        with self.assertRaises(OSError):
            client.serial_use(1, serial_factory=lambda **kwargs: connection)
        self.assertTrue(connection.closed)

    def test_rejects_empty_run(self):
        with self.assertRaises(ValueError):
            client.serial_use(0)


if __name__ == "__main__":
    unittest.main()

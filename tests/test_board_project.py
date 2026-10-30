"""Check the saved board project's source and physical-pin contract offline."""

from pathlib import Path
import re
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "use/nbytes_uart_final.xpr"


class BoardProjectTest(unittest.TestCase):
    def test_saved_top_matches_the_constrained_physical_ports(self):
        project = ET.parse(PROJECT).getroot()
        sources = project.find("./FileSets/FileSet[@Name='sources_1']")
        self.assertEqual(
            sources.find("./Config/Option[@Name='TopModule']").get("Val"),
            "uart_board_top",
        )
        self.assertEqual(
            sources.find("./Config/Option[@Name='TopAutoSet']").get("Val"),
            "FALSE",
        )
        wrapper = (ROOT / "uart_board_top.v").read_text(encoding="utf-8")
        ports = set(re.findall(r"(?:input|output)\s+wire\s+(\w+)", wrapper))
        xdc = ROOT / "nbytes_uart_final.srcs/constrs_1/new/xc7a35t.xdc"
        constraints = "\n".join(
            line for line in xdc.read_text(encoding="utf-8").splitlines()
            if not line.lstrip().startswith("#")
        )
        bound = set(re.findall(
            r"PACKAGE_PIN\s+\w+\s+IOSTANDARD\s+\w+\s*}\s*\[get_ports\s*{\s*(\w+)\s*}",
            constraints,
        ))
        self.assertEqual(ports, {"clk_50m_i", "uart_rxd_i", "uart_txd_o"})
        self.assertEqual(ports, bound)

    def test_all_saved_source_references_resolve_from_project_directory(self):
        project = ET.parse(PROJECT).getroot()
        for entry in project.findall("./FileSets/FileSet/File"):
            with self.subTest(path=entry.get("Path")):
                path = entry.get("Path")
                self.assertTrue(path.startswith("$PPRDIR/"), path)
                resolved = PROJECT.parent / path.removeprefix("$PPRDIR/")
                self.assertTrue(resolved.is_file(), resolved)

    def test_wrapper_copies_stay_identical_and_are_in_the_project(self):
        root_copy = ROOT / "uart_board_top.v"
        vivado_copy = ROOT / "nbytes_uart_final.srcs/sources_1/new/uart_board_top.v"
        self.assertEqual(root_copy.read_bytes(), vivado_copy.read_bytes())
        project = ET.parse(PROJECT).getroot()
        sources = project.find("./FileSets/FileSet[@Name='sources_1']")
        self.assertIn(
            "$PPRDIR/../nbytes_uart_final.srcs/sources_1/new/uart_board_top.v",
            [entry.get("Path") for entry in sources.findall("File")],
        )


if __name__ == "__main__":
    unittest.main()

# AutoCAD to G-Code

An **AutoLISP-based tool** for generating G-code directly from AutoCAD drawings. Create **G0, G1, G2, and G3 moves** with feedrate settings, coordinate selection, and working-plane selection (**G17/G18/G19**) for arc commands—all within AutoCAD.

Designed for CNC users who want a lightweight, script-based workflow for generating G-code.

---

## Tutorials

I post tutorials, usage guides, and version update demos on YouTube: [**@hansoy69**](https://www.youtube.com/@hansoy69)

---

## Available Commands

| Command | Description |
|---|---|
| `IDC` | Copies selected coordinates in G-code coordinate format |
| `G0P` | Generates a rapid positioning move (`G0`) |
| `G1P` | Generates linear moves (`G1`) with a specified feedrate |
| `G2P` | Generates clockwise arc moves (`G2`) with selectable working plane |
| `G3P` | Generates counterclockwise arc moves (`G3`) with selectable working plane |
| `GCODE` | Combines multiple G-code commands into a single output workflow and copies the generated code to the clipboard |

---

## Installation

1. Download the latest `CNC_HELPER_COMMANDS.lsp` file from [**Releases**](https://github.com/Hans930v/AutoCAD-to-Gcode/releases).
2. Open AutoCAD and enter `APPLOAD` in the command line.
3. Select and load the downloaded `.lsp` file.
4. Enter any of the commands listed above in the AutoCAD command line to start generating G-code.

---

## Latest Version

**Current Release:** [v1.3.3](https://github.com/Hans930v/AutoCAD-to-Gcode/releases/tag/1.3.3)

Highlights:
- Remembers the last selected working plane for `G2P` and `G3P` arc commands.
- Maintains compatibility with previous versions from `v1.1.1` onward.
- Streamlines multi-point linear and arc commands for faster G-code generation.

---

## Important Notes

- Review the generated G-code before running it on a CNC machine.
- Confirm the coordinate system, units, working plane, feedrate, and machine/controller compatibility.
- Simulate or verify tool movements and machine limits before executing the program.

This tool generates G-code commands; it does not replace machine-specific setup, validation, or safety checks.

---

## License

Released under the **MIT License**.

Created by **Hansoy**.

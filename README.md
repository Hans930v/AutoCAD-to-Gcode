# AutoCAD to G-Code  
AutoLISP-based commands for generating G-code directly from AutoCAD drawings.  
Easily create **G0**, **G1**, **G2**, and **G3** moves with feedrate and plane selection (**G17/G18/G19**) — perfect for CNC users who want lightweight, script-based G-code generation inside AutoCAD.  

---

## Tutorials  
I post tutorials and version update demos on YouTube: [**@hansoy69**](https://www.youtube.com/@hansoy69)  

---

## Available Commands  
| Command | Description |
|----------|-------------|
| `IDC` | Copies Coordinates in G-code format |
| `G0P` | Rapid move (G00) |
| `G1P` | Linear move (G01) |
| `G2R` | Clockwise arc with radius input (G02) |
| `G3R` | Counterclockwise arc with radius input (G03) |
| `G2P` | CW arc (G02) with selectable working plane |
| `G3P` | CCW arc (G03) with selectable working plane |

---

## Installation  
1. Download the latest `CNC_HELPER_COMMANDS.lsp` from [Releases](https://github.com/Hans930v/AutoCAD-to-Gcode/releases).  
2. In AutoCAD, type `APPLOAD` and load the `.lsp` file.  
3. Run any of the listed commands in the AutoCAD command line.  

---

## Latest Version  
**Current Release:** [v1.1.1](https://github.com/Hans930v/AutoCAD-to-Gcode/releases/tag/1.1.1)  
- Smart working-plane memory between G2P and G3P commands  
- Backward compatible with v1.1.0  

---

## License  
**MIT License**  
Created by **Hansoy**

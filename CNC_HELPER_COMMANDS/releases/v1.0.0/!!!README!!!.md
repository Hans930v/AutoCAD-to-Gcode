AutoCAD to G-Code (v1.0.0)
--------------------------
*[Full Tutorial Video](https://www.youtube.com/watch?v=bIPuGLiqasY&t=504s)* 

Overview:  
The first release of the AutoCAD G-Code Generator Lisp project.  
It converts drawing points and arcs from AutoCAD directly into G-code commands
(G00–G03) for CNC applications.  

Features:  
• Generates G00, G01, G02, and G03 commands  
• Operates only on the G17 (XY) plane for arcs  
• Easy point and arc selection  
• Automatically copies the generated G-code to clipboard  

Commands:  
G0P  → Rapid move (G00)  
G1P  → Linear move (G01)  
G2R  → Clockwise arc + Arc Radius (G02)  
G3R  → Counter-clockwise arc + Arc Radius (G03)  
G2P  → Clockwise arc + I, J (G02)  
G3P  → Counter-clockwise arc + I, J(G03)  

Installation:
1. Open AutoCAD.
2. Type `APPLOAD`, click on 'Çontents', and add `CNC_HELPER_COMMANDS.lsp`.
3. Run any of the commands above in the command line.

Notes:  
• Fixed to the XY plane (G17)  
• No tool offsets or feedrate options  
• Ideal for students learning the basics of CNC G-code from AutoCAD  
• Default feedrate: F2000  
• Works for basic 3-axis CNC setups  

Version Info:  
Version: 1.0.0   
Language: AutoLISP  
Author: Hansoy  
Goal: Convert AutoCAD geometry to simple G-code commands

**Full Changelog**: https://github.com/Hans930v/AutoCAD-to-Gcode/commits/1.0.0

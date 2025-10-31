AutoCAD to G-Code (v1.1.0)
--------------------------
*[Watch Full Tutorial Here for v1.0.0](https://www.youtube.com/watch?v=bIPuGLiqasY&t=504s)*  and *[v1.1.0 Update Video](https://www.youtube.com/watch?v=TD5tBZHAWmY)*

Overview:  
Version 1.1.0 introduces multi-plane circular interpolation.  
You can now generate G02 and G03 commands for G17 (XY), G18 (XZ), and G19 (YZ) planes.  

New Features:  
• Working plane selection (G17, G18, G19)  
• Support for arcs with (I, J, K) parameters  
• Smarter input: accepts typed or clicked plane selection  
• G-code automatically copied to clipboard  

Commands:  
G0P - Rapid move (G00)
G1P - Linear move (G01)  
G2R - Clockwise arc + Arc Radius(G02)  
G3R - Counter-clockwise arc + Arc Radius(G03)  
G2P - CW arc (G02) with selectable working plane  
G3P - CCW arc (G03) with selectable working plane  

Example Output:  
G18 G2 X45.3500 Z-15.0000 I5.0000 K0.0000 F800  
G19 G3 Y28.7035 Z71.1003 J15.0000 K0.0000 F500  

Installation:
1. Open AutoCAD.
2. Type `APPLOAD`, click on `Contents`, and add `CNC_HELPER_COMMANDS.lsp`.
3. Run any of the commands above in the command line.

Notes:  
• Default plane: G17 (XY)  
• World UCS only — no need to rotate UCS  
• Default feedrate: F2000  
• Works for basic 3-axis CNC setups  

Version Info:  
Version: 1.1.0    
Language: AutoLISP    
Author: Hansoy    
Goal: Add multi-plane circular interpolation support to AutoCAD G-code generation

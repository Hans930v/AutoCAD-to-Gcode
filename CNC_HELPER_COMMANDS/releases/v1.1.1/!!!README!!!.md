AutoCAD to G-Code (v1.1.1)
--------------------------
*[Watch Full Tutorial for v1.0.0](https://www.youtube.com/watch?v=bIPuGLiqasY&t=504s)*  and *[v1.1.0 Update Video](https://www.youtube.com/watch?v=TD5tBZHAWmY)*

Overview:  
Version 1.1.1 refines multi-plane circular interpolation with **smart plane memory**.  
The last selected working plane (G17, G18, or G19) is now remembered between G2P and G3P commands.

Key Update:  
• Working plane selection is persistent until changed  
• No change in command usage — fully backward compatible with v1.1.0  

Example Output:  
G18 G2 X45.3500 Z-15.0000 I5.0000 K0.0000 F800  
G19 G3 Y28.7035 Z71.1003 J15.0000 K0.0000 F500  

Version Info:  
Version: 1.1.1  
Language: AutoLISP  
Author: Hansoy  
Goal: Improve workflow with automatic working plane memory  

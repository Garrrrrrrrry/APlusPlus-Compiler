A++ README  
==========

Team Members: 
-------------
Gurman Dhaliwal gdhal005@ucr.edu gsinghd  
James Glassford aglas012@ucr.edu jamesglassford15  
Suhail-Anand Singh Dhillon sdhil026@ucr.edu DhillonSuhail  
Kevin Pham kpham130@ucr.edu Kuvinn  

Name of Language:  
-----------------
A++  

Extension Given to Programs:  
----------------------------
[program name].aplusplus  

Compiler Name:  
--------------
apc  

Language features:  
==================
*note: brackets denote conditionals, parentheses denote order of operations  

Integer scalar variables
------------------------
\# x;  
\# x, y;

One-dimensional arrays of integers
-----------------------------------
#10# x; |for array of size 10|  
x#1#; |to access element with index of 1|  


Assignment statements
---------------------
x = 10;

Arithmetic operators (e.g., “+”, “-”, “*”, “/”)
-----------------------------------------------
x add y; |+|  
x sub y;  |-|  
x pro y; |*|  
x div y; |/|  
x mod y; |%|  

x = (x add y) min z;  

Relational operators (e.g., “<”, “==”, “>”, “!=”)
-------------------------------------------------
x lt y; |<|  
x eq y; |==|  
x gt y; |>|  
x ne y; |!=|  
x leq y; |<=|  
x geq y; |>=|  

x and y; |&&|  
x or y; | || |  

(x lt y) and (x gt z)  


While or Do-While loops
-----------------------
when [x]:  
do whatever;  
;  

Break statement
---------------
stop;  

If-then-else statements
-----------------------
\?[(x add y) eq 4]:  
do whatever;  
\>[(x add y) eq 3]:  
do whatever2;  
\>[1]:  
;  

Read and write statements
-------------------------
ain(x);  
aout(x);  

Comments
---------
|comment|  

Functions (that can take multiple scalar arguments and return a single scalar result)
-------------------------------------------------------------------------------------
\# myfunction(parameters):

function body;

return(x);

;

|returning an integer|

\# myfunction2(parameters):

function body;

return();

;

|returning nothing|


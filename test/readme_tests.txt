|Integer scalar variables|
# x;
# x, y;

|One-dimensional arrays of integers|
#10# x;
|to access element with index of 1|
x#1#;

|Assignment statements|
x = 10;

|Arithmetic operators (e.g., “+”, “-”, “*”, “/”)|
x add y;
x sub y;
x pro y;
x div y;
x mod y;

x = (4 add 7) sub 8;

|Relational operators (e.g., “<”, “==”, “>”, “!=”)|
x lt y;
x eq y;
x gt y;
x ne y; 
x leq y;
x geq y;

x and y;
x or y;

(6 lt 7) and (8 gt 9);

|While or Do-While loops|
when [x]:
;

|Break statement|
stop;

|If-then-else statements|
?[(x add y) eq 4]:
;
>[(x add y) eq 3]:
;
>[1]:
;

|Read and write statements|
ain(x);
aout(x);

|Functions (that can take multiple scalar arguments and return a single scalar result)|
# myfunction(# parameters):
return(x);
;
# myfunction2(# parameters):
return();
;
|returning nothing|
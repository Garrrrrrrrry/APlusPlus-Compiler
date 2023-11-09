rm lex.yy.c
rm y.output
rm y.tab.c
rm y.tab.h
rm output.txt
rm parser.exe
bison -v -d --file-prefix=y apc.y
flex apc.flex
gcc -O3 lex.yy.c -o parser.exe
./parser.exe input.txt > output.txt
=====================
rm lex.yy.c
rm y.output
rm y.tab.c
rm y.tab.h
rm output.txt
rm parser.exe
bison -v -d --file-prefix=y apc.y
flex apc.flex
gcc -O3 lex.yy.c -o parser.exe
py tests.py
=====================
rm test\output_bubble.txt
rm test\output_fib.txt
rm test\output_readme.txt
rm output.txt
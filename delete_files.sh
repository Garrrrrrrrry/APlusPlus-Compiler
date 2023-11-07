rm lex.yy.c
rm y.output
rm y.tab.c
rm y.tab.h
rm output.txt
rm parser.exe

# .flex -> lex.yy.c
# .y (for yacc) -> y.tab.c
bison -v -d --file-prefix=y apc.y
flex apc.flex
# .c -> .elf
gcc -O3 lex.yy.c -o parser.elf
#run parser (which now includes lexing)
./parser.exe input.txt > output.txt
# cleanup
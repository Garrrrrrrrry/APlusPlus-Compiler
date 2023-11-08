# .flex -> lex.yy.c
flex apc.flex
# .y (for yacc) -> y.tab.c
bison -v -d --file-prefix=y apc.y
# .c -> .elf
gcc -O3 lex.yy.c -o parser.elf
#run parser (which now includes lexing)
./parser.elf input.txt > output.txt
# ./parser.elf test/fib.aplusplus > output.txt
# cleanup
rm lex.yy.c y.output y.tab.c y.tab.h parser.elf
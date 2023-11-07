# .flex -> lex.yy.c
flex apc.flex
# .y (for yacc) -> y.tab.c
bison -v -d --file-prefix=y apc.y
# .c -> .elf
gcc lex.yy.c -o parser.elf
# run parser (which now includes lexing)
./parser.elf testInput.txt > testOutput.txt
#cleanup
rm lex.yy.c y.output y.tab.c y.tab.h parser.elf
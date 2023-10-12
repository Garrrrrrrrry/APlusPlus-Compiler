#calc.flex -> lex.yy.c
flex apc.flex
# lex.yy.c -> lexer.elf
# (note: may have -lfl depending on your env)
gcc -O3 lex.yy.c -o lexer.elf
# lexer.elf + testInput.txt -> testOutput.txt
./lexer.elf testInput.txt > testOutput.txt
# clean up intermediates
rm lex.yy.c lexer.elf
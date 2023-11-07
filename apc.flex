%{
// C code goes here
#include <stdio.h>
#include <math.h>
#include <string.h>
FILE* input_file;

unsigned long long current_line = 1;
unsigned long long current_column = 0;
#define YY_USER_ACTION current_column += yyleng;

#include "y.tab.c"

%}

%option noyywrap

DIGIT [0-9]
ID [a-zA-Z0-9]+\.[a-zA-Z0-9]*
INT [0-9]+\.[0-9]*
ARITH_OP (add|sub|pro|div|mod)
RELAT_OP (lt|eq|gt|ne|leq|geq|and|or)
STRING [a-z][a-zA-Z]+
/* lexing rules go down there */
%%

{ID}           { yylval.id = strdup(yytext); return ID; }
"="           { return EQ; }

{DIGIT}+      { yylval.num = atoi(yytext); return NUM; }
"add"         { return ADD; }
"sub"         { return SUB; }
"pro"         { return MUL; }
"div"         { return DIV; }
"("           { return L_PAREN; }
")"           { return R_PAREN; }
";"           { return SEMICOLON; }

"lt"          { return LT; }
"eq"          { return EQUIVALENT; }
"gt"          { return GT; }
"ne"          { return NE; }
"leq"         { return LEQ; }
"geq"         { return GEQ; }

"?"             { return IF; }
"["             { return S_COND; }
"]"             { return E_COND; }
":"             { return THEN; }
">[1]"          { return ELSE; }
"ain"           { return READIN; }
"aout"          { return READOUT; }
"'"             { return STRING_EDGE_A; }
\"              { return STRING_EDGE_B; }
\n          { ++current_line; current_column = 0; }
[ \t*\r*]     /* NOP */
.           {
                // note: fprintf(stderr, ""); more traditional for error reporting
                printf("problem at line %llu, col %llu\n", current_line, current_column);
                yyterminate();
            }

%%


// more C code goes here



int main(int argc, char **argv) {
    // handle possible file input
    if(argc == 2 && !(yyin = fopen(argv[1], "r"))) {
        fprintf(stderr, " could not open input %s \n", argv[1]);
        return -1;
    }

//    input_file = fopen("full_tests.txt", "r");
//    if(input_file == NULL){
//        fprintf(stderr, "ERROR: file not open");
//        return 1;
//    }

    //perform lexing
    //comment out yyin for manual input
//    yyin = input_file;
//    yylex();
    yyparse();
//    fclose(input_file);

    return 0;
}
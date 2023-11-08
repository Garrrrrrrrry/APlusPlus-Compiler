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
ID [a-zA-Z]

/* lexing rules go down there */
%%

{DIGIT}+                    { yylval.num = atoi(yytext); return INT; }
"#"                         { return DEC; }
"="                         { return ASSIGNMENT; }
";"                         { return SEMICOLON; }
"add"                       { return ADD; }
"sub"                       { return SUB; }
"pro"                       { return MULT; }
"div"                       { return DIV; }
"mod"                       { return MOD; }
"("                         { return L_P; }
")"                         { return R_P; }
","                         { return COMMA; }
"lt"                        { return LT; }
"eq"                        { return EQ; }
"gt"                        { return GT; }
"ne"                        { return NE; }
"leq"                       { return LEQ; }
"geq"                       { return GEQ; }
"and"                       { return AND; }
"or"                        { return OR; }
"stop"                      { return BREAK; }
"when"                      { return WHILE; }
"?"                         { return IF; }
"["                         { return S_COND; }
"]"                         { return E_COND; }
":"                         { return GROUPING; }
">"                         { return ELIF; }
"ain"                       { return RIN; }
"aout"                      { return ROUT; }
"return"                    { return RETURN; }
"|".*"|"                    { yylval.str = strdup(yytext); return COMMENT; }
{ID}+                       { yylval.str = strdup(yytext); return ID; }

\n                          { ++current_line; current_column = 0; }
[ \t*\r*]                   /* NOP */

{ID}*[^{ID}^[PUNCT]]{ID}+   { printf("problem at line %llu, col %llu : Invalid ID\n", current_line, current_column); yyterminate(); }
.                           {
                                // note: fprintf(stderr, ""); more traditional for error reporting
                                printf("problem at line %llu, col %llu : unrecognized symbol\n", current_line, current_column);
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
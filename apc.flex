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

{DIGIT}+                    { printf("INT %s\n", yytext); }
"#"                         { printf("DEC %s\n", yytext); }
"="                         { printf("ASSIGNMENT %s\n", yytext); }
";"                         { printf("SEMICOLON %s\n", yytext); }
"add"                       { printf("ADD %s\n", yytext); }
"sub"                       { printf("SUB %s\n", yytext); }
"pro"                       { printf("MULT %s\n", yytext); }
"div"                       { printf("DIV %s\n", yytext); }
"mod"                       { printf("MOD %s\n", yytext); }
"("                         { printf("L_P %s\n", yytext); }
")"                         { printf("R_P %s\n", yytext); }
"{"                         { printf("L_CB %s\n", yytext); }
"}"                         { printf("R_CB %s\n", yytext); }
","                         { printf("COMMA %s\n", yytext); }
"lt"                        { printf("LT %s\n", yytext); }
"eq"                        { printf("EQ %s\n", yytext); }
"gt"                        { printf("GT %s\n", yytext); }
"ne"                        { printf("NE %s\n", yytext); }
"leq"                       { printf("LEQ %s\n", yytext); }
"geq"                       { printf("GEQ %s\n", yytext); }
"and"                       { printf("AND %s\n", yytext); }
"or"                        { printf("OR %s\n", yytext); }
"stop"                      { printf("BREAK%s\n", yytext); }
"when"                      { printf("WHILE%s\n", yytext); }
"?"                         { printf("IF %s\n", yytext); }
"["                         { printf("S_COND %s\n", yytext); }
"]"                         { printf("E_COND %s\n", yytext); }
":"                         { printf("GROUPING %s\n", yytext); }
">"                         { printf("ELIF %s\n", yytext); }
"ain"                       { printf("RIN %s\n", yytext); }
"aout"                      { printf("ROUT %s\n", yytext); }
"return"                    { printf("RETURN %s\n", yytext); }
"|".*"|"                    { printf("COMMENT %s\n", yytext); }
{ID}+                       { printf("ID %s\n", yytext); }

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
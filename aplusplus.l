%{
#include <stdio.h>
#include <math.h>
FILE* input_file;

unsigned long long current_line = 1;
unsigned long long current_column = 0;
unsigned long long yylang = 1;
#define YY_USER_ACTION current_column += yylang;
%}

%option noyywrap

DIGIT [0-9]

%%

[DIGIT]+    { printf("INT %s\n", yytext); }

[0-9]       { printf("INT %s\n", yytext); }

"add"       { printf("%s\n", yytext); }
"sub"       { printf("%s\n", yytext); }
"pro"       { printf("%s\n", yytext); }
"div"       { printf("%s\n", yytext); }
"mod"       { printf("%s\n", yytext); }
"("         { printf("%s\n", yytext); }
")"         { printf("%s\n", yytext); }

"lt"        { printf("%s\n", yytext); }
"eq"        { printf("%s\n", yytext); }
"gt"        { printf("%s\n", yytext); }
"ne"        { printf("%s\n", yytext); }
"leq"       { printf("%s\n", yytext); }
"geq"       { printf("%s\n", yytext); }

"and"       { printf("%s\n", yytext); }
"or"        { printf("%s\n", yytext); }

"|".*"|"    { printf("%s\n", yytext); }


";"         { printf("%s\n", yytext); }
\n          /*NOP*/
[ \t\r]     /*NOP*/
.           {fprintf(stderr, "problem\n"); yyterminate(); }

"#"[0-9]*"#\t"[a-zA-Z]* { printf("%s\n", yytext); }

%%

int main(){
    input_file = fopen("input.txt", "r");
    if(input_file == NULL){
        fprintf(stderr, "ERROR: file not open");
        return 1;
    }
    yyin = input_file;
    yylex();
    fclose(input_file);
    return 0;
}
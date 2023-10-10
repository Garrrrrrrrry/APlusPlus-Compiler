%{
#include <stdio.h>
#include <math.h>

unsigned long long current_line = 1;
unsigned long long current_column = 0;
#define YY_USER_ACTION current_column += yyleng;
%}

%option noyywrap

DIGIT   [0-9]
ALPHA   [A-Z]

%%

{DIGIT}+    { printf("INT %d\n", atoi(yytext)); }
"add"       { printf("%s\n", "add"); }
"sub"       { printf("%s\n", "subtract"); }
"pro"       { printf("%s\n", "multiply"); }
"div"       { printf("%s\n", "divide"); }
"mod"       { printf("%s\n", "modulo"); }
"eq"        { printf("%s\n", "assign"); }
";"         { printf("%s\n", "semicolon"); }
#{DIGIT}#   { printf("%s\n", "array"); yytext++; yytext[strlen(yytext)-1] = '\0'; printf("%s", "size: "); printf("%s\n", yytext);}
{ALPHA}     { printf("%s\n", yytext); }
"#"         { printf("%s\n", "make_int"); }
\n          { ++current_line; current_column = 0; }
[ \t\r]     /* NOP */
.           {
            // note: fprintf(stderr, ""); more traditional for error reporting printf("problem at line %llu, col %llu\n", current_line, current_column); yyterminate();

            }

%%

int main(int argc, char **argv){
    yylex();
    return 0;
}
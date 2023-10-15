
%{
// C code goes here
#include <stdio.h>
#include <math.h>

unsigned long long current_line = 1;
unsigned long long current_column = 0;
#define YY_USER_ACTION current_column += yyleng;
%}

%option noyywrap

DIGIT [0-9]
ID [a-z][a-z0-9]*
/* lexing rules go down there */
%%

{DIGIT}+    { printf("INT %d\n", atoi(yytext)); }
"add"         { printf("%s\n", "+"); }
"sub"         { printf("%s\n", "-"); }
"pro"         { printf("%s\n", "*"); }
"div"         { printf("%s\n", "/"); }
"mod"         { printf("%s\n", "%"); }
"("         { printf("%s\n", yytext); }
")"         { printf("%s\n", yytext); }

"lt"          { printf("%s\n", "<"); }
"eq"          { printf("%s\n", "="); }
"gt"          { printf("%s\n", ">"); }
"ne"          { printf("%s\n", "!="); }
"leq"          { printf("%s\n", "<="); }
"geq"          { printf("%s\n", ">="); }

"stop"      { printf("%s\n", yytext); }

#{DIGIT}#   { printf("%s\n", "array"); yytext++; yytext[strlen(yytext)-1] = '\0'; printf("%s", "size: "); printf("%s\n", yytext);}

"#"[ \t\r]{ID}+        { printf("assign %s\n", yytext+2); } 

\n          { ++current_line; current_column = 0; }
[ \t\r]     /* NOP */
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

    //perform lexing
    yylex();

    return 0;
}

%{
// C code goes here
#include <stdio.h>
#include <math.h>
FILE* input_file;

unsigned long long current_line = 1;
unsigned long long current_column = 0;
#define YY_USER_ACTION current_column += yyleng;
%}

%option noyywrap

DIGIT [0-9]
ID [a-z][a-z0-9]*
ARITH_OP (add|sub|pro|div|mod)
RELAT_OP (lt|eq|gt|ne|leq|geq|and|or)
/* lexing rules go down there */
%%

{DIGIT}+      { printf("INT %d\n", atoi(yytext)); }
"add"         { printf("%s\n", "+"); }
"sub"         { printf("%s\n", "-"); }
"pro"         { printf("%s\n", "*"); }
"div"         { printf("%s\n", "/"); }
"mod"         { printf("%s\n", "%"); }
"("           { printf("%s\n", yytext); }
")"           { printf("%s\n", yytext); }

"(".+")"([ \t]+{ARITH_OP}[ \t]*[a-zA-Z]+)?;     { printf("%s\n", yytext); }
[a-zA-Z]+[ \t]*{ARITH_OP}[ \t]*[a-zA-Z]+;       { printf("%s\n", yytext); }

"lt"          { printf("%s\n", "<"); }
"eq"          { printf("%s\n", "="); }
"gt"          { printf("%s\n", ">"); }
"ne"          { printf("%s\n", "!="); }
"leq"         { printf("%s\n", "<="); }
"geq"         { printf("%s\n", ">="); }

"and"         { printf("%s\n", "&&"); }
"or"          { printf("%s\n", "||"); }

"(".+")"([ \t]+{RELAT_OP}[ \t]*[a-zA-Z]+)?;     { printf("%s\n", yytext); }
[a-zA-Z]+[ \t]*{RELAT_OP}[ \t]*[a-zA-Z]+;       { printf("%s\n", yytext); }

"stop"        { printf("%s\n", yytext); }

#[ ]+[a-zA-Z](,[ ]+[a-zA-Z ]+)?;   { printf("%s\n", yytext); }
"#"[ \t\r]{ID}+        { printf("assign %s\n", yytext+2); } 

"|".*"|"    { printf("%s\n", yytext); }

";"         { printf("%s\n", yytext); }
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

    input_file = fopen("working_tests.txt", "r");
    if(input_file == NULL){
        fprintf(stderr, "ERROR: file not open");
        return 1;
    }

    //perform lexing
    //comment out yyin for manual input
    yyin = input_file;
    yylex();
    fclose(input_file);

    return 0;
}
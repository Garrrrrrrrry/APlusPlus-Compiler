%{
// C code goes here
#include <stdio.h>
#include <math.h>
#include <string.h>
FILE* input_file;

unsigned long long current_line = 1;
unsigned long long current_column = 0;
#define YY_USER_ACTION current_column += yyleng;
%}

%option noyywrap

DIGIT [0-9]
ID [a-zA-Z0-9]+
INT [0-9]+
ARITH_OP (add|sub|pro|div|mod)
RELAT_OP (lt|eq|gt|ne|leq|geq|and|or)
/* lexing rules go down there */
%%

ID+[ \t]+"="[ \t]+{DIGIT}+;   { printf("%s\n", yytext); }
ID+[ \t]+"="[ \t]+            { printf("%s\n", yytext); }

"="           { printf("%s\n", yytext); }

{DIGIT}+      { printf("INT %d\n", atoi(yytext)); }
"add"         { printf("%s\n", "+"); }
"sub"         { printf("%s\n", "-"); }
"pro"         { printf("%s\n", "*"); }
"div"         { printf("%s\n", "/"); }
"mod"         { printf("%s\n", "%"); }
"("           { printf("%s\n", yytext); }
")"           { printf("%s\n", yytext); }
"{"           { printf("%s\n", yytext); }
"}"           { printf("%s\n", yytext); }
","           { printf("%s\n", yytext); }

"(".+")"([ \t]+{ARITH_OP}[ \t]*ID+)?;     { printf("%s\n", yytext); }
ID+[ \t]*{ARITH_OP}[ \t]*ID+;       { printf("%s\n", yytext); }

"lt"          { printf("%s\n", "<"); }
"eq"          { printf("%s\n", "="); }
"gt"          { printf("%s\n", ">"); }
"ne"          { printf("%s\n", "!="); }
"leq"         { printf("%s\n", "<="); }
"geq"         { printf("%s\n", ">="); }

"and"         { printf("%s\n", "&&"); }
"or"          { printf("%s\n", "||"); }

"(".+")"([ \t]+{RELAT_OP}[ \t]*ID+)?;     { printf("%s\n", yytext); }
ID+[ \t]*{RELAT_OP}[ \t]*ID+;       { printf("%s\n", yytext); }

"stop"        { printf("%s\n", yytext); }

"when"       { printf("%s\n", "while loop"); }

{ID}+#{DIGIT}+#;      { printf("%s\n", yytext); }
{ID}+#{ID}+#;      { printf("%s\n", yytext); }
#{ID}+#             { printf("%s\n", "array"); yytext++; yytext[strlen(yytext)-1] = '\0'; printf("%s", "index: "); printf("%s\n", yytext);}
#{ID}+[ \t]*{ARITH_OP}[ \t]*{ID}+#             { printf("%s\n", "array"); yytext++; yytext[strlen(yytext)-1] = '\0'; printf("%s", "index: "); printf("%s\n", yytext);}

#{DIGIT}*#                { printf("%s\n", "array"); yytext++; yytext[strlen(yytext)-1] = '\0'; printf("%s", "size: "); printf("%s\n", yytext);}
#{DIGIT}+#[ \t]ID+; { printf("%s\n", yytext); }
#{ID}+#[ \t]ID+; { printf("%s\n", yytext); }

"?"             {printf("IF %s\n", yytext);}
"["             {printf("START CONDITIONAL %%s\n", yytext);}
"]"             {printf("END CONDITIONAL %s\n", yytext);}
":"             {printf("%s\n", yytext);}
">"             {printf("ELSE IF %s\n", yytext);}

"ain"           {printf("READ IN %s\n", yytext);}
"aout"          {printf("WRITE OUT %s\n", yytext);}

"return"        {printf("%s\n", yytext);}
"return()"        {printf("%s\n", yytext);}

{ID}+             {printf("ID %s\n", yytext);}

#[ ]+ID(,[ ]+[a-zA-Z ]+)?;   { printf("%s\n", yytext); }
"#"[ \t\r]{ID}+        { printf("assign %s\n", yytext+2); } 

"|".*"|"    { printf("%s\n", yytext); }

";"         { printf("%s\n", yytext); }
\n          { ++current_line; current_column = 0; }
[ \t*\r*]     /* NOP */

{ID}*[^{ID}]{ID}+   {printf("problem at line %llu, col %llu : Invalid ID\n", current_line, current_column); yyterminate();}
.           {
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
    yylex();
//    fclose(input_file);

    return 0;
}
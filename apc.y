%{
    #include <stdio.h>

    int yylex(void);
    
    int var[26];

    void yyerror(char const *err) {fprintf(stderr, "yyerror: %s\n", err); exit(-1); }

%}

%token INT L_P R_P S_COND E_COND ASSIGNMENT WHILE GROUPING SEMICOLON ID DEC

%left ADD SUB MUL DIV EQ MOD

%union{
    int num;
    char* str;
}

%type<num> INT stmt mul_exp add_exp exp
%type<str> ID
%%

program: stmt {}
| program stmt {}

stmt: add_exp ASSIGNMENT { printf("add_exp %d ASSIGNMENT\n", $1); } | DEC ID {printf("exp %s: VARIABLE\n", $2);} | WHILE S_COND add_exp EQ add_exp E_COND GROUPING { printf("WHILE CONDITIONAL %d EQ %d\n", $3, $5); } | add_exp SEMICOLON { printf("test\n");} | SEMICOLON { printf("SEMICOLON\n");}

add_exp: mul_exp { printf("add_exp %d: mul_exp\n", $1); $$ = $1; }
| add_exp ADD add_exp { printf("add_exp %d ADD add_exp %d\n", $1, $3); $$ = $1 + $3; }
| add_exp SUB add_exp { printf("add_exp %d SUB add_exp %d\n", $1, $3); $$ = $1 - $3; }

mul_exp: exp { printf("mul_exp %d: exp\n", $1); $$ = $1; }
| mul_exp MUL mul_exp { printf("mul_exp %d MUL mul_exp %d\n", $1, $3); $$ = $1 * $3; }
| mul_exp DIV mul_exp { printf("mul_exp %d DIV mul_exp %d\n", $1, $3); $$ = $1 / $3; }
| mul_exp MOD mul_exp { printf("mul_exp %d MOD mul_exp %d\n", $1, $3); $$ = $1 % $3; }

exp: INT { printf("exp %d: INT\n", $1); $$ = $1; } 
| ID ASSIGNMENT INT{printf("exp %s: VARIABLE\n", $1); $$ = $3;}
| SUB exp { printf("SUB exp %d\n", $2); $$ = -$2; }
| L_P exp R_P { printf("L_P exp %d R_P\n", $2); $$ = $2; }

%%

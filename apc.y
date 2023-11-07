%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    int yylex(void);

    void yyerror(char const *err) {fprintf(stderr, "yyerror: %s\n", err); exit(-1); }

%}

%token INT L_P R_P S_COND E_COND ASSIGNMENT WHILE GROUPING SEMICOLON VERT_BAR
%token DEC MULT L_CB R_CB COMMA LT GT NE LEQ GEQ AND OR BREAK IF ELIF RIN ROUT RETURN COMMENT ID

%left ADD SUB MUL DIV EQ MOD

%union {
    int num;
    char* str;
}

%type<num> INT stmt mul_exp add_exp mod_exp exp

%type<str> ID comments
 
%%

program: stmt {}
| program stmt {}

stmt: add_exp ASSIGNMENT { printf("add_exp %d ASSIGNMENT\n", $1); } | WHILE S_COND add_exp EQ add_exp E_COND GROUPING { printf("WHILE CONDITIONAL %d EQ %d\n", $3, $5); } | SEMICOLON { printf("SEMICOLON\n");}

stmt: VERT_BAR comments VERT_BAR { printf("|%s|\n", $2); }
| VERT_BAR VERT_BAR { printf("||\n"); }

comments: ID { $$ = $1; }
| INT {
    char buffer[20];
    sprintf(buffer, "%d", $1);
    $$ = strdup(buffer);
}

add_exp: mul_exp { printf("add_exp %d: mul_exp\n", $1); $$ = $1; }
| add_exp ADD add_exp { printf("add_exp %d ADD add_exp %d\n", $1, $3); $$ = $1 + $3; }
| add_exp SUB add_exp { printf("add_exp %d SUB add_exp %d\n", $1, $3); $$ = $1 - $3; }

mul_exp: mod_exp { printf("mul_exp %d: mod_exp\n", $1); $$ = $1; }
| mul_exp MUL mul_exp { printf("mul_exp %d MUL mul_exp %d\n", $1, $3); $$ = $1 * $3; }
| mul_exp DIV mul_exp { printf("mul_exp %d DIV mul_exp %d\n", $1, $3); $$ = $1 / $3; }

mod_exp: exp { printf("mod_exp %d: exp\n", $1); $$ = $1; } 
| mod_exp MOD mod_exp { printf("mod_exp %d MOD mod_exp %d\n", $1, $3); $$ = $1 % $3; }

exp: INT { printf("exp %d: INT\n", $1); $$ = $1; }  
| SUB exp { printf("SUB exp %d\n", $2); $$ = -$2; }
| L_P exp R_P { printf("L_P exp %d R_P\n", $2); $$ = $2; }

%%

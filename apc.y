%{
    #include <stdio.h>

    int yylex(void);

    void yyerror(char const *err) {fprintf(stderr, "yyerror: %s\n", err); exit(-1); }

%}

%token INT L_P R_P S_COND E_COND ASSIGNMENT WHILE GROUPING SEMICOLON

%left ADD SUB MUL DIV EQ MOD

%union {
    int num;
}

%type<num> INT stmt mul_exp add_exp mod_exp exp
 
%%

program: stmt {}
| program stmt {}

stmt: add_exp ASSIGNMENT { printf("%d\n", $1); } | WHILE S_COND add_exp EQ add_exp E_COND GROUPING { printf("WHILE CONDITIONAL %d EQ %d\n", $3, $5); } | SEMICOLON { printf("END GROUPING");}

add_exp: mul_exp { $$ = $1; }
| add_exp ADD add_exp { $$ = $1 + $3; }
| add_exp SUB add_exp { $$ = $1 - $3; }

mul_exp: mod_exp { $$ = $1; }
| mul_exp MUL mul_exp { $$ = $1 * $3; }
| mul_exp DIV mul_exp { $$ = $1 / $3; }

mod_exp: exp { $$ = $1; } 
| mod_exp MOD mod_exp { $$ = $1 % $3; }

exp: INT { $$ = $1; }  
| SUB exp { $$ = -$2; }
| L_P exp R_P { $$ = $2; }

%%

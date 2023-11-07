%{
    #include <stdio.h>

    int yylex(void);

    void yyerror(char const *err) {fprintf(stderr, "yyerror: %s\n", err); exit(-1); }

%}

%token INT L_P R_P S_COND E_COND ASSIGNMENT WHILE GROUPING SEMICOLON ID

%left ADD SUB MUL DIV EQ MOD 
%left AND OR LT EQ GT GEQ LEQ NE

%union {
    int num;
    char* str;
}

%type<num> INT stmt mul_exp add_exp mod_exp exp
 
%%

program: stmt {}
| program stmt {}

stmt: add_exp ASSIGNMENT { printf("add_exp %d ASSIGNMENT\n", $1); } | WHILE S_COND add_exp EQ add_exp E_COND GROUPING { printf("WHILE CONDITIONAL %d EQ %d\n", $3, $5); } | SEMICOLON { printf("SEMICOLON\n");}

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


statements:
statement SEMICOLON statements { printf("statements -> statement SEMICOLON statements \n"); }
| { printf("statements -> epsilon \n"); }

cond: equality { printf("cond -> equality \n"); }
| L_P cond R_P { printf("cond -> L_P cond R_P \n"); }
| cond OR cond { printf("cond -> cond OR cond \n"); }
| cond AND cond { printf("cond -> cond AND cond \n"); }

equality: m_exp { printf("equality -> m_exp \n"); }
| m_exp LT m_exp { printf("equality -> m_exp LT m_exp \n"); }
| m_exp EQ m_exp { printf("equality -> m_exp EQ m_exp \n"); }
| m_exp GT m_exp { printf("equality -> m_exp GT m_exp \n"); }
| m_exp NE m_exp { printf("equality -> m_exp NE m_exp \n"); }
| m_exp LEQ m_exp { printf("equality -> m_exp LEQ m_exp \n"); }
| m_exp GEQ m_exp { printf("equality -> m_exp GEQ m_exp \n"); }

function_dec:
DEC ID L_P param R_P GROUPING statements { printf("function_dec -> DEC ID L_P param R_P GROUPING statements \n"); }

function_call:
ID L_P param R_P { printf("function_call -> ID L_P param R_P \n"); }

param: { printf("param -> epsilon \n"); }
| ID { printf("param -> ID \n); }
| ID COMMA multiparam { printf("param -> ID COMMA multiparam \n"); }

multiparam: ID { printf("multiparam -> ID \n"); }
| ID COMMA multiparam { printf("multiparam -> ID COMMA multiparam \n"); }

return:
RETURN L_P m_exp R_P { printf("return -> RETURN L_P m_exp R_P \n"); }
| RETURN L_P R_P { printf("return -> RETURN L_P R_P \n"); }

array_dec: DEC m_exp DEC ID { printf("array_dec -> DEC m_exp DEC ID \n"); }

array_access: ID DEC m_exp DEC { printf("array_access -> ID DEC m_exp DEC \n"); }


%%

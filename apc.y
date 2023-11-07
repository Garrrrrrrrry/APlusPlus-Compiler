%{
    #include <stdio.h>

    int yylex(void);
    
    int val;

    void yyerror(char const *err) {fprintf(stderr, "yyerror: %s\n", err); exit(-1); }

%}

%token INT L_P R_P S_COND E_COND ASSIGNMENT WHILE GROUPING SEMICOLON ID DEC RETURN COMMA

%left ADD SUB MUL DIV MOD 
%left AND OR LT EQ GT GEQ LEQ NE

%union{
    int num;
    char* str;
}

%type<num> INT stmt mul_exp add_exp exp
%type<str> ID mul_str
%%

program: stmt SEMICOLON { printf("program -> stmt SEMICOLON \n"); }
| stmt SEMICOLON program { printf("program -> stmt SEMICOLON program \n"); }

stmt: DEC mul_str {} 
| WHILE S_COND add_exp EQ add_exp E_COND GROUPING { printf("WHILE CONDITIONAL %d EQ %d\n", $3, $5); } 
| ID ASSIGNMENT add_exp{printf("ID %s ASSIGNMENT add_exp %d\n", $1, $3); $$ = $3;}  //introduces shift/reduce conflict
| add_exp SEMICOLON { printf("add_exp %d end stmt\n"), $1;} 

add_exp: mul_exp { printf("add_exp %d: mul_exp\n", $1); $$ = $1; } //issue: we can't run input where (sub) pro because mul only multiplies exp
| L_P add_exp R_P { printf("L_P add_exp %d R_P\n", $2); $$ = $2; } //introduces shift/reduce conflict
| add_exp ADD add_exp { printf("add_exp %d ADD add_exp %d\n", $1, $3); $$ = $1 + $3; }
| add_exp SUB add_exp { printf("add_exp %d SUB add_exp %d\n", $1, $3); $$ = $1 - $3; }

mul_exp: exp { printf("mul_exp %d: exp\n", $1); $$ = $1; }
| L_P mul_exp R_P { printf("L_P mul_exp %d R_P\n", $2); $$ = $2; } //introduces shift/reduce conflict
| mul_exp MUL mul_exp { printf("mul_exp %d MUL mul_exp %d\n", $1, $3); $$ = $1 * $3; }
| mul_exp DIV mul_exp { printf("mul_exp %d DIV mul_exp %d\n", $1, $3); $$ = $1 / $3; }
| mul_exp MOD mul_exp { printf("mul_exp %d MOD mul_exp %d\n", $1, $3); $$ = $1 % $3; }

exp: INT { printf("exp %d: INT\n", $1); $$ = $1; } //issue: cant pass up strings (yet!) so implement that tmrw morning
| SUB exp { printf("SUB exp %d\n", $2); $$ = -$2; }
| L_P exp R_P { printf("L_P exp %d R_P\n", $2); $$ = $2; }

cond: equality { printf("cond -> equality \n"); }
| L_P cond R_P { printf("cond -> L_P cond R_P \n"); }
| cond OR cond { printf("cond -> cond OR cond \n"); }
| cond AND cond { printf("cond -> cond AND cond \n"); }

equality: add_exp { printf("equality -> add_exp \n"); }
| add_exp LT add_exp { printf("equality -> add_exp LT add_exp \n"); }
| add_exp EQ add_exp { printf("equality -> add_exp EQ add_exp \n"); }
| add_exp GT add_exp { printf("equality -> add_exp GT add_exp \n"); }
| add_exp NE add_exp { printf("equality -> add_exp NE add_exp \n"); }
| add_exp LEQ add_exp { printf("equality -> add_exp LEQ add_exp \n"); }
| add_exp GEQ add_exp { printf("equality -> add_exp GEQ add_exp \n"); }

function_dec:
DEC ID L_P param R_P GROUPING program { printf("function_dec -> DEC ID L_P param R_P GROUPING program \n"); }

function_call:
ID L_P param R_P { printf("function_call -> ID L_P param R_P \n"); }

param: { printf("param -> epsilon \n"); }
| ID { printf("param -> ID \n"); }
| ID COMMA multiparam { printf("param -> ID COMMA multiparam \n"); }

multiparam: ID { printf("multiparam -> ID \n"); }
| ID COMMA multiparam { printf("multiparam -> ID COMMA multiparam \n"); }

return:
RETURN L_P add_exp R_P { printf("return -> RETURN L_P add_exp R_P \n"); }
| RETURN L_P R_P { printf("return -> RETURN L_P R_P \n"); }

array_dec: DEC add_exp DEC ID { printf("array_dec -> DEC add_exp DEC ID \n"); }

array_access: ID DEC add_exp DEC { printf("array_access -> ID DEC add_exp DEC \n"); }

mul_str: mul_str COMMA mul_str { printf("DEC mul_str %s COMMA mulstr %s\n", $1, $3);} //introduces shift/reduce conflict
| ID { printf("DEC ID %s\n", $1);}

%%

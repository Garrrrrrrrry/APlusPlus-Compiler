%{
    #include <stdio.h>
    #include <stdlib.h>
    int yylex(void);
    
    int val;

    void yyerror(char const *err) {
        fprintf(stderr, "parse problem at line %llu, col %llu\n", current_line, current_column); 
        fprintf(stderr, "yyerror: %s\n", err); exit(-1); }

%}


%token INT L_P R_P S_COND E_COND ASSIGNMENT WHILE GROUPING SEMICOLON ID DEC RETURN COMMA COMMENT MULT BREAK IF ELIF RIN ROUT ELSE


%left ADD SUB MUL DIV MOD 
%left AND OR LT EQ GT GEQ LEQ NE 

%union{
    int num;
    char* str;
}

%type<num> INT stmt mul_exp add_exp exp

%type<str> ID mul_str
 
%%

program: stmt SEMICOLON     { printf("program -> stmt SEMICOLON\n"); }
| stmt SEMICOLON program    { printf("program -> stmt SEMICOLON program \n"); }

stmts: /* none */           { printf("stmts -> none\n"); }
    | stmts stmt SEMICOLON  { printf("stmts -> stmts stmt SEMICOLON\n"); }

stmt: DEC mul_str                               { printf("stmt -> DEC mul_str\n"); }
    | DEC ID ASSIGNMENT add_exp                 { printf("stmt -> DEC ID ASSIGNMENT add_exp\n"); }
    | WHILE S_COND cond E_COND GROUPING stmts   { printf("stmt -> WHILE S_COND cond E_COND GROUPING stmts\n"); } 
    | ID ASSIGNMENT add_exp                     { printf("stmt -> ID ASSIGNMENT add_exp\n"); }
    | if_else_stmt                              { printf("stmt -> if_else_stmt\n"); }
    | read                                      { printf("stmt -> read\n"); }
    | function_call                             { printf("stmt -> function_call\n"); }
    | function_dec                              { printf("stmt -> function_dec\n"); }
    | array_access                              { printf("stmt -> array_access\n"); }
    | array_dec                                 { printf("stmt -> array_dec\n"); }
    | return                                    { printf("stmt -> return\n"); }

add_exp: 
    add_exp ADD mul_exp                         { printf("add_exp -> add_exp ADD mul_exp\n"); }
    | add_exp SUB mul_exp                       { printf("add_exp -> add_exp SUB mul_exp\n"); }
    | mul_exp                                   { printf("add_exp -> mul_exp\n"); }

mul_exp: 
    mul_exp MUL exp         { printf("mull_exp -> mul_exp MUL exp\n"); }
    | mul_exp DIV exp       { printf("mull_exp -> mul_exp DIV exp\n"); }
    | mul_exp MOD exp       { printf("mull_exp -> mul_exp MOD exp\n"); }
    | exp                   { printf("mul_exp -> exp\n"); }

exp: 
    INT                 { printf("exp -> INT\n"); $$ = $1; }
    | ID                { printf("exp -> ID\n");}
    | SUB exp           { printf("exp -> SUB exp\n"); $$ = -($2); }
    | array_access      { printf("exp -> array_access\n"); }
    | L_P add_exp R_P   { printf("exp -> L_P add_exp R_P\n"); $$ = $2; };


cond: 
    add_exp                 { printf("cond -> add_exp\n"); }
   | add_exp LT add_exp     { printf("cond -> add_exp LT add_exp\n"); }
   | add_exp EQ add_exp     { printf("cond -> add_exp EQ add_exp\n"); }
   | add_exp GT add_exp     { printf("cond -> add_exp GT add_exp\n"); }
   | add_exp NE add_exp     { printf("cond -> add_exp NE add_exp\n"); }
   | add_exp LEQ add_exp    { printf("cond -> add_exp LEQ add_exp\n"); }
   | add_exp GEQ add_exp    { printf("cond -> add_exp GEQ add_exp\n"); }
   | add_exp AND add_exp    { printf("cond -> add_exp AND add_exp\n"); }
   | add_exp OR add_exp     { printf("cond -> add_exp OR add_exp\n"); }

mul_str: ID COMMA mul_str   { printf("mul_str -> mul_str COMMA mul_str\n"); }
    | ID                    { printf("mul_str -> ID\n"); }

array_dec: 
    DEC INT DEC ID  { printf("array_dec -> DEC INT DEC ID\n"); }
    | DEC DEC ID    { printf("array_dec -> DEC DEC ID\n"); }

array_access: 
    ID DEC INT DEC              { printf("array_access -> ID DEC INT DEC\n"); }
    | ID DEC ID DEC             { printf("array_access -> ID DEC ID DEC\n"); }
    | ID DEC ID ADD INT DEC     { printf("array_access -> ID DEC ID ADD INT DEC\n"); }

function_dec:
    DEC ID L_P param R_P GROUPING stmts   { printf("function_dec -> DEC ID L_P param R_P GROUPING\n"); }
function_call:
    ID L_P param R_P    { printf("function_call -> ID L_P param R_P\n"); }

param:                      
    /* none */                         { printf("param -> epsilon\n"); }
    | DEC param_val                    { printf("param -> DEC ID\n"); }
    | DEC param_val COMMA multiparam   { printf("param -> DEC ID COMMA multiparam\n"); }

param_val:
    ID          { printf("param_val -> ID\n"); }
    | DEC ID    { printf("param_val -> DEC ID\n"); }

multiparam: 
    ID                          { printf("multiparam -> ID\n"); }
    | DEC param_val COMMA multiparam   { printf("multiparam -> DEC ID COMMA multiparam\n"); }

return: 
    RETURN L_P add_exp R_P  { printf("return -> RETURN L_P add_exp R_P\n"); }
    | RETURN L_P ID R_P     { printf("return -> RETURN L_P ID R_P \n"); }
    | RETURN ID             { printf("return -> RETURN ID \n"); }
    | RETURN L_P R_P        { printf("return -> RETURN L_P R_P \n"); }

read: 
    read_out            { printf("read_write_stmt -> read_out\n"); }
    | read_in           { printf("read_write_stmt -> read_in\n"); }
read_in: 
    RIN L_P ID R_P      { printf("read_in -> RIN L_P ID R_P\n"); }
read_out: 
    ROUT L_P ID R_P     { printf("read_out -> ROUT L_P ID R_P\n"); }
    | ROUT L_P INT R_P  { printf("read_out -> ROUT L_P INT R_P\n"); }


if_else_stmt: 
    if_stmt                          { printf("if_else_stmt -> if_stmt stmt\n"); }

if_stmt: 
    IF S_COND cond E_COND GROUPING   { printf("if_stmt -> IF S_COND cond E_COND GROUPING\n"); }
    | else_stmt { printf("if_stmt -> else_stmt\n"); }
    | elif_stmt { printf("if_stmt -> elif_stmt\n"); }

else_stmt: 
    ELSE GROUPING                    { printf("else_stmt -> ELSE GROUPING\n"); }

elif_stmt:
    ELIF S_COND cond E_COND GROUPING { printf("elif_stmt -> ELIF S_COND cond E_COND GROUPING\n"); }

%%

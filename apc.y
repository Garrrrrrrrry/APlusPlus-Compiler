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

%type<num> INT stmt mul_exp add_exp exp assignment_stmt

%type<str> ID mul_str int_scalar_dec arrays array_access array_dec
 
%%

program: stmt SEMICOLON { printf("program -> stmt SEMICOLON\n"); }

stmts: {}
| stmts stmt {}

stmt: 
    program             { printf("stmt -> program\n"); }
    | int_scalar_dec    { printf("stmt -> int_scalar_dec\n"); }
    | arrays            { printf("stmt -> arrays\n"); }
    | assignment_stmt   { printf("stmt -> assignment_stmt\n"); }
    | arithmetic_ops    { printf("stmt -> arithmetic_ops\n"); }
    | relational_ops    { printf("stmt - > relational_ops\n"); }
    | while_loops       { printf("stmt -> while_loops\n"); }
    | if_else_stmt      { printf("stmt -> if_else_stmt\n"); }
    | read_write_stmt   { printf("stmt -> read_write\n"); }
    | functions         { printf("stmt -> functions\n"); }
    | return            { printf("stmt -> return\n"); }


int_scalar_dec:
    DEC mul_str             { printf("int_scalar_dec -> DEC mul_str\n"); }
mul_str: 
    ID                      { printf("mul_str -> ID\n"); }
    | mul_str COMMA mul_str { printf("mul_str -> mul_str COMMA mul_str\n"); }

arrays:
    array_dec       { printf("arrays -> array_dec\n"); }
    | array_access  { printf("arrays -> array_access\n"); }
array_dec: 
    DEC INT DEC ID  { printf("array_dec -> DEC INT DEC ID\n"); }
    | DEC DEC ID    { printf("array_dec -> DEC DEC ID\n"); }
array_access: 
    ID DEC INT DEC  { printf("array_access -> ID DEC INT DEC\n"); }


assignment_stmt:
    DEC ID ASSIGNMENT add_exp   { printf("assignment_stmt -> DEC ID ASSIGNMENT add_exp"); }
    | DEC ID ASSIGNMENT ID      { printf("assignment_stmt -> DEC ID ASSIGNMENT ID"); }
    | ID ASSIGNMENT add_exp     { printf("assignment_stmt -> ID ASSIGNMENT add_exp"); }  //introduces shift/reduce conflict

arithmetic_ops: add_exp { printf("arithmetic_ops -> add_exp\n"); }

add_exp: mul_exp
    | add_exp ADD mul_exp { printf("add_exp -> add_exp ADD mul_exp\n"); }
    | add_exp SUB mul_exp %prec SUB { printf("add_exp -> add_exp SUB mul_exp\n"); }

mul_exp: exp
    | mul_exp MUL exp { printf("mul_exp -> mul_exp MUL exp\n"); }
    | mul_exp DIV exp { printf("mul_exp -> mul_exp DIV exp\n"); }
    | mul_exp MOD exp { printf("mul_exp -> mul_exp MOD exp\n"); }

exp: INT { printf("exp -> INT\n"); }
    | SUB exp { printf("exp -> SUB exp\n"); }
    | L_P add_exp R_P { printf("exp -> L_P add_exp R_P\n"); }


relational_ops: cond { printf("relational_ops -> cond\n"); }

cond: equality
    | L_P cond R_P { printf("cond -> L_P cond R_P\n"); }
    | cond OR cond { printf("cond -> cond OR cond\n"); }
    | cond AND cond { printf("cond -> cond AND cond\n"); }
    ;

equality: add_exp compare_rhs { printf("equality -> add_exp compare_rhs\n"); }
        | ID compare_rhs { printf("equality -> ID compare_rhs\n"); }
        ;

compare_rhs: ID compare add_exp { printf("compare_rhs -> ID compare add_exp\n"); }
            | add_exp compare ID { printf("compare_rhs -> add_exp compare ID\n"); }
            ;

compare: LT   { printf("compare -> LT\n"); }
        | EQ   { printf("compare -> EQ\n"); }
        | GT   { printf("compare -> GT\n"); }
        | NE   { printf("compare -> NE\n"); }
        | LEQ  { printf("compare -> LEQ\n"); }
        | GEQ  { printf("compare -> GEQ\n"); }
        | AND  { printf("compare -> AND\n"); }
        | OR   { printf("compare -> OR\n"); }
        ;

while_loops:
    WHILE S_COND cond E_COND GROUPING { printf("while_loops -> WHILE S_COND cond E_COND GROUPING\n"); } 

functions:
    function_dec    { printf("functions -> function_dec\n"); }
    | function_call { printf("functions -> function_call\n"); }

function_dec:
    DEC ID L_P param R_P GROUPING stmts SEMICOLON   { printf("function_dec -> DEC ID L_P param R_P GROUPING\n"); }
function_call:
    ID L_P param R_P    { printf("function_call -> ID L_P param R_P\n"); }

param:                      
    /* none */                  { printf("param -> epsilon\n"); }
    | DEC ID                    { printf("param -> DEC ID\n"); }
    | DEC ID COMMA multiparam   { printf("param -> DEC ID COMMA multiparam\n"); }

multiparam: 
    ID                          { printf("multiparam -> ID\n"); }
    | DEC ID COMMA multiparam   { printf("multiparam -> DEC ID COMMA multiparam\n"); }

return: 
    RETURN L_P add_exp R_P  { printf("return -> RETURN L_P add_exp R_P\n"); }
    | RETURN L_P ID R_P     { printf("return -> RETURN L_P ID R_P \n"); }
    | RETURN L_P R_P        { printf("return -> RETURN L_P R_P \n"); }


read_write_stmt: 
    read_out            { printf("read_write_stmt -> read_out\n"); }
    | read_in           { printf("read_write_stmt -> read_in\n"); }
read_in: 
    RIN L_P ID R_P      { printf("read_in -> RIN L_P ID R_P\n"); }
read_out: 
    ROUT L_P ID R_P     { printf("read_out -> ROUT L_P ID R_P\n"); }
    | ROUT L_P INT R_P  { printf("read_out -> ROUT L_P INT R_P\n"); }


if_else_stmt: 
    if_stmt stmt else_stmt stmt     { printf("if_else_stmt -> if_stmt stmt else_stmt stmt\n"); }
    | if_stmt stmt                  { printf("if_else_stmt -> if_stmt stmt\n"); }
if_stmt: 
    IF S_COND cond E_COND GROUPING  { printf("if_stmt -> IF S_COND cond E_COND GROUPING\n"); }
else_stmt: 
    ELSE GROUPING                   { printf("else_stmt -> ELSE GROUPING\n"); }

%%
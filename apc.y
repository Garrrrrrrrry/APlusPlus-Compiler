%{
    #include <stdio.h>

    int yylex(void);
    
    int val;

    void yyerror(char const *err) {
        fprintf(stderr, "parse problem at line %llu, col %llu\n", current_line, current_column); 
        fprintf(stderr, "yyerror: %s\n", err); exit(-1); }

%}

%token INT L_P R_P S_COND E_COND ASSIGNMENT WHILE GROUPING SEMICOLON ID DEC RETURN COMMA BREAK IF ELIF RIN ROUT COMMENT 

%left ADD SUB MULT DIV MOD 
%left AND OR LT EQ GT GEQ LEQ NE

%union{
    int num;
    char* str;
}

%type<num> INT
%type<str> ID COMMENT
%%

program: { printf("program -> epsilon \n"); }
| stmt  program { printf("program -> stmt program \n"); }

stmt:
int_dec SEMICOLON { printf("stmt -> int_dec SEMICOLON \n"); }
| assign SEMICOLON { printf("stmt -> assign SEMICOLON \n"); }
| function_dec SEMICOLON { printf("stmt -> function_dec SEMICOLON \n"); }
| function_call SEMICOLON { printf("stmt -> function_call SEMICOLON \n"); }
| return SEMICOLON { printf("stmt -> return SEMICOLON \n"); }
| array_dec SEMICOLON { printf("stmt -> array_dec SEMICOLON \n"); }
| while SEMICOLON { printf("stmt -> while SEMICOLON \n"); }
| if SEMICOLON { printf("stmt -> if SEMICOLON \n"); }
| rin SEMICOLON { printf("stmt -> rin SEMICOLON \n"); }
| rout SEMICOLON { printf("stmt -> rout SEMICOLON \n"); }
| break SEMICOLON { printf("stmt -> break SEMICOLON \n"); }

int_dec:
DEC ID int_assign { printf("int_dec -> DEC ID int_assign \n"); }
| DEC ID int_assign COMMA int_multidec { printf("int_dec -> DEC ID int_assign COMMA int_multidec \n"); }

int_assign:
 { printf("int_assign -> epsilon \n"); }
| ASSIGNMENT m_exp { printf("int_assign -> EQ m_exp \n"); }

int_multidec:
ID int_assign { printf("int_multidec -> ID int_assign \n"); }
| ID int_assign COMMA int_multidec { printf("int_multidec -> ID int_assign COMMA int_multidec \n"); }

assign:
ID ASSIGNMENT m_exp { printf("assign -> ID EQ m_exp \n"); }
| array_access ASSIGNMENT m_exp { printf("assign -> array_access EQ m_exp \n"); }

m_exp:
integer { printf("m_exp -> integer \n"); }
| L_P m_exp R_P { printf("m_exp -> L_P m_exp R_P \n"); }
| m_exp ADD m_exp { printf("m_exp -> m_exp ADD m_exp \n"); }
| m_exp SUB m_exp { printf("m_exp -> m_exp SUB m_exp \n"); }
| m_exp MULT m_exp { printf("m_exp -> m_exp MULT m_exp \n"); }
| m_exp DIV m_exp { printf("m_exp -> m_exp DIV m_exp \n"); }
| m_exp MOD m_exp { printf("m_exp -> m_exp MOD m_exp \n"); }

integer:
INT { printf("integer -> INT \n"); }
| SUB INT { printf("integer -> SUB INT \n"); }
| ID { printf("integer -> ID \n"); }
| SUB ID { printf("integer -> SUB ID \n"); }
| array_access { printf("integer -> array_access \n"); }
| SUB array_access { printf("integer -> SUB array_access \n"); }

cond: equality { printf("cond -> equality \n"); }
| S_COND cond E_COND { printf("cond -> L_P cond R_P \n"); }
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
DEC ID L_P param R_P GROUPING program { printf("function_dec -> DEC ID L_P param R_P GROUPING program \n"); }

function_call:
ID L_P param R_P { printf("function_call -> ID L_P param R_P \n"); }

param: { printf("param -> epsilon \n"); }
| DEC ID { printf("param -> DEC ID \n"); }
| DEC ID COMMA multiparam { printf("param -> DEC ID COMMA multiparam \n"); }
| DEC S_COND E_COND ID { printf("param -> DEC S_COND E_COND ID \n"); }
| DEC S_COND E_COND ID COMMA multiparam { printf("param -> DEC S_COND E_COND ID COMMA multiparam \n"); }

multiparam: DEC ID { printf("multiparam -> DEC ID \n"); }
| DEC ID COMMA multiparam { printf("multiparam -> DEC ID COMMA multiparam \n"); }
| DEC S_COND E_COND ID { printf("multiparam -> DEC S_COND E_COND ID \n"); }
| DEC S_COND E_COND ID COMMA multiparam { printf("multiparam -> DEC S_COND E_COND ID COMMA multiparam \n"); }

return:
RETURN L_P m_exp R_P { printf("return -> RETURN L_P m_exp R_P \n"); }
| RETURN L_P R_P { printf("return -> RETURN L_P R_P \n"); }

array_dec: DEC S_COND m_exp E_COND ID { printf("array_dec -> S_COND m_exp E_COND ID \n"); }

array_access: ID S_COND m_exp E_COND { printf("array_access -> ID S_COND m_exp E_COND \n"); }

while:
WHILE S_COND cond E_COND GROUPING program { printf("while -> WHILE S_COND cond E_COND GROUPING program \n"); }

if:
IF S_COND cond E_COND GROUPING program elif { printf("if -> IF S_COND cond E_COND GROUPING program elif \n"); }
|IF IF S_COND cond E_COND GROUPING program elif { yyerror("error: double if  \n"); }

elif:
 { printf("elif -> epsilon \n"); }
| ELIF S_COND cond E_COND GROUPING program elif { printf("elif -> ELIF S_COND cond E_COND GROUPING program elif \n"); }

rin:
RIN L_P ID R_P { printf("rin -> RIN L_P ID R_P \n"); }

rout:
ROUT L_P m_exp R_P { printf("rout -> ROUT L_P m_exp R_P \n"); }

break:
BREAK { printf("break -> BREAK \n"); }

%%

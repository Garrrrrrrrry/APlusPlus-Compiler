%{
    #include <stdio.h>

    int yylex(void);
    
    int val;

    void yyerror(char const *err) {
        fprintf(stderr, "parse problem at line %llu, col %llu\n", current_line, current_column); 
        fprintf(stderr, "yyerror: %s\n", err); exit(-1); }

    static char* genTempName() {
        static unsigned long counter;
        static char buff[4096]; sprintf(buff, "temp%llu", counter++);
        return strdup(buff);
    }

    typedef struct { char *name; char *value; } VarData;

%}

%token INT S_COND E_COND WHILE GROUPING SEMICOLON ID DEC RETURN COMMA BREAK IF ELIF RIN ROUT COMMENT 

%right ADD SUB MULT DIV MOD 
%left EQ GT GEQ LEQ NE
%nonassoc LT L_P R_P
%right ASSIGNMENT AND OR

%union{
    int num;
    char* str;
    VarData var;
}

%type<num> INT
%type<str> ID COMMENT
%type<var> integer m_exp equality cond
%%

program: { printf("func main\n"); } stmts { printf("endfunc\n"); } {}

stmts: stmts stmt {}
| stmt {}

stmt:
int_dec SEMICOLON { }
| assign SEMICOLON { }
| function_dec SEMICOLON { }
| function_call SEMICOLON { }
| return SEMICOLON { }
| array_dec SEMICOLON {  }
| while SEMICOLON { printf("stmt -> while SEMICOLON \n"); }
| if SEMICOLON { printf("stmt -> if SEMICOLON \n"); }
| rin SEMICOLON { printf("stmt -> rin SEMICOLON \n"); }
| rout SEMICOLON { }
| break SEMICOLON { printf("stmt -> break SEMICOLON \n"); }

int_dec: DEC ID ASSIGNMENT cond { printf("= %s, %s\n", $2, $4.name); }
| DEC int_assign {}

int_assign: int_assign COMMA ID { printf(". %s\n", $3); }
| ID { printf(". %s\n", $1); }

assign:
ID ASSIGNMENT cond { 
    printf("= %s, %s\n", $1, $3.name);
 }
| ID DEC INT DEC ASSIGNMENT cond { 
    printf("[]= %s, %d, %s\n", $1, $3, $6.name);
 }
| ID ASSIGNMENT ID DEC INT DEC {
    printf("=[] %s, %s, %d\n", $1, $3, $5);
}

m_exp:
integer {
    $$.value = $1.value;
}
| L_P m_exp R_P { $$ = $2; }
| m_exp ADD m_exp { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("+ %s, %s, %s\n", name, $1.name, $3.name);

    $$.name = name;
 }
| m_exp SUB m_exp { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("- %s, %s, %s\n", name, $1.name, $3.name);

    $$.name = name;
 }
| m_exp MULT m_exp { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("* %s, %s, %s\n", name, $1.name, $3.name);

    $$.name = name;
 }
| m_exp DIV m_exp { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("/ %s, %s, %s\n", name, $1.name, $3.name);

    $$.name = name;
 }
| m_exp MOD m_exp { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("% %s, %s, %s\n", name, $1.name, $3.name);

    $$.name = name;
 }

integer:
INT { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("= %s, %s\n", name, $1);

    $$.name = name;
    $$.value = $1;
 }
| SUB INT { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("= %s, %s\n", name, $2);

    $$.name = name;
    $$.value = -$2;
 }
| ID { 
    char *name = genTempName();


    printf(". %s\n", name);
    printf("= %s, %s\n", name, $1);

    $$.name = name;
    $$.value = $1;
 }

cond: L_P cond R_P { $$.name = $2.name; }
| cond OR cond { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("|| %s, %s, %s\n", name, $1.name, $3.name);

    $$.name = name;
    
 }
| cond AND cond { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("&& %s, %s, %s\n", name, $1.name, $3.name);

    $$.name = name;
 }
| equality {
    $$.name = $1.name;
}

equality: L_P equality R_P { $$.name = $2.name; }
| equality LT equality { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("< %s, %s, %s\n", name, $1.name, $3.name);

    $$.name = name;
 }
| equality EQ equality { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("== %s, %s, %s\n", name, $1.name, $3.name);

    $$.name = name;
 }
| equality GT equality { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("> %s, %s, %s\n", name, $1.name, $3.name);

    $$.name = name;
 }
| equality NE equality { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("!= %s, %s, %s\n", name, $1.name, $3.name);

    $$.name = name;
 }
| equality LEQ equality { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("<= %s, %s, %s\n", name, $1.name, $3.name);

    $$.name = name;
 }
| equality GEQ equality { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf(">= %s, %s, %s\n", name, $1.name, $3.name);

    $$.name = name;
 }
 | m_exp {
    $$.name = $1.name;
}

function_dec:
DEC ID L_P param R_P GROUPING stmts { printf("function_dec -> DEC ID L_P param R_P GROUPING program \n"); }

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
RETURN L_P cond R_P { 
    printf("ret %s\n", $3.name);
 }
| RETURN L_P R_P { 
    printf("ret 0\n");
 }

array_dec: DEC integer DEC ID {
    printf("at array declaration\n");
    printf(".[] %s, ", $4);
    printf("%s\n", $2);
}

while:
WHILE S_COND cond E_COND GROUPING stmts { printf("while -> WHILE S_COND cond E_COND GROUPING program \n"); }

if:
IF S_COND cond E_COND GROUPING stmts elif { printf("if -> IF S_COND cond E_COND GROUPING program elif \n"); }
|IF IF S_COND cond E_COND GROUPING stmts elif { yyerror("error: double if  \n"); }

elif:
 { printf("elif -> epsilon \n"); }
| ELIF S_COND cond E_COND GROUPING stmts elif { printf("elif -> ELIF S_COND cond E_COND GROUPING program elif \n"); }

rin:
RIN L_P cond R_P { 
    printf(".< %s\n", $3.name);
 }

rout:
ROUT L_P cond R_P { 
    printf(".> %s\n", $3.name);
 }

break:
BREAK { printf("break -> BREAK \n"); }

%%

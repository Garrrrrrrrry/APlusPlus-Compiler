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

    typedef struct { char **data; size_t len; } Vec;
    static void VecPush(Vec *vec, char *cstring) {
        if ( !(vec->data = realloc (vec->data, sizeof(char *)*(vec->len + 1)))){
            printf("bad_alloc\n"); exit(-1);
        }
        vec->data[vec->len++] = cstring;
    }

    static Vec vec;
    static Vec vecVar;

%}

%token INT S_COND E_COND WHILE GROUPING SEMICOLON ID DEC RETURN COMMA BREAK IF ELIF RIN ROUT COMMENT NEG

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

int_dec: DEC ID ASSIGNMENT cond { 
    //check for dups
    int i = 0;
    for (; i < vecVar.len; ++i){
        if (0 == strcmp(vecVar.data[i], $2)){
            fprintf(stderr,"Variable %s already declared; exiting.\n", $2); 
            exit(-1);
        }
    }
    VecPush(&vecVar, $2);
    i = 0;
    for (; i < vecVar.len; ++i){
        if (0 == strcmp(vecVar.data[i], $4.name)){
            VecPush(&vec, vec.data[i]);
                printf(". %s\n", $2);
                printf("= %s, %s\n", $2, vec.data[i]); 
                exit(0);
        }
    }
    VecPush(&vec, $4.name);
    printf(". %s\n", $2);
    printf("= %s, %s\n", $2, $4.name); 
    }
| DEC int_assign {}

int_assign: int_assign COMMA ID 
{   
    //check for dups
    int i = 0;
    for (; i < vecVar.len; ++i){
        if (0 == strcmp(vecVar.data[i], $3)){
            fprintf(stderr, "Variable %s already declared; exiting.\n", $3); 
            exit(-1);
        }
    }
    VecPush(&vecVar, $3);
    VecPush(&vec, "0");
    printf(". %s\n", $3); 
    }
| ID { 
    //check for dups
    int i = 0;
    for (; i < vecVar.len; ++i){
        if (0 == strcmp(vecVar.data[i], $1)){
            fprintf(stderr, "Variable %s already declared; exiting.\n", $1); 
            exit(-1);
        }
    }
    VecPush(&vecVar, $1);
    VecPush(&vec, "0");
    printf(". %s\n", $1); 
    }

assign:
ID ASSIGNMENT cond { 
    
    //check for declared variable
    int i = 0;
    int j = 0;
    int error = 1;
    for (; i < vecVar.len; ++i){ //for all variable names
        if (0 == strcmp(vecVar.data[i], $1)){   //if variable is equal to id
            for(; j < vecVar.len; ++j){         //for all variable names
                if (0 == strcmp(vecVar.data[i], $3.name)){ 
                    vec.data[i] = vec.data[j];
                }
                
            }
            vec.data[i] = $3.name;
            printf("= %s, %s\n", $1, vec.data[i]);
            error = 0;
        }
    }
    if(error){
        fprintf(stderr, "Assignment of undeclared variable %s\n", $1);
    }
 }
| ID DEC INT DEC ASSIGNMENT cond { 
    printf("[]= %s, %s, %s\n", $1, $3, $6.name);
 }
| ID ASSIGNMENT ID DEC INT DEC {
    printf("=[] %s, %s, %s\n", $1, $3, $5);
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
| NEG INT { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("= %s, -%s\n", name, $2);

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
    printf(".[] %s, ", $4);
    printf("%s\n", $2.value);
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
ROUT L_P cond R_P { printf(".> %s\n", $3.value); }
| ROUT L_P ID DEC INT DEC R_P {
    printf(".[]> %s, %s\n", $3, $5);
}

break:
BREAK { printf("break -> BREAK \n"); }

%%

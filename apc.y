%{
    #define _GNU_SOURCE
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdint.h>
    #include <stdbool.h>
    
    int yylex(void);
    
    int val;
    int whileCount = 0;
    const unsigned int MAX_LENGTH = 4096;

    void yyerror(char const *err) {
        fprintf(stderr, "parse problem at line %llu, col %llu\n", current_line, current_column); 
        fprintf(stderr, "yyerror: %s\n", err); exit(-1); }

    static char* genTempName() {
        static unsigned long counter;
        static char buff[4096]; sprintf(buff, "temp%lu", counter++);
        return strdup(buff);
    }

    static char* whileLoopBodyCount() {
        static unsigned long counter;
        static char buff[4096]; sprintf(buff, "loopbody%lu", counter++);
        return strdup(buff);
    }

    static char* beginWhileLoopBot() {
        whileCount--;
        static char buff[4096]; sprintf(buff, "beginloop%lu", whileCount);
        return strdup(buff);
    }
    static char* beginWhileLoopTop() {
        static char buff[4096]; sprintf(buff, "beginloop%lu", whileCount);
        return strdup(buff);
    }

    static char* endWhileLoopTop() {
        static char buff[4096]; 
        sprintf(buff, "endloop%lu", whileCount);
        whileCount++;
        return strdup(buff);
    }

    static char* endWhileLoopBot() {

        static char buff[4096]; 
        sprintf(buff, "endloop%lu", whileCount);
        return strdup(buff);
    }


    typedef struct { char *name; char *value; } VarData;

    typedef struct { char **data; size_t len; } Vec;
    static void VecPush(Vec *vec, char *cstring) {
        if ( !(vec->data = realloc (vec->data, sizeof(char *)*(vec->len + 1)))){
            printf("bad_alloc\n"); exit(-1);
        }
        vec->data[vec->len++] = strdup(cstring);
    }

    static Vec vec;
    static Vec vecVar;
    static Vec arrayVar;
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
%type<str> ID COMMENT stmt int_dec int_assign program stmts if elif break while assign return array_dec
%type<var> integer m_exp equality cond
%%

program: { printf("func main\n"); } stmts { printf("%sendfunc\n", $2); } {}

stmts: { $$ = "" }
| stmt stmts { 
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "%s%s", $1, $2);
    $$ = strdup(temp_buf);
}

stmt:
function_dec SEMICOLON { }
| while SEMICOLON { }
| if SEMICOLON { }
| int_dec SEMICOLON { }
| assign SEMICOLON { }
| function_call SEMICOLON { }
| return SEMICOLON { }
| array_dec SEMICOLON { }
| rin SEMICOLON { }
| rout SEMICOLON { }
| break SEMICOLON { }

int_dec: DEC ID ASSIGNMENT cond { 
    //check for dups
    int i = 0;
    for (; i < vecVar.len; ++i){
        if (0 == strcmp(vecVar.data[i], $2)){
            fprintf(stderr,"Error line %llu : Variable %s already declared; exiting.\n", current_line, $2);  
            exit(-1);
        }
    }
    VecPush(&vecVar, $2);
    i = 0;
    for (; i < vecVar.len; ++i){
        if (0 == strcmp(vecVar.data[i], $4.name)){
            VecPush(&vec, vec.data[i]);

                char temp_buf[MAX_LENGTH];
                sprintf(temp_buf, ". %s\n", $2);
                sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", $2, vec.data[i]);
                $$ = strdup(temp_buf);

                exit(0);
        }
    }
    VecPush(&vec, $4.name);

    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ". %s\n", $2);
    sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", $2, $4);
    $$ = strdup(temp_buf);
    }
| DEC int_assign { $$ = $2; }

int_assign: int_assign COMMA ID 
{   
    //check for dups
    int i = 0;
    for (; i < vecVar.len; ++i){
        if (0 == strcmp(vecVar.data[i], $3)){
            fprintf(stderr, "Error line %llu : Variable %s already declared; exiting.\n", current_line, $3); 
            exit(-1);
        }
    }
    VecPush(&vecVar, $3);
    VecPush(&vec, "0");

    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ". %s\n", $3);
    $$ = strdup(temp_buf);
}
| ID { 
    //check for dups
    int i = 0;
    for (; i < vecVar.len; ++i){
        if (0 == strcmp(vecVar.data[i], $1)){
            fprintf(stderr, "Error line %llu : Variable %s already declared; exiting.\n", current_line, $1); 
            exit(-1);
        }
    }
    VecPush(&vecVar, $1);
    VecPush(&vec, "0");

    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ". %s\n", $1);
    $$ = strdup(temp_buf);
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

            char temp_buf[MAX_LENGTH];
            sprintf(temp_buf, "= %s, %s\n", $1, vec.data[i]);
            $$ = strdup(temp_buf);

            error = 0;
        }
    }
    if(error){
        fprintf(stderr, "Error line %llu : Assignment of undeclared variable %s\n", current_line, $1);
    }
 }
| ID DEC INT DEC ASSIGNMENT cond { 
    printf("[]= %s, %s, %s\n", $1, $3, $6.name);
 }
| ID ASSIGNMENT ID DEC INT DEC {

    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "=[] %s, %s, %s\n", $1, $3, $5);
    $$ = strdup(temp_buf);
}
| ID ASSIGNMENT ID S_COND m_exp E_COND {
    //check for non declared
    int i = 0;
    int error = 0;
    for (; i < arrayVar.len; ++i){
        if (0 == strcmp(arrayVar.data[i], $3)){
            error = 1;
        }
    }
    if(error){
        fprintf(stderr,"Error line %llu : Array %s is not declared; %s\n", current_line, $3);  
    }
    char *name = genTempName();

    printf(". %s\n", name);
    printf("=[] %s, %s, %s\n", $1, $3, $5);
}
| ID S_COND m_exp E_COND ASSIGNMENT m_exp { 
    //check for non declared
    int i = 0;
    int error = 1;
    for (; i < arrayVar.len; ++i){
        if (0 == strcmp(arrayVar.data[i], $1)){
            error = 0;
        }
    }
    if(error){
        fprintf(stderr,"Error line %llu : Array %s is not declared; %s\n", current_line, $1);  
    }
    char *name = genTempName();
    
    printf(". %s\n", name);
    printf("[]= %s, %s, %s\n", $1, $3, $6);
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
    printf("%% %s, %s, %s\n", name, $1.name, $3.name);

    $$.name = name;
 }

integer:
INT { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("= %s, %s\n", name, $1);

    $$.name = name;
    $$.value = (void *)(intptr_t)$1;
 }
| NEG INT { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("- %s, 0, %s\n", name, $2);

    $$.name = name;
    $$.value = (void *)(intptr_t)$2;
 }
| ID { 
    char *name = genTempName();


    printf(". %s\n", name);
    printf("= %s, %s\n", name, $1);

    $$.name = name;
    $$.value = $1;
 }
| ID S_COND m_exp E_COND { 
    char *name = genTempName();

    printf(". %s\n", name);
    printf("=[] %s, %s, %s\n", name, $1, $3);

    $$.name = name;
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

    //$$.name = name;
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
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "ret %s\n", $3);
    $$ = strdup(temp_buf);
 }
| RETURN L_P R_P { 
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "ret 0\n");
    $$ = strdup(temp_buf);
 }

array_dec: 
DEC S_COND m_exp E_COND ID {
    VecPush(&arrayVar, $5);
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ".[] %s, %s\n", $5, $3);
    $$ = strdup(temp_buf);
}

while:
WHILE S_COND cond E_COND GROUPING stmts{
    char *begin = beginWhileLoopTop();
    char *end = endWhileLoopTop();
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ": %s\n", begin);

    char* condition = genTempName();
    char* inverse_cond = genTempName();
    sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", condition, $3);
    sprintf(temp_buf + strlen(temp_buf), "! %s, %s\n", inverse_cond, condition);
    
    sprintf(temp_buf + strlen(temp_buf), "?:= %s, %s\n", end, inverse_cond); //if cond is false, goto end
    sprintf(temp_buf + strlen(temp_buf), "%s", $6);
    sprintf(temp_buf + strlen(temp_buf), ":= %s\n", begin); //goto begin to loop
    sprintf(temp_buf + strlen(temp_buf), ": %s\n", end);

    $$ = strdup(temp_buf);
}

if:
IF S_COND cond E_COND GROUPING stmts elif { 
    char* end = "if_end", * final = "if_final_end";
    char* condition = genTempName();
    char* inverse_cond = genTempName();

    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "= %s, %s\n", condition, $3);
    sprintf(temp_buf + strlen(temp_buf), "! %s, %s\n", inverse_cond, condition);
    sprintf(temp_buf + strlen(temp_buf), "?:= %s, %s\n", end, inverse_cond);
    sprintf(temp_buf + strlen(temp_buf), "Testing if stmts: %s", $6);
    sprintf(temp_buf + strlen(temp_buf), ":= %s\n", final);
    sprintf(temp_buf + strlen(temp_buf), ": %s\n", end);
    sprintf(temp_buf + strlen(temp_buf), "%s", $7);
    sprintf(temp_buf + strlen(temp_buf), ": %s\n", final);
    $$ = strdup(temp_buf);
}
elif: { $$ = ""; }
| ELIF S_COND cond E_COND GROUPING stmts elif { 
    char* end = "elseif_end", * final = "if_final_end";
    char* condition = genTempName();
    char* inverse_cond = genTempName();

    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "= %s, %s\n", condition, $3);
    sprintf(temp_buf + strlen(temp_buf), "! %s, %s\n", inverse_cond, condition);
    sprintf(temp_buf + strlen(temp_buf), "?:= %s, %s\n", end, inverse_cond);
    sprintf(temp_buf + strlen(temp_buf), "%s", $6);
    sprintf(temp_buf + strlen(temp_buf), ":= %s\n", final);
    sprintf(temp_buf + strlen(temp_buf), ": %s\n", end);
    sprintf(temp_buf + strlen(temp_buf), "%s", $7);
    $$ = strdup(temp_buf);
}

rin:
RIN L_P cond R_P { 
    printf(".< %s\n", $3);
 }

rout:
ROUT L_P cond R_P { printf(".> %s\n", $3); }
| ROUT L_P ID DEC INT DEC R_P {
    printf(".[]> %s, %s\n", $3, $5);
}

break: 
BREAK { 
    char* final = "if_final_end";
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ":= %s\n", final);
    $$ = strdup(temp_buf);
}

%%
%{
    #define _GNU_SOURCE
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdint.h>
    #include <stdbool.h>
    
    int yylex(void);
    
    int val;
    int whileCount = 0;
    char *global_name_sub = "";
    const unsigned int MAX_LENGTH = 4096;

    void yyerror(char const *err) {
        fprintf(stderr, "parse problem at line %llu, col %llu\n", current_line, current_column); 
        fprintf(stderr, "yyerror: %s\n", err); exit(-1); }

    static char* genTempName() {
        static unsigned long counter;
        static char buff[4096];
        snprintf(buff, sizeof(buff), "temp%lu", counter++);
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
    static Vec func;
    static Vec funcVar;

    int counter = 0;
    int inFunc = 0;
%}

%token INT S_COND E_COND WHILE GROUPING SEMICOLON ID DEC RETURN COMMA BREAK IF ELIF RIN ROUT COMMENT NEG

%right ADD SUB MULT DIV MOD 
%left EQ GT GEQ LEQ NE
%nonassoc LT L_P R_P
%right ASSIGNMENT AND OR

%union{
    char* str;
}

%type<str> param function_call rin rout function_dec INT ID COMMENT if elif stmt int_dec int_assign assign stmts array_dec break return while S_COND E_COND GROUPING m_exp integer cond equality
%%

program: { printf("func main\n"); } stmts { printf("%sendfunc\n", $2); } {}

stmts: { $$ = "" }
| stmts stmt { 
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "%s%s", $1, $2);
    $$ = strdup(temp_buf);
}

stmt:
function_dec SEMICOLON { $$ = $1 }
| while SEMICOLON { $$ = $1 }
| if SEMICOLON { $$ = $1 }
| int_dec SEMICOLON { $$ = $1 }
| assign SEMICOLON { $$ = $1 }
| function_call SEMICOLON { $$ = $1 }
| array_dec SEMICOLON { $$ = $1 }
| rin SEMICOLON { $$ = $1 }
| rout SEMICOLON { $$ = $1 }
| break SEMICOLON { $$ = $1 }
| return SEMICOLON { $$ = $1 }

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
        if (0 == strcmp(vecVar.data[i], $4)){
            VecPush(&vec, vec.data[i]);

                char temp_buf[MAX_LENGTH];
                sprintf(temp_buf, ". %s\n", $2);
                sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", $2, vec.data[i]);
                $$ = strdup(temp_buf);

                exit(0);
        }
    }
    VecPush(&vec, $4);

    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ". %s\n", $2);
    sprintf(temp_buf + strlen(temp_buf), "%s", $4);
    sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", $2, global_name_sub);
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
    sprintf(temp_buf, "%s. %s\n", $1, $3);
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
                if (0 == strcmp(vecVar.data[i], $3)){ 
                    vec.data[i] = vec.data[j];
                }
            }
            vec.data[i] = $3;
            /*
            char temp_buf[MAX_LENGTH];
            sprintf(temp_buf, "= %s, %s\n", $1, vec.data[i]);
            $$ = strdup(temp_buf);
            */
            error = 0;
        }
    }
    if(error){
        fprintf(stderr, "Error line %llu : Assignment of undeclared variable %s\n", current_line, $1);
    }
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "%s", $3);
    sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", $1, strdup(global_name_sub));
    $$ = strdup(temp_buf);
 }
| ID DEC INT DEC ASSIGNMENT cond { 

    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "[]= %s, %s, %s\n", $1, $3, $6);
    $$ = strdup(temp_buf);
 }
| ID ASSIGNMENT ID DEC INT DEC {
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "=[] %s, %s, %s\n", $1, $3, $5);
    $$ = strdup(temp_buf);
}
| ID ASSIGNMENT ID S_COND m_exp E_COND {
    //check for non declared
    int i = 0;
    int error = 1;
    for (; i < arrayVar.len; ++i){
        if (0 == strcmp(arrayVar.data[i], $3)){
            error = 0;
        }
    }
    if(error){
        fprintf(stderr,"Error line %llu : Array %s is not declared; %s\n", current_line, $3);  
    }
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "=[] %s, %s, %s\n", $1, $3, $5);
    $$ = strdup(temp_buf);
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
    
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "[]= %s, %s, %s\n", $1, $3, $6);
    $$ = strdup(temp_buf);
}

m_exp:
integer {
    $$ = $1;
}
| L_P m_exp R_P { $$ = $2; }
| m_exp ADD m_exp { 
    char *one = genTempName(), *two = genTempName(), *sum = genTempName();
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ". %s\n", one);
    sprintf(temp_buf + strlen(temp_buf), ". %s\n", two);
    sprintf(temp_buf + strlen(temp_buf), ". %s\n", sum);

    sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", one, $1);
    sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", two, $3);

    sprintf(temp_buf + strlen(temp_buf), "+ %s, %s, %s\n", sum, one, two);
    global_name_sub = strdup(sum);
    $$ = strdup(temp_buf);
 }
| m_exp SUB m_exp { 
    char *one = genTempName(), *two = genTempName(), *sum = genTempName();
    char temp_buf[MAX_LENGTH];

    sprintf(temp_buf, ". %s\n", one);
    sprintf(temp_buf + strlen(temp_buf), ". %s\n", two);
    sprintf(temp_buf + strlen(temp_buf), ". %s\n", sum);

    sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", one, $1);
    sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", two, $3);

    sprintf(temp_buf + strlen(temp_buf), "- %s, %s, %s\n", sum, one, two);
    global_name_sub = strdup(sum);
    $$ = strdup(temp_buf);
 }
| m_exp MULT m_exp { 
    char *one = genTempName(), *two = genTempName(), *sum = genTempName();
    char temp_buf[MAX_LENGTH];

    sprintf(temp_buf, ". %s\n", one);
    sprintf(temp_buf + strlen(temp_buf), ". %s\n", two);
    sprintf(temp_buf + strlen(temp_buf), ". %s\n", sum);

    sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", one, $1);
    sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", two, $3);
    sprintf(temp_buf + strlen(temp_buf), "* %s, %s, %s\n", sum, one, two);
    global_name_sub = sum;
    $$ = strdup(temp_buf);
 }
| m_exp DIV m_exp { 
    char *one = genTempName(), *two = genTempName(), *sum = genTempName();
    char temp_buf[MAX_LENGTH];

    sprintf(temp_buf, ". %s\n", one);
    sprintf(temp_buf + strlen(temp_buf), ". %s\n", two);
    sprintf(temp_buf + strlen(temp_buf), ". %s\n", sum);

    sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", one, $1);
    sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", two, $3);
    sprintf(temp_buf + strlen(temp_buf), "/ %s, %s, %s\n", sum, one, two);
    global_name_sub = strdup(sum);
    $$ = strdup(temp_buf);
 }
| m_exp MOD m_exp { 
    char *one = genTempName(), *two = genTempName(), *sum = genTempName();
    char temp_buf[MAX_LENGTH];

    sprintf(temp_buf, ". %s\n", one);
    sprintf(temp_buf + strlen(temp_buf), ". %s\n", two);
    sprintf(temp_buf + strlen(temp_buf), ". %s\n", sum);

    sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", one, $1);
    sprintf(temp_buf + strlen(temp_buf), "= %s, %s\n", two, $3);
    sprintf(temp_buf + strlen(temp_buf), "%% %s, %s, %s\n", sum, one, two);
    global_name_sub = strdup(sum);
    $$ = strdup(temp_buf);
 }

integer:
INT { 
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "%s", $1);
    $$ = strdup(temp_buf);
}
| NEG INT { 
    char *name = genTempName();
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ". %s\n", name);
    sprintf(temp_buf + strlen(temp_buf), "- %s, 0, %s\n", name, $2);
    $$ = strdup(temp_buf);
 }
| ID { 
    $$ = $1;
}
| ID S_COND m_exp E_COND { 
    char *name = genTempName();
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ". %s\n", name);
    sprintf(temp_buf + strlen(temp_buf), "=[] %s, %s, %s\n", name, $1, $3);
    $$ = strdup(temp_buf);
 }

cond: L_P cond R_P { $$ = $2; }
    | cond OR cond {
        char *name = genTempName();
        char temp_buf[MAX_LENGTH];
        sprintf(temp_buf, ". %s\n", name);
        sprintf(temp_buf + strlen(temp_buf), "|| %s, %s, %s\n", name, $1, $3);
        global_name_sub = strdup(name);
        $$ = strdup(temp_buf);
    }
    | cond AND cond {
        char *name = genTempName();
        char temp_buf[MAX_LENGTH];
        sprintf(temp_buf, ". %s\n", name);
        sprintf(temp_buf + strlen(temp_buf), "&& %s, %s, %s\n", name, $1, $3);
        global_name_sub = strdup(name);
        $$ = strdup(temp_buf);
    }
    | equality {
        $$ = $1;
    }

equality: L_P equality R_P { $$ = $2; }
    | equality LT equality {
        char *name = genTempName();
        char temp_buf[MAX_LENGTH];
            sprintf(temp_buf, "%s", $3);
        sprintf(temp_buf + strlen(temp_buf), ". %s\n< %s, %s, %s\n", name, name, $1, global_name_sub);
        global_name_sub = strdup(name);
        $$ = strdup(temp_buf);
    }
    | equality EQ equality {
        char *name = genTempName();
        char temp_buf[MAX_LENGTH];
        sprintf(temp_buf, ". %s\n== %s, %s, %s\n", name, name, $1, $3);
        global_name_sub = strdup(name);
        $$ = strdup(temp_buf);
    }
    | equality GT equality {
        char *name = genTempName();
        char temp_buf[MAX_LENGTH];
        sprintf(temp_buf, ". %s\n> %s, %s, %s\n", name, name, $1, $3);
        global_name_sub = strdup(name);
        $$ = strdup(temp_buf);
    }
    | equality NE equality {
        char *name = genTempName();
        char temp_buf[MAX_LENGTH];
        sprintf(temp_buf, ". %s\n!= %s, %s, %s\n", name, name, $1, $3);
        global_name_sub = strdup(name);
        $$ = strdup(temp_buf);
    }
    | equality LEQ equality {
        char *name = genTempName();
        char temp_buf[MAX_LENGTH];
        sprintf(temp_buf, ". %s\n<= %s, %s, %s\n", name, name, $1, $3);
        global_name_sub = strdup(name);
        $$ = strdup(temp_buf);
    }
    | equality GEQ equality {
        char *name = genTempName();
        char temp_buf[MAX_LENGTH];
        sprintf(temp_buf, ". %s\n>= %s, %s, %s\n", name, name, $1, $3);
        global_name_sub = strdup(name);
        $$ = strdup(temp_buf);
    }
    | m_exp {
        $$ = $1;
    }

function_dec:
DEC ID L_P param R_P GROUPING stmts{ 
    //check for dup functions
    int i = 0;
    int funcDefinition = 0;
    for (; i < func.len; ++i){
        if (0 == strcmp(func.data[i], $2)){
            fprintf(stderr,"Error line %llu : Function %s already declared; exiting.\n", current_line, $2);  
            exit(-1);
        }
    }
    VecPush(&func, $2);

    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "func %s\n", $2);
    sprintf(temp_buf + strlen(temp_buf), "%s", $7);
    sprintf(temp_buf + strlen(temp_buf), "endfunc\n");
    $$ = strdup(temp_buf);
}

function_call:
ID L_P param_pass R_P { 
    int found = 0, i = 0;
    for (; i < func.len; ++i) {
        if (strcmp(func.data[i], $1) == 0) {
            found = 1;
            break;
        }
    }
    if (!found) {
        fprintf(stderr, "Error line %llu : Access to undeclared function %s; exiting.\n", current_line, $1);
    }
    char* name = genTempName();
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ". %s\n", name);
    sprintf(temp_buf + strlen(temp_buf), "call %s, %s\n", $1, name);
    $$ = strdup(temp_buf);
}

param_pass: 
    m_exp {
        printf("param %s\n", $1);
    }
    | param_pass COMMA m_exp {
        printf("param %s\n", $3);
    }

param: { $$ = "" }
| DEC ID { 
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ". %s\n", $2);
    $$ = strdup(temp_buf);
 }
| DEC ID COMMA param { 
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ". %s\n", $2);
    sprintf(temp_buf + strlen(temp_buf), ". %s\n", $4);
    $$ = strdup(temp_buf);
 }
| DEC S_COND E_COND ID { 
    VecPush(&arrayVar, $4);
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ".[] %s, %s\n", $4, "1");
    $$ = strdup(temp_buf);
 }
| DEC S_COND E_COND ID COMMA param { 
    VecPush(&arrayVar, $4);
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ".[] %s, %s\n", $4, "1");
    sprintf(temp_buf + strlen(temp_buf), "%s", $6);
    $$ = strdup(temp_buf);
 }

array_dec: 
DEC S_COND m_exp E_COND ID {
    VecPush(&arrayVar, $5);
    char temp_buf[MAX_LENGTH];
    if(atoi(strdup($3)) <= 0){
        fprintf(stderr, "Error line %llu : Declaration of array %s with size <= 0 \n", current_line, $5);
    }
    sprintf(temp_buf, ".[] %s, %s\n", $5, $3);
    $$ = strdup(temp_buf);
}

while:
WHILE S_COND cond E_COND GROUPING stmts{
    char *begin = beginWhileLoopTop();
    char *end = endWhileLoopTop();
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ": %s\n", begin);

    sprintf(temp_buf + strlen(temp_buf), "%s", $3);
    char* condition = strdup(global_name_sub);
    char* inverse_cond = genTempName();
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
    char temp_buf[MAX_LENGTH];

    sprintf(temp_buf, "%s", $3);
    char* condition = strdup(global_name_sub);

    char* inverse_cond = genTempName();
    sprintf(temp_buf + strlen(temp_buf), "! %s, %s\n", inverse_cond, condition);

    sprintf(temp_buf + strlen(temp_buf), "?:= %s, %s\n", end, inverse_cond);
    sprintf(temp_buf + strlen(temp_buf), "%s", $6);

    sprintf(temp_buf + strlen(temp_buf), ":= %s\n", final);
    sprintf(temp_buf + strlen(temp_buf), ": %s\n", end);
    sprintf(temp_buf + strlen(temp_buf), "%s", $7);
    sprintf(temp_buf + strlen(temp_buf), ": %s\n", final);
    $$ = strdup(temp_buf);
}
elif: { $$ = ""; }
| ELIF S_COND cond E_COND GROUPING stmts elif { 
    char* end = "if_end", * final = "if_final_end";
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, "%s", $3);
    char *condition = strdup(global_name_sub);
    char* inverse_cond = genTempName();
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
ROUT L_P cond R_P { 
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ".> %s\n", $3);
    $$ = strdup(temp_buf);
}
| ROUT L_P ID DEC INT DEC R_P {
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ".[]> %s, %s\n", $3, $5);
    $$ = strdup(temp_buf);
}

break: 
BREAK { 
    char* final = "if_final_end";
    char temp_buf[MAX_LENGTH];
    sprintf(temp_buf, ":= %s\n", final);
    $$ = strdup(temp_buf);
}

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


%%
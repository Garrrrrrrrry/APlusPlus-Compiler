%{ 
    #include <stdio.h>

    int yylex (void);

    int val;

    void yyerror(char const *err) { fprintf(stderr, "yyerror: %s\n", err); exit(-1);}
%}


%define parse.error custom



%token INT L_P R_P IF S_COND E_COND GROUPING SEMICOLON RIN ROUT ELSE ID

%left ADD SUB MUL DIV
%left EQ LT GT GEQ LEQ NE

%union {
    int num;
    char* str;
}

%type<num> INT stmt add_exp mul_exp exp
%type<str> ID
%%

program: stmt {}
| program stmt {}


stmt: add_exp EQ{ printf("%d\n", $1); }
| if_else_stmt {  }
| read {}


read: read_out {}
| read_in {}

read_in: RIN L_P stmt R_P SEMICOLON{ printf("taking input from command line\n"); }

read_out: ROUT L_P ID R_P SEMICOLON{ printf("Printing %s to command line\n", $3); }
| ROUT L_P INT R_P SEMICOLON{ printf("Printing %d to command line\n", $3); }

if_else_stmt: if_stmt stmt else_stmt stmt SEMICOLON
| if_stmt stmt SEMICOLON

if_stmt: IF S_COND add_exp EQ add_exp E_COND GROUPING { printf("If %d is equivalent to %d, then do something\n", $3, $5);}
| IF S_COND add_exp LT add_exp E_COND GROUPING { printf("If %d is less than %d, then do something\n", $3, $5);}
| IF S_COND add_exp GT add_exp E_COND GROUPING { printf("If %d is greater than %d, then do something\n", $3, $5);}
| IF S_COND add_exp GEQ add_exp E_COND GROUPING { printf("If %d is greater than or equal to %d, then do something\n", $3, $5);}
| IF S_COND add_exp LEQ add_exp E_COND GROUPING { printf("If %d is less than or equal to %d, then do something\n", $3, $5);}
| IF S_COND add_exp NE add_exp E_COND GROUPING { printf("If %d is not equivalent to %d, then do something\n", $3, $5);}

else_stmt: ELSE GROUPING{ printf("Else, do something else.\n"); }
|

add_exp: mul_exp { $$ = $1; }
| add_exp ADD add_exp { $$ = $1 + $3; }
| add_exp SUB add_exp { $$ = $1 - $3; }

mul_exp: exp { $$ = $1; }
| mul_exp MUL mul_exp { $$ = $1 * $3; }
| mul_exp DIV mul_exp { $$ = $1 / $3; }

exp: INT { $$ = $1; }
| SUB exp { $$ = -$2; }
| L_P add_exp R_P { $$ = $2; }


%%

static int yyreport_syntax_error(const yypcontext_t *ctx) {
    yysymbol_kind_t tokenCausingError = yypcontext_token(ctx);
    yysymbol_kind_t expectedTokens[YYNTOKENS];
    int INTExpectedTokens = yypcontext_expected_tokens(ctx, expectedTokens, YYNTOKENS);

    fprintf(stderr, "\n-- Syntax Error --\n");
    fprintf(stderr, "%llu line, %llu column\n", current_line, current_column);
    fprintf(stderr, "Token causing error: %s\n", yysymbol_name(tokenCausingError));
    for(int i = 0; i < INTExpectedTokens; ++i) {
        fprintf(stderr, " expected token (%d/%d) %s\n", i+1, INTExpectedTokens, yysymbol_name(expectedTokens[i]));
    }

    return 0;
}
%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "llvm-c/Core.h"
  
// Need for parser and scanner
extern FILE *yyin;
int yylex();
void yyerror(const char*);
int yyparse();
 
// Needed for LLVM
char* funName;
LLVMModuleRef M;
LLVMBuilderRef  Builder;

 typedef struct string_list_node_def {
   struct string_list_node_def *next;
   const char *str;
 } string_list_node;

 typedef struct {
   string_list_node *head;
   string_list_node *tail;
 } string_list;

 string_list* string_list_create() {
   string_list *list = malloc(sizeof(string_list));
   list->head = NULL;
   list->tail = NULL;
   return list;
 }
 
 void string_list_append(string_list *list, const char * str)
 {
   string_list_node *node = malloc(sizeof(string_list_node));
   node->str = str;
   node->next = NULL;
   if (list->tail) {
     list->tail->next = node;
     list->tail = node;
   } else {
     list->head = list->tail = node;
   }
 }
 
%}

%union {
  string_list *params_list;
}

/*%define parse.trace*/

%token ERROR

%token RETURN
%token DET TRANSPOSE INVERT
%token REDUCE
%token MATRIX
%token X

%token FLOAT
%token INT
%token ID

%token SEMI COMMA

%token PLUS MINUS MUL DIV
%token ASSIGN

%token LBRACKET RBRACKET
%token LPAREN RPAREN 
%token LBRACE RBRACE 

%type expr
%type <params_list> params_list
%type matrix_rows
%type matrix_row expr_list
%type dim

%left PLUS MINUS
%left MUL DIV 


%start program

%%

program: ID {
  // set name of function, this is okay, no need to change
  //funName = $1;
} LPAREN params_list_opt RPAREN LBRACE statements_opt return RBRACE
{
  // parsing is done, input is accepted
  YYACCEPT;
}
;


params_list_opt: params_list 
{  
  string_list_node *tmp = $1->head;
  int cnt=0;
  while(tmp)
    {
      cnt++;
      tmp = tmp->next;
    }

  LLVMTypeRef *paramTypes = malloc(sizeof(LLVMTypeRef)*cnt);
  for(int i=0; i<cnt; i++)
    paramTypes[i] = LLVMFloatType();
  
  LLVMTypeRef FnTy = LLVMFunctionType(LLVMFloatType(),paramTypes,0,0);

  // Make a void function named main (the start of the program!)
  LLVMValueRef Fn = LLVMAddFunction(M,funName,FnTy);

  // Add a basic block to main to hold new instructions
  LLVMBasicBlockRef BB = LLVMAppendBasicBlock(Fn,"entry");

  // Create a Builder object that will construct IR for us
  Builder = LLVMCreateBuilder();
  // Ask builder to place new instructions at end of the
  // basic block
  LLVMPositionBuilderAtEnd(Builder,BB);
  
}
| %empty
{ 
  // Make a void function type with no arguments
  LLVMTypeRef FnTy = LLVMFunctionType(LLVMFloatType(),NULL,0,0);

  // Make a void function named main (the start of the program!)
  LLVMValueRef Fn = LLVMAddFunction(M,funName,FnTy);

  // Add a basic block to main to hold new instructions
  LLVMBasicBlockRef BB = LLVMAppendBasicBlock(Fn,"entry");

  // Create a Builder object that will construct IR for us
  Builder = LLVMCreateBuilder();
  // Ask builder to place new instructions at end of the
  // basic block
  LLVMPositionBuilderAtEnd(Builder,BB);
}
;

params_list: ID
{
  $$ = string_list_create();
  string_list_append($$,"");
  // add ID to vector
}
| params_list COMMA ID
{
  // add ID to $1
}
;

return: RETURN expr SEMI
{
  // FIX ME, ALWAYS RETURNS 0
  LLVMBuildRet(Builder,LLVMConstReal(LLVMFloatType(),1e4));
}
;

// These may be fine without changes
statements_opt: %empty
            | statements;

// These may be fine without changes
statements:   statement 
            | statements statement 
;

//FIXME: implement these rules
statement:
  ID ASSIGN expr SEMI
| ID ASSIGN MATRIX dim LBRACE matrix_rows RBRACE SEMI
;


//FIXME: implement these rules
dim: LBRACKET INT X INT RBRACKET
;

//FIXME: implement these rules
matrix_rows: matrix_row
| matrix_rows COMMA matrix_row
;

//FIXME: implement these rules
matrix_row: LBRACKET expr_list RBRACKET
;

//FIXME: implement these rules
expr_list: expr
| expr_list COMMA expr
;

//FIXME: implement these rules
expr: ID
| FLOAT
| INT
| expr PLUS expr
| expr MINUS expr
| expr MUL expr
| expr DIV expr
| MINUS expr
| DET LPAREN expr RPAREN
| INVERT LPAREN expr RPAREN
| TRANSPOSE LPAREN expr RPAREN
| ID LBRACKET INT COMMA INT RBRACKET
| REDUCE LPAREN expr RPAREN
| LPAREN expr RPAREN 
;


%%

LLVMModuleRef parseP1File(const char* InputFilename)
{
  // Figure out module name
  char *pos = strrchr(InputFilename,'/');
  const char *modName;
  if (pos)
    modName = strdup(pos+1);
  else 
    modName = strdup(InputFilename);
  pos = strchr(modName,'.');
  if (pos) *pos = 0;

  // Make Module
  M = LLVMModuleCreateWithName(modName);
  free((void*)modName);
  
  if (strcmp(InputFilename,"--")==0)
    yyin = stdin;
  else
    yyin = fopen(InputFilename,"r");

  //yydebug = 1;
  if (yyparse() != 0) {
    // errors, so discard module
    return NULL;
  } else {
    LLVMDumpModule(M);
    return M;
  }
}

void yyerror(const char* msg)
{
  printf("%s\n",msg);
}

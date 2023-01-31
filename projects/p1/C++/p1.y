%{
#include <cstdio>
#include <list>
#include <vector>
#include <map>
#include <iostream>
#include <fstream>
#include <string>
#include <memory>
#include <stdexcept>

#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/Verifier.h"

#include "llvm/Bitcode/BitcodeReader.h"
#include "llvm/Bitcode/BitcodeWriter.h"
#include "llvm/Support/SystemUtils.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/FileSystem.h"

using namespace llvm;
using namespace std;


// Need for parser and scanner
extern FILE *yyin;
int yylex();
void yyerror(const char*);
int yyparse();
 
// Needed for LLVM
string funName;
Module *M;
LLVMContext TheContext;
IRBuilder<> Builder(TheContext);

%}


%union {
  int dummy; 
}

%define parse.trace

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

%type params_list
%type expr

%type matrix_rows
%type matrix_row expr_list
%type dim

%left PLUS MINUS
%left MUL DIV 

%start program

%%

program: ID {
  // FIXME: set name of function, this is okay, no need to change
  funName = "main"; // FIXME: should not be main!
} LPAREN params_list_opt RPAREN LBRACE statements_opt return RBRACE
{
  // parsing is done, input is accepted
  YYACCEPT;
}
;

//FIXME: some changes needed below
params_list_opt:  params_list 
{
  // FIXME: This action needs attention!
  
  // FIXME: this is hard-coded to be a single parameter:
  std::vector<Type*> param_types(1,Builder.getFloatTy());  
  ArrayRef<Type*> Params (param_types);
  
  // Create int function type with no arguments
  FunctionType *FunType = 
    FunctionType::get(Builder.getFloatTy(),Params,false);

  // Create a main function
  Function *Function = Function::Create(FunType,GlobalValue::ExternalLinkage,funName,M);

  int arg_no=0;
  for(auto &a: Function->args()) {
    //
    // FIXME: match arguments to name in parameter list
    // iterate over arguments of function
    //
  }
  
  //Add a basic block to main to hold instructions, and set Builder
  //to insert there
  Builder.SetInsertPoint(BasicBlock::Create(TheContext, "entry", Function));
}
| %empty
{ 
  // Create int function type with no arguments
  FunctionType *FunType = 
    FunctionType::get(Builder.getFloatTy(),false);

  // Create a main function
  Function *Function = Function::Create(FunType,  
         GlobalValue::ExternalLinkage,funName,M);

  //Add a basic block to main to hold instructions, and set Builder
  //to insert there
  Builder.SetInsertPoint(BasicBlock::Create(TheContext, "entry", Function));
}
;

params_list: ID
{
  // FIXME: remember ID
}
| params_list COMMA ID
{
  // FIXME: remember ID
}
;

return: RETURN expr SEMI
{
  // FIXME: always returns 0.0
  Builder.CreateRet(ConstantFP::get(Builder.getFloatTy(), 1e4));
}
;

// These may be fine without changes
statements_opt: %empty
            | statements
;

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

unique_ptr<Module> parseP1File(const string &InputFilename)
{
  string modName = InputFilename;
  if (modName.find_last_of('/') != string::npos)
    modName = modName.substr(modName.find_last_of('/')+1);
  if (modName.find_last_of('.') != string::npos)
    modName.resize(modName.find_last_of('.'));

  // unique_ptr will clean up after us, call destructor, etc.
  unique_ptr<Module> Mptr(new Module(modName.c_str(), TheContext));

  // set global module
  M = Mptr.get();
  
  /* this is the name of the file to generate, you can also use
     this string to figure out the name of the generated function */

  if (InputFilename == "--")
    yyin = stdin;
  else	  
    yyin = fopen(InputFilename.c_str(),"r");

  //yydebug = 1;
  if (yyparse() != 0) {
    // Dump LLVM IR to the screen for debugging
    M->print(errs(),nullptr,false,true);
    // errors, so discard module
    Mptr.reset();
  } else {
    // Dump LLVM IR to the screen for debugging
    M->print(errs(),nullptr,false,true);
  }
  
  return Mptr;
}

void yyerror(const char* msg)
{
  printf("%s\n",msg);
}

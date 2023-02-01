%{
#include <cstdio>
#include <list>
#include <map>
#include <iostream>
#include <string>
#include <memory>
#include <stdexcept>

#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/IRBuilder.h"

#include "llvm/Bitcode/BitcodeReader.h"
#include "llvm/Bitcode/BitcodeWriter.h"
#include "llvm/Support/SystemUtils.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Support/FileSystem.h"

using namespace llvm;

static LLVMContext TheContext;
static IRBuilder<> Builder(TheContext);


extern FILE *yyin;
int yylex();
void yyerror(const char*);

extern "C" {
  int yyparse();
}

// helper code 
template<typename ... Args>
std::string format( const std::string& format, Args ... args )
{
    size_t size = snprintf( nullptr, 0, format.c_str(), args ... ) + 1; // Extra space for '\0'
    if( size <= 0 ){ throw std::runtime_error( "Error during formatting." ); }
    std::unique_ptr<char[]> buf( new char[ size ] ); 
    snprintf( buf.get(), size, format.c_str(), args ... );
    return std::string( buf.get(), buf.get() + size - 1 ); // We don't want the '\0' inside
}


int getReg() {
  static int cnt = 8;
  return cnt++;
}

 Value *regs[8] = {nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr, nullptr};

%}

%verbose
%define parse.trace

%union {
  int reg;
  int imm;
  Value *val;
}
// Put this after %union and %token directives

%type <val> expr
%token <reg> REG
%token <imm> IMMEDIATE
%token RETURN ASSIGN SEMI PLUS MINUS LPAREN RPAREN LBRACKET RBRACKET

%type expr

%left  PLUS MINUS

%%

program:   REG ASSIGN expr SEMI
{
  regs[$1] = $3;
}
| program REG ASSIGN expr SEMI
{ 
  regs[$2] = $4;
}
| program RETURN expr SEMI
{
  // add action
  //printf("RET R%d\n", $3);
  Builder.CreateRet($3);
  return 0; /* program is done */
}
;

expr: IMMEDIATE
{
  $$ = Builder.getInt32($1);
}
| REG
{ 
  $$ = regs[$1];
}
| expr PLUS expr
{
  $$ = Builder.CreateAdd($1, $3, "add");
}
| expr MINUS expr
{
  $$ = Builder.CreateSub($1, $3, "sub");
}
| LPAREN expr RPAREN
{
  $$ = $2;
}
| MINUS expr
{
  $$ = Builder.CreateNeg($2, "neg");
}
| LBRACKET expr RBRACKET
{
  Value * tmp = Builder.CreateIntToPtr($2,   
                   PointerType::get(Builder.getInt32Ty(),0));

  $$ = Builder.CreateLoad(Builder.getInt32Ty(),tmp,"load");

  //int reg = getReg();
  //printf("LDR R%d, R%d, 0\n", reg, $2);
  //$$ = reg;
}
;

%%

void yyerror(const char* msg)
{
  printf("%s",msg);
}

int main(int argc, char *argv[])
{
  yydebug = 0;
  yyin = stdin; // get input from screen

  // Make Module
  Module *M = new Module("Tutorial2", TheContext);

  std::vector<Type*> argTypes(8, Builder.getInt32Ty());
  
  // Create void function type with no arguments
  FunctionType *FunType = 
    FunctionType::get(Builder.getInt32Ty(),argTypes,false);
  
  // Create a main function
  Function *Function = Function::Create(FunType,  
					GlobalValue::ExternalLinkage, "fun",M);
  
  //Add a basic block to main to hold instructions
  BasicBlock *BB = BasicBlock::Create(TheContext, "entry",
				      Function);
  // Ask builder to place new instructions at end of the
  // basic block
  Builder.SetInsertPoint(BB);

  for(int i=0; i<8; i++)
    // set regs[i] to point to argument i
    regs[i] = Function->arg_begin()+i;
  
  // Now we’re ready to make IR, call yyparse()

  if (yyparse()==0) {
    std::error_code EC;
    raw_fd_ostream OS("main.bc",EC,sys::fs::OF_None);
    WriteBitcodeToFile(*M,OS);

    // Dump LLVM IR to the screen for debugging                                                                                                
    M->print(errs(),nullptr,false,true);
  }
  
  return 0;
}

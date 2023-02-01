%{
#include <stdio.h>
#include <math.h>
#include <cstdio>
#include <list>
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

using namespace std;
using namespace llvm;  

#include "p1.y.hpp"
%}

  //%option debug

%%

[ \t\n]         //ignore

return       { return ERROR; }
det          { return ERROR; }
transpose    { return ERROR; }
invert       { return ERROR; }
matrix       { return ERROR; }
reduce       { return ERROR; }
x            { return ERROR; }

[a-zA-Z_][a-zA-Z_0-9]* { return ERROR; }

[0-9]+        { return ERROR; }

[0-9]+        { return ERROR; }
[0-9]+("."[0-9]*) { return ERROR; }

"["           { return ERROR; }
"]"           { return ERROR; }
"{"           { return ERROR; }
"}"           { return ERROR; }
"("           { return ERROR; }
")"           { return ERROR; }

"="           { return ERROR; }
"*"           { return ERROR; }
"/"           { return ERROR; }
"+"           { return ERROR; }
"-"           { return ERROR; }

","           { return ERROR; }

";"           { return ERROR; }


"//".*\n      { }

.             { return ERROR; }
%%

int yywrap()
{
  return 1;
}

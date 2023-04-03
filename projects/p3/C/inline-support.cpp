/*
 * File: dominance.cpp
 *
 * Description:
 *   This provides a C interface to the dominance analysis in LLVM
 */

#include <stdio.h>
#include <stdlib.h>

/* LLVM Header Files */
#include "llvm-c/Core.h"

#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/GlobalVariable.h"
//#include "llvm/PassManager.h"
#include "llvm/IR/Dominators.h"
//#include "llvm/Analysis/PostDominators.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/Type.h"

#include "inline.h"
#include "llvm/Transforms/Utils/Cloning.h"

using llvm::InlineFunction;
using llvm::InlineFunctionInfo;
using llvm::CallInst;
using llvm::dyn_cast;


void InlineFunction(LLVMValueRef Call)
{
  CallInst *CI = dyn_cast<CallInst>(llvm::unwrap(Call));
  if (CI) {
    llvm::InlineFunctionInfo IFI;
    llvm::InlineFunction(*CI, IFI);
    return ;
  }
}
  


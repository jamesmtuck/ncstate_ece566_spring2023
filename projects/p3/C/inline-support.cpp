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
#include "llvm/Analysis/InlineCost.h"

using llvm::InlineFunction;
using llvm::InlineFunctionInfo;
using llvm::CallInst;
using llvm::dyn_cast;
using llvm::isInlineViable;

LLVMBool InlineFunction(LLVMValueRef Call)
{
  CallInst *CI = dyn_cast<CallInst>(llvm::unwrap(Call));
  llvm::Function *F = CI->getCalledFunction();
  if (F) {
    llvm::InlineFunctionInfo IFI;
    llvm::InlineResult IR = isInlineViable(*F);
    if (IR.isSuccess()) {
      InlineFunction(*CI, IFI);
      return true;
    }
  }
  return false;
}

  


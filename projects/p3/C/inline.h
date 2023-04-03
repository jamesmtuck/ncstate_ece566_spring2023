#ifndef INLINE_H
#define INLINE_H

//#include "llvm/Support/DataTypes.h"
//#include "llvm-c/Core.h"
#include "llvm-c/DataTypes.h"
#include "llvm-c/ExternC.h"

LLVM_C_EXTERN_C_BEGIN

void InlineFunction(LLVMValueRef Call);

LLVM_C_EXTERN_C_END

#endif

#include <stdlib.h>
#include "llvm-c/Core.h"

#include "stats.h"
#include "inline.h"
#include "worklist.h"

LLVMStatisticsRef Inlined;
LLVMStatisticsRef InlineConstArg;
LLVMStatisticsRef InlineSizeReq;

int inline_const_arg = 0;
int inline_function_size_limit=1000000000;
int inline_growth_factor=1000;
int inline_heuristic = 0;

void DoInlining(LLVMModuleRef M)
{
  
  Inlined = LLVMStatisticsCreate("Inlined", "Number of inlined functions");
  InlineConstArg = LLVMStatisticsCreate("ConstArg",
					"Inlined functions with a constant argument");
  InlineSizeReq = LLVMStatisticsCreate("SizeReq",
				       "Inlined functions meeting size restriction.");

  /* Implement here! */

  
  //LLVMValueRef Call = ...;
  //InlineFunction(Call);
  
  //Update stats as needed
  //LLVMStatisticsInc(Inlined);
}

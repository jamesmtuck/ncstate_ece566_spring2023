// dce.cpp

#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <set>

#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Value.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Verifier.h"

#include "llvm/ADT/Statistic.h"

#include "llvm/Bitcode/BitcodeReader.h"
#include "llvm/Bitcode/BitcodeWriter.h"
#include "llvm/Support/SystemUtils.h"
#include "llvm/Support/ToolOutputFile.h"
#include "llvm/Support/FileSystem.h"

#include "llvm/IR/LegacyPassManager.h"
#include "llvm/LinkAllPasses.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/SourceMgr.h"

#include "llvm/IRReader/IRReader.h"
#include "llvm/Support/SourceMgr.h"

#include "llvm/Support/CommandLine.h"

using namespace llvm;

static cl::opt<std::string>
        InputFilename(cl::Positional, cl::desc("<input bitcode>"), cl::Required, cl::init("-"));

static cl::opt<std::string>
        OutputFilename(cl::Positional, cl::desc("<output bitcode>"), cl::Required, cl::init("out.bc"));

static cl::opt<bool>
        Mem2Reg("mem2reg",
                cl::desc("Perform memory to register promotion before CSE."),
                cl::init(false));

static cl::opt<bool>
        Verbose("verbose",
                cl::desc("Verbosely print lots of status messages to the screen."),
                cl::init(false));


static llvm::Statistic DeadInst = {"", "Dead", "DCE found dead instructions"};
static llvm::Statistic WorkList = {"", "WorkList", "Added to work list"};

void NoOptimization(Module &M) {
  // Do nothing! Simplest optimization that exists
  errs() << "Inside NoOptimization!\n";

  for(auto f = M.begin(); f!=M.end(); f++)
    {
      // loop over functions
      for(auto bb= f->begin(); bb!=f->end(); bb++)
	{
	  // loop over basic blocks
	  for(auto i = bb->begin(); i != bb->end(); i++)
	    {
	      //loop over instructions

	      errs() << "All users of the instruction: " ;
	      i->print(errs(),true);
	      errs() << "\n";

	      using use_iterator = Value::use_iterator;

	      for(use_iterator u = i->use_begin(); u!=i->use_end(); u++)
		{
		  Value *v = u->getUser();
		  errs() << "   ";
		  v->print(errs(),true);
		  errs() << "\n";
		}

	      for(unsigned op=0; op < i->getNumOperands(); op++) 
		{
		  Value* def = i->getOperand(op);

		  if ( isa<Instruction>(def) ) {
		    errs() << "   Definition of op=" << op << " is:" ;
		    def->print(errs(),true);
		    errs() << "\n";
		  } else {
		  }
		} 

	      
	    }    
	}
    }
}

bool isDead(Instruction &I) {

  int opcode = I.getOpcode();
  switch(opcode){
  case Instruction::Add:
  case Instruction::FNeg:
  case Instruction::FAdd: 	
  case Instruction::Sub:
  case Instruction::FSub: 	
  case Instruction::Mul:
  case Instruction::FMul: 	
  case Instruction::UDiv:	
  case Instruction::SDiv:	
  case Instruction::FDiv:	
  case Instruction::URem: 	
  case Instruction::SRem: 	
  case Instruction::FRem: 	
  case Instruction::Shl: 	
  case Instruction::LShr: 	
  case Instruction::AShr: 	
  case Instruction::And: 	
  case Instruction::Or: 	
  case Instruction::Xor: 	
  case Instruction::Alloca:
  case Instruction::GetElementPtr: 	
  case Instruction::Trunc: 	
  case Instruction::ZExt: 	
  case Instruction::SExt: 	
  case Instruction::FPToUI: 	
  case Instruction::FPToSI: 	
  case Instruction::UIToFP: 	
  case Instruction::SIToFP: 	
  case Instruction::FPTrunc: 	
  case Instruction::FPExt: 	
  case Instruction::PtrToInt: 	
  case Instruction::IntToPtr: 	
  case Instruction::BitCast: 	
  case Instruction::AddrSpaceCast: 	
  case Instruction::ICmp: 	
  case Instruction::FCmp: 	
  case Instruction::PHI: 
  case Instruction::Select: 
  case Instruction::ExtractElement: 	
  case Instruction::InsertElement: 	
  case Instruction::ShuffleVector: 	
  case Instruction::ExtractValue: 	
  case Instruction::InsertValue: 
    if ( I.use_begin() == I.use_end() )
         {
	       return true;
         }
         break;

  case Instruction::Load:
    {
      LoadInst *li = dyn_cast<LoadInst>(&I);
      if (li && li->isVolatile())
	   return false;
      if (I.use_begin() == I.use_end())
         return true;
      break;
      
    }
  
  default: 
    // any other opcode fails 
      return false;
  }

  
  return false;
}

void RunDeadCodeElimination(Module &M) {
  // Use standard template library for a set
  std::set<Instruction*> worklist;

  for(auto f = M.begin(); f!=M.end(); f++)
    {
      // loop over functions
      for(auto bb= f->begin(); bb!=f->end(); bb++)
	{
	  // loop over basic blocks
	  for(auto i = bb->begin(); i != bb->end(); i++)
	    {
	      if (isDead(*i)) {
		// remove the instruction
		errs() << "Found a dead instruction." ;
		i->print(errs(),true);
		errs() << "\n";

		worklist.insert(&*i);
		//i->eraseFromParent();
	      }
	      //loop over instructions and find the dead ones
	    }
	}
    }

  while(worklist.size()>0) 
    {
      // Get the first item 
	Instruction *i = *(worklist.begin());
   // Erase it from worklist
      worklist.erase(i);

      if(isDead(*i))
	{
	  for(unsigned op=0; op<i->getNumOperands(); op++)
	    {
	      // Note, op still has one use so the isDead routine
	      // would return false, so don’t check that yet.
	      // This forces us to check in the if statement above.
	      
	      // The operand could be many different things, in 
		// particular constants. Don’t try to delete it
		// unless its an instruction:
		if ( isa<Instruction>(i->getOperand(op)) ) 
		  {
		    Instruction *o = 
		      cast<Instruction>(i->getOperand(op));
		    worklist.insert(o);
		    WorkList++;
		  }
	    }
	  
	  
	  // Erase from basic block
	  i->eraseFromParent();
	  DeadInst++;
	}
    }

}

int main(int argc, char **argv) {
    cl::ParseCommandLineOptions(argc, argv, "./dce <input> <output> \n");

    // LLVM idiom for constructing output file.
    std::unique_ptr<ToolOutputFile> Out;
    std::string ErrorInfo;
    std::error_code EC;
    Out.reset(new ToolOutputFile(OutputFilename, EC,
                                 sys::fs::OF_None));

    SMDiagnostic Err;
    std::unique_ptr<Module> M;
    LLVMContext *Context = new LLVMContext();
    M = parseIRFile(InputFilename, Err, *Context);

    if (M.get() == 0) {
        Err.print(argv[0], errs());
        return 1;
    }

    EnableStatistics();

    if (Mem2Reg) {
        if (Verbose)
            errs() << "Run Mem2Reg.\n";
        legacy::PassManager Passes;
        Passes.add(createPromoteMemoryToRegisterPass());
        Passes.run(*M.get());
    }
    if (Verbose)
        M->print(errs(), nullptr);

    /* 3. Do optimization on Module */
    //NoOptimization(*M.get());
    RunDeadCodeElimination(*M.get());

    bool res = verifyModule(*M, &errs());
    if (!res) {
        WriteBitcodeToFile(*M.get(), Out->os());
        Out->keep();
    } else {
        fprintf(stderr, "Error: %s not created.\n", argv[2]);
    }

    PrintStatistics(errs());

    return 0;
}



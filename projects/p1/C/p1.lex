%{
#include <stdio.h>
#include <math.h>

#include "llvm-c/Core.h"

 typedef struct string_list_node_def {
   struct string_list_node_def *next;
   const char *str;
 } string_list_node;

 typedef struct {
   string_list_node *head;
   string_list_node *tail;
 } string_list;
  
#include "p1.y.h"

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

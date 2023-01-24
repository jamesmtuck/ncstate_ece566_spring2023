%{
#include <stdio.h>
#include <iostream>
#include <math.h>

  struct reg_or_imm {
   bool is_reg;
   int  val;
 };
  
#include "expr.y.hpp"
%}


%option noyywrap

%% // begin tokens

[ \n\t]    // ignore a space, a tab, a newline

[Rr][0-7]   { /*printf("REG %s\n", yytext);*/
              yylval.reg  = atoi(yytext+1);
              return REG; }
[0-9]+      { /*printf("IMMEDIATE %s\n",yytext);*/
              yylval.imm = atoi(yytext);
              return IMMEDIATE; }
          
"="         { /*printf("ASSIGN\n");*/ return ASSIGN;
              // More stuff here
            }
;           { /*printf("SEMI\n");*/ return SEMI; }
"("       { /*printf("LPAREN\n");*/ return LPAREN; }
")"       { /*printf("RPAREN\n");*/  return RPAREN; }
"["       { /*printf("LBRACKET\n");*/ return LBRACKET;}
"]"       { /*printf("RBRACKET\n");*/ return RBRACKET; }
"-"       { /*printf("MINUS\n");*/ return MINUS; }
"+"       { /*printf("PLUS\n");*/ return PLUS; }

"//".*\n  

.         {   // If we match anything unexpected, just exit the scanner and report an error.
              printf("syntax error!\n"); exit(1);
          }

%% // end tokens


// put more C code that I want in the final scanner

#ifdef SCANNER_ONLY

// This is the main function when we compile just the scanner: make scanner
int main(int argc, char *argv[])
{
  // all the rules above are combined into a single function called yylex, we call it to trigger
  // the scanner to read the input and match tokens:

  yylex();
  // yylex has a return value, but we ignore it for now.
 
  return 0;
}

#endif

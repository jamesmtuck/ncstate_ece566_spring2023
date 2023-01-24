%{
#include <cstdio>
#include <list>
#include <map>
#include <iostream>
#include <string>
#include <memory>
#include <stdexcept>


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


%}

%verbose
%define parse.trace

%union {
  int reg;
  int imm;
}
// Put this after %union and %token directives

%type <reg> expr
%token <reg> REG
%token <imm> IMMEDIATE
%token RETURN ASSIGN SEMI PLUS MINUS LPAREN RPAREN LBRACKET RBRACKET

%type expr

%left  PLUS MINUS



%%

program:   REG ASSIGN expr SEMI
{
  printf("ADD R%d, R%d, 0\n", $1,  $3);
}
| program REG ASSIGN expr SEMI
{ 
  // add action
}
| program RETURN REG SEMI
{
  // add action
  return 0; /* program is done */
}

;

expr: IMMEDIATE
{
  int reg = getReg();
  printf("AND R%d, R%d, 0\n", reg, reg);
  printf("ADD R%d, R%d, %d\n", reg, reg, $1);
  $$ = reg;
}
| REG
{ 
  //printf("expr: REG (%d)\n", $1);
  $$ = $1;
}
| expr PLUS expr
{
  //printf("expr: expr PLUS expr\n");
  int reg = getReg();
  printf("ADD R%d, R%d, R%d\n", reg, $1, $3);
  $$ = reg;
}
| expr MINUS expr
{
  int reg = getReg();
  printf("SUB R%d, R%d, R%d\n", reg, $1, $3);
  $$ = reg;
}
| LPAREN expr RPAREN
{
  $$ = $2;
}
| MINUS expr
{
  int reg = getReg();
  printf("NOT R%d, R%d\n", reg, $2);
  printf("ADD R%d, R%d, 1\n", reg, reg);
}
| LBRACKET expr RBRACKET
{
  int reg = getReg();
  printf("LDR R%d, R%d, 0\n", reg, $2);
  $$ = reg;
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
  yyparse();
  
  return 0;
}

%{ /* -*- C++ -*- */
#include <cerrno>
#include <climits>
#include <cstdlib>
#include <cstring> // strerror
#include <string>
#include "driver.h"
#include "AbsSyn.h"
#include "parser.h"
%}

%option noyywrap nounput noinput batch debug

whitespace	[ \t\r\n]

digit				[0-9]
natural			{digit}+
negative		\-{natural}
double			(({negative}|{natural})\.{natural})

letter			[a-zA-Z]
ident				{letter}({letter}|{digit}|\_-)*

l_comment		"//"[^\n]*\n
ml_comment	"/*"((("*"[^/])?)|[^*])*"*/"

%{
  // Code run each time a pattern is matched.
  #define YY_USER_ACTION \
		loc.step();\
		for (int i = 0; i < yyleng; i++) {\
			if (yytext[i] == '\n') { loc.lines(); loc.step(); }\
			else { loc.columns(); }\
		}
%}

%%

%{
  // A handy shortcut to the location held by the driver.
  yy::location& loc = drv.location;
  // Code run each time yylex is called.
  loc.step ();
%}

problem								return yy::parser::make_PROB(loc);
reachability					return yy::parser::make_REACH(loc);
synthesis							return yy::parser::make_SYNTH(loc);
variable_mode					return yy::parser::make_VARMODE(loc);
parameter_mode				return yy::parser::make_PARAMMODE(loc);
boxes									return yy::parser::make_BOX(loc);
parallelotopes				return yy::parser::make_PARAL(loc);
polytopes							return yy::parser::make_POLY(loc);
var										return yy::parser::make_VAR(loc);
param									return yy::parser::make_PARAM(loc);
const									return yy::parser::make_CONST(loc);
in										return yy::parser::make_IN(loc);
dynamic								return yy::parser::make_DYN(loc);
spec									return yy::parser::make_SPEC(loc);
iterations						return yy::parser::make_ITER(loc);
direction							return yy::parser::make_DIR(loc);
template							return yy::parser::make_TEMPL(loc);
parameter_direction		return yy::parser::make_PDIR(loc);
option								return yy::parser::make_OPT(loc);
transformation				return yy::parser::make_TRANS(loc);
AFO										return yy::parser::make_AFO(loc);
OFO										return yy::parser::make_OFO(loc);
decompositions				return yy::parser::make_DECOMP(loc);
sapo_alpha						return yy::parser::make_ALPHA(loc);
&&										return yy::parser::make_AND(loc);
\|\|									return yy::parser::make_OR(loc);
\!										return yy::parser::make_NOT(loc);
\<\=									return yy::parser::make_LE(loc);
\>\=									return yy::parser::make_GE(loc);
\=										return yy::parser::make_EQ(loc);
G											return yy::parser::make_ALWAYS(loc);
F											return yy::parser::make_EVENTUALLY(loc);
U											return yy::parser::make_UNTIL(loc);


"-"					return yy::parser::make_MINUS(loc);
"+"					return yy::parser::make_PLUS(loc);
"*"					return yy::parser::make_STAR(loc);
"("					return yy::parser::make_LPAREN(loc);
")"					return yy::parser::make_RPAREN(loc);
"["					return yy::parser::make_LSQUARE(loc);
"]"					return yy::parser::make_RSQUARE(loc);
"{"					return yy::parser::make_LBRACE(loc);
"}"					return yy::parser::make_RBRACE(loc);
"<"					return yy::parser::make_LANGLE(loc);
">"					return yy::parser::make_RANGLE(loc);

":"					return yy::parser::make_COLON(loc);
";"					return yy::parser::make_SEMICOLON(loc);
","					return yy::parser::make_COMMA(loc);

{natural}		return yy::parser::make_INTEGER(stoi(yytext), loc);

{double}		return yy::parser::make_DOUBLE(stof(yytext), loc);

{ident}			return yy::parser::make_IDENT(yytext, loc);

{whitespace}	; /* ignore whitespace */

{l_comment}		; /* ignore inline comments */

{ml_comment}	; /* ignore multiline comments */

<<EOF>>			return yy::parser::make_END(loc);
%%

void driver::scan_begin()
{
  yy_flex_debug = trace_scanning;
  if (file.empty() || file == "-")
    yyin = stdin;
  else if (!(yyin = fopen(file.c_str (), "r")))
    {
      std::cerr << "cannot open " << file << ": " << strerror(errno) << '\n';
      exit (EXIT_FAILURE);
    }
}

void driver::scan_end()
{
  fclose(yyin);
}

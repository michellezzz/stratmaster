%{
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "y.tab.h"
#include "symtab.h"
#include "runtime.h"
void yyerror(char *);
%}

comment		\/\*[^\*]*\*+([^\/\*][^\*]*\*+)*\/
digit		[0-9]
number		[0-9]+
id		[a-zA-Z][_a-zA-Z0-9]*
ws		[ \t]
wsn		[ \t\n]


%%
\S\T\R\A\T\E\G\Y		{ return(STRATEGY); }
\A\L\G\O\R\I\T\H\M  		{ return(ALGORITHM);}
\F\U\N\C\T\I\O\N  		{ return(FUNCTION);}
\U\S\E 				{ return(USE); }
\A\C\C\O\U\N\T			{ yylval.int_val = ACCOUNT_T; return(ACCOUNT); }
\D\A\T\A\F\E\E\D    		{ yylval.int_val = DATAFEED_T; return(DATAFEED);}
\D\A\T\A\B\A\S\E    		{ yylval.int_val = DATABASE_T; return(DATABASE);}
\E\X\C\H\A\N\G\E    		{ yylval.int_val = EXCHANGE_T; return(EXCHANGE);}
\B\U\Y				{ return(BUY); }
\S\E\L\L			{ return(SELL); }
\W\H\A\T 			{ return(WHAT); }
\A\M\O\U\N\T			{ return(AMOUNT); }
\E\Q\T\Y			{ return(EQTY); }
\P\R\I\C\E			{ return(PRICE); }
\S\E\T             		{ return(SET);}
\I\F                		{ return(IF);}
\W\H\E\R\E          		{ return(WHERE);}
\W\H\E\N           	 	{ return(WHEN);}
\U\N\T\I\L          		{ return(UNTIL);}
\R\E\T\U\R\N\S      		{ return(RETURNS);}
\I\N\T				{ yylval.int_val = INT_T; return(INT); }
\D\O\U\B\L\E  			{ yylval.int_val = DOUBLE_T; return(DOUBLE); }
\B\O\O\L\E\A\N			{ yylval.int_val = BOOLEAN_T; return(BOOLEAN); }
\S\E\C\U\R\I\T\Y		{ yylval.int_val = SECURITY_T; return(SECURITY); }
\V\O\I\D			{ yylval.int_val = VOID_T; return(VOID); }
\C\U\R\R\E\N\C\Y		{ yylval.int_val = CURRENCY_T; return(CURRENCY); }
\P\O\S\I\T\I\O\N		{ return(POSITION); }
\I\S				{ return(IS); }
\I\S\N\O\T			{ return(ISNOT); }
\T\R\U\E			{ return(TRUE_S); }
\F\A\L\S\E			{ return(FALSE_S); }
\O\R				{ return(OR); }
\A\N\D				{ return(AND); }
\N\O\T				{ return(NOT); }
\W\H\I\L\E			{ return(WHILE); }
\U\S\D				{ yylval.int_val = USD_T; return(USD); }
\E\U\R				{ yylval.int_val = EUR_T; return(EUR); }
\J\P\Y				{ yylval.int_val = JPY_T; return(JPY); }
\P\O\S				{ return(POS); }
\S\E\C				{ return(SEC); }
\A\M\T				{ return(AMT); }
\P\R\C				{ return(PRC); }
\A\V\A\I\L\_\C\A\S\H		{ return(AVAIL_CASH); }
\N\E\X\T			{ return(NEXT); }
{number}"."{digit}{digit}	{ strcpy(yylval.str, yytext); return(PRICESTRING); }
{digit}*"."{digit}		{ yylval.fp_val  = atof(yytext); return(FLOATPT); }
{number}			{ yylval.int_val = atoi(yytext); return(INTEGER); }
{id}				{ strcpy(yylval.str, yytext); return(IDENTIFIER); }
[:;{}().,=#<>+-/*]		{ return *yytext; }
{comment}			/* this is a comment; do nothing */ ;
{wsn}+				/* do nothing */  ;
.				yyerror("invalid input");
%%
int yywrap(void) { return 1; }


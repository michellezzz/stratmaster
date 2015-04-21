%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "symtab.h"
#include "ast.h"
#include "runtime.h"

/* Functions to interface with Lex */
int yylex(void);
void yyerror (char *s);

/* Other functions declarations */
void strat_error_msg(char *msg, int error_t, int lineno);

/* For debugging: print line numbers on error */
extern int yylineno;

/* Global Variables */
struct symbol_table *top;
struct symbol_table *parent;

%}

/* Data types for yylval in Lexer */
%union {
    char str[32];
    int  int_val;
    double fp_val;
};


%start program
%token STRATEGY ALGORITHM FUNCTION USE 
%token BUY SELL WHAT AMOUNT EQTY SET IF WHERE WHEN UNTIL RETURNS
%token POSITION IS ISNOT
%token TRUE_S FALSE_S OR AND NOT WHILE
%token USD EUR JPY POS SEC AMT PRC AVAIL_CASH NEXT
%token <str> IDENTIFIER PRICEXP
%token <int_val> INTEGER
%token <int_val> INT LONG DOUBLE BOOLEAN SECURITY VOID CURRENCY PRICE ACCOUNT DATAFEED DATABASE EXCHANGE 
%token <fp_val> FLOATPT

%type <program> program;
%type <use_list> use_list;
%type <use_others> use_others;
%type <decision_list> decision_list;
%type <algorithm_list> algorithm_list;
%type <algorithm_function> algorithm_function;
%type <algorithm_header> algorithm_header;
%type <algorithm_parameter_list> algorithm_parameter_list;
%type <target_list> target_list;
%type <compound_statement> compound_statement;
%type <variable_declaration_list> variable_declaration_list;
%type <variable_declaration> variable_declaration;
%type <type_specifier> type_specifier;
%type <arithmetic_type> arithmetic_type;
%type <statement_list> statement_list;
%type <statement> statement;
%type <set_statement> set_statement;
%type <argument_expression_list> argument_expression_list;
%type <unary_expression> unary_expression;
%type <postfix_expression> postfix_expression;
%type <primary_expression> primary_expression;
%type <logical_OR_expression> logical_OR_expression;
%type <logical_AND_expression> logical_AND_expression;
%type <equality_expression> equality_expression;
%type <relation_expression> relation_expression;
%type <additive_expression> additive_expression;
%type <multiplicative_expression> multiplicative_expression;
%type <expression> expression;
%type <assignment_expression> assignment_expression;

%type <strategy_list> strategy_list;
%type <strategy> strategy;
%type <strategy_body> strategy_body;
%type <strategy_block> strategy_block;
%type <action_list> action_list;
%type <order> order;
%type <order_type> order_type;
%type <constraint_list> constraint_list;
%type <constraint> constraint;
%type <order_item> order_item;
%type <security> security;
%type <security_type> security_type;
%type <process_statement_list> process_statement_list;
%type <process_statement> process_statement;

%%
program		: { fprintf(stdout, "STARTING PROGRAM\n"); parent = NULL; top = symbol_table_create(parent); } 
	 	  use_list process_list { fprintf(stdout, "ENDING PROGRAM\n"); print_symtab(top); }
	 	;

use_list	: USE  variable_declaration		
		| use_list USE variable_declaration 
		;

process_list	: strategy_list
	     	| function_list strategy_list
		| algorithm_list strategy_list
		| function_list algorithm_list strategy_list
		;	     	

function_list	: function_definition			{ fprintf(stdout, "Function\n"); }
		| function_list function_definition	{ fprintf(stdout, "Function\n"); }
		;

algorithm_list 	: algorithm_definition			{ fprintf(stdout, "Algorithm\n"); }
		| algorithm_list algorithm_definition	{ fprintf(stdout, "Algorithm\n"); }
		;

strategy_list 	: strategy_definition				{ fprintf(stdout, "Strategy\n"); }
		| strategy_list strategy_definition		{ fprintf(stdout, "Strategy\n"); }
		;

function_definition : function_header compound_statement
		;

function_header : FUNCTION IDENTIFIER '(' parameter_list ')' func_return	{ fprintf(stdout, "Function HDR\n"); }
		;

func_return	: RETURNS type_specifier
		;

algorithm_definition : algorithm_header compound_statement
		;

algorithm_header : ALGORITHM IDENTIFIER '(' parameter_list ')'		{ fprintf(stdout, "Algo Hdr\n"); }

parameter_list	: type_specifier IDENTIFIER				{ fprintf(stdout, "Param List\n"); }	
	       	| type_specifier '#' IDENTIFIER				{ fprintf(stdout, "Param List\n"); }
		| parameter_list ',' type_specifier '#' IDENTIFIER	{ fprintf(stdout, "Param List\n"); }
		| /* empty */
		;

strategy_definition : STRATEGY IDENTIFIER '{' strategy_body '}'
	  	;

strategy_body	: variable_declaration_list statement_list strategy_block
	      	| variable_declaration_list strategy_block 
		| strategy_block
		| /* empty */
		;

strategy_block	: action_list
		| process_statement_list
		;

process_statement_list : process_statement
		| process_statement_list process_statement
		;

process_statement : WHEN '(' expression ')' '{' process_body '}' UNTIL '(' expression ')' { fprintf(stdout, "Process statement\n"); } 
		| WHEN '(' expression ')' '{' process_body '}'				{ fprintf(stdout, "Process statement\n"); }
		;

process_body	: action_list
	     	| action_list statement_list
		;

action_list	: order_type '{' constraint_list '}'				{ fprintf(stdout, "Action List\n"); }
		| action_list order_type '{' constraint_list '}'		{ fprintf(stdout, "Action List\n"); }
		;

constraint_list	: constraint
		| constraint_list constraint
		;

constraint	: WHAT ':' order_item ';'
	   	| WHERE ':' IDENTIFIER ';'
		;

order_item	: security '.' AMOUNT '(' INTEGER ')''.' PRICE '(' price_expr ')' 	{ fprintf(stdout, "Order Item\n"); }
		;

price_expr	: PRICEXP
		| currency
		| IDENTIFIER
		;

variable_declaration_list : variable_declaration			 
		| variable_declaration_list variable_declaration
		;

variable_declaration : type_specifier IDENTIFIER ';'	{ if( install_symbol($<int_val>1, $<str>2, top) != 0 )
		    						strat_error_msg("Duplicated Symbol", 1, yylineno); }
		;

type_specifier	: INT					{ $<int_val>$ = $1; }
		| LONG					{ $<int_val>$ = $1; }
		| DOUBLE				{ $<int_val>$ = $1; }
		| BOOLEAN				{ $<int_val>$ = $1; }
		| SECURITY				{ $<int_val>$ = $1; }
		| PRICE					{ $<int_val>$ = $1; }
		| use_type				
		| VOID					{ $<int_val>$ = $1; }
		;

use_type	: ACCOUNT				{ $<int_val>$ = $1; }
		| DATAFEED				{ $<int_val>$ = $1; }
		| DATABASE				{ $<int_val>$ = $1; }
		| EXCHANGE				{ $<int_val>$ = $1; }
		;

security_type 	: EQTY
		;

currency_type	: USD
		| EUR
		| JPY
		;

order_type	: BUY
		| SELL
		;

statement	: expression_statement
	  	| compound_statement
		| selection_statement
		| iteration_statement
		| set_statement
		;

expression_statement : expression ';'
		| ';'
		;

compound_statement : '{' variable_declaration_list statement_list '}'
		| '{' statement_list '}'
		| '{' '}'
		;

statement_list	: statement
		| statement_list statement
		;

selection_statement : IF '(' expression ')' statement
		;

iteration_statement : WHILE '(' expression ')' statement
		;

set_statement 	: SET '{' argument_expression_list '}' IF ':' '{' expression '}'
		;

expression	: assignment_expression
            	| expression ',' assignment_expression
		;

assignment_expression : logical_OR_expression
            	| unary_expression '=' logical_OR_expression
		;

logical_OR_expression :  logical_AND_expression 
            	| logical_OR_expression OR logical_AND_expression
		;

logical_AND_expression : equality_expression
           	| logical_AND_expression AND equality_expression
		;

equality_expression : relation_expression 
		| equality_expression IS relation_expression
		| equality_expression ISNOT relation_expression
		;

relation_expression :  additive_expression
	        | relation_expression '<' additive_expression
       		| relation_expression '>' additive_expression
       		| relation_expression '<''=' additive_expression
        	| relation_expression '>''=' additive_expression
		;

additive_expression : multiplicative_expression
        	| additive_expression '+' multiplicative_expression
	        | additive_expression '-' multiplicative_expression
		;

multiplicative_expression : unary_expression
	        | multiplicative_expression '*' unary_expression
        	| multiplicative_expression '/' unary_expression
		;
	
unary_expression : postfix_expression 
		| unary_operator unary_expression
		;

unary_operator 	: '-' 
		| '#' 
		| NOT
		;

postfix_expression : primary_expression
	        | postfix_expression '(' ')'
       		| postfix_expression '(' argument_expression_list ')'
		;

argument_expression_list : assignment_expression 
		| argument_expression_list ',' assignment_expression
		;

primary_expression : type_name
		| INTEGER
		| PRICEXP
		| security
		| currency
		| position
		| TRUE_S
		| FALSE_S
		| '(' expression ')'
		;

type_name	: IDENTIFIER
	  	| type_name '.' IDENTIFIER
		| type_name '.' attribute
		;

position 	: POS '(' IDENTIFIER ')'
	  	;

security	: security_type '(' IDENTIFIER ')'
		;

currency	: currency_type '(' PRICEXP ')'
	 	;

attribute	: SEC
	  	| AMT
		| PRC
		| POS
		| AVAIL_CASH
		| NEXT
		;

%%

void yyerror(char * s)
{
   fprintf(stderr, "line %d: %s\n", yylineno, s);
}

void strat_error_msg(char *msg, int error_t, int lineno)
{
    if( error_t == 1 )
    {	
        fprintf(stderr, "ERROR: StratMaster: Duplicated variable name on line %d\n", lineno);
        exit(EXIT_FAILURE);
    }
}


int main(void)
{
   yyparse();
   return 0;
}



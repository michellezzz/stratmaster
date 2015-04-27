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
///ast_program * root;

%}

/* Data types for yylval in Lexer */
%union {
    char str[32];
    int  int_val;
    double fp_val;
    ast_security *security;
    ast_security_type *security_type;
	ast_order_item *order_item;
	ast_order_item *constraint;
	ast_order_item * constraint_list;
	ast_action_list *process_body;
	ast_action_list *action_list;
	ast_strategy *strategy;
	ast_strategy_list *strategy_list;
	ast_algorithm_list *algorithm_list;
	ast_program *program;
	ast_exp *exp;
	ast_process_statement * process_statement;
	ast_process_statement_list * process_statement_list;	
	ast_algorithm_header *algorithm_header;
	ast_algorithm *algorithm_function;
    	ast_statement_list * statement_list;
	ast_parameter_list *parameter_list;
ast_strategy_block *strategy_block;
ast_statement *statement;
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


%type <int_val> order_type;
%type <use_list> use_list;
%type <algorithm_list> algorithm_list;
%type <algorithm_header> algorithm_header;
%type <algorithm_function> algorithm_definition;
%type <int_val> type_specifier;

%type <statement_list> compound_statement;
%type <statement_list> statement_list;
%type <statement> statement;
%type <statement> expression_statement;
%type <statement> selection_statement;
%type <statement> set_statement;

%type <exp> argument_expression_list;
%type <exp> unary_expression;
%type <exp> postfix_expression;
%type <exp> primary_expression;
%type <exp> logical_OR_expression;
%type <exp> logical_AND_expression;
%type <exp> equality_expression;
%type <exp> relation_expression;
%type <exp> additive_expression;
%type <exp> multiplicative_expression;
%type <exp> expression;
%type <exp> assignment_expression;
%type <exp> type_name;

%type <int_val> security_type;
%type <strategy> strategy_definition
%type <strategy_list> strategy_list;
%type <strategy_block> strategy_body;
%type <strategy_block> strategy_block;
%type <action_list> process_body
%type <action_list> action_list;
%type <order_item> constraint_list;
%type <order_item> order_item;
%type <order_item> constraint;
%type <security> security;
%type <process_statement_list> process_statement_list; 
%type <process_statement> process_statement;
%type <program> process_list
%type <program> program
%type <int_val> unary_operator
%type <parameter_list> parameter_list


%%
program		: { fprintf(stdout, "STARTING PROGRAM\n"); parent = NULL; top = symbol_table_create(parent); } 
	 	  use_list process_list 
		{ $$=$3; print_ast($$);fprintf(stdout, "ENDING PROGRAM\n"); print_symtab(top); root = $$;}
	 	;

use_list	: USE  variable_declaration		{ }	
		| use_list USE variable_declaration 
		;

process_list	: strategy_list 			{$$ = create_program(NULL, NULL, $1, top);}
	     	| function_list strategy_list		{ }
		| algorithm_list strategy_list 		{$$ = create_program(NULL, $1, $2, top);}
		| function_list algorithm_list strategy_list	{ }
		;	     	

function_list	: function_definition			{ fprintf(stdout, "Function\n"); }
		| function_list function_definition	{ fprintf(stdout, "Function\n"); }
		;

algorithm_list 	: algorithm_definition			{ fprintf(stdout, "Algorithm\n"); 
							$$ = create_algorithm_list($1);}
		| algorithm_list algorithm_definition	{ fprintf(stdout, "Algorithm\n"); }
		;

strategy_list 	: strategy_definition				{ fprintf(stdout, "Strategy\n");
								$$ = create_strategy_list($1);}
		| strategy_list strategy_definition		{ fprintf(stdout, "Strategy\n"); }
		;

function_definition : function_header compound_statement
		;

function_header : FUNCTION IDENTIFIER '(' parameter_list ')' func_return	{ fprintf(stdout, "Function HDR\n"); }
		;

func_return	: RETURNS type_specifier
		;

algorithm_definition : algorithm_header 		{ parent = top;
							top = symbol_table_create(parent);     }
			compound_statement		{ $$ = create_algorithm_ast($1, $3, top);
							top = parent;
							symbol_table_put_value(top, ALGO_SYM, $$->name, $$);
							}
		;

algorithm_header: ALGORITHM IDENTIFIER '(' parameter_list ')'		{ fprintf(stdout, "Algo Hdr\n");
									$$ = create_algorithm_header($<str>2, $4); }
		;

parameter_list	: type_specifier IDENTIFIER				{ fprintf(stdout, "Param List\n"); 
									$$ = create_parameter_list($1,0,$<str>2);
									symbol_table_put_value(top, $1, $<str>2, 0);}
	       	| type_specifier '#' IDENTIFIER				{ fprintf(stdout, "Param List\n");
									$$ = create_parameter_list($1,1, $<str>3);
									symbol_table_put_value(top, $1, $<str>2, 0);} 
		| parameter_list ',' type_specifier '#' IDENTIFIER	{ $$ = add_parameter_list($1,$3,1, $<str>5);
									fprintf(stdout, "Param List\n"); }

		| /* empty */						{ }
		;

strategy_definition : STRATEGY IDENTIFIER '{' 	{ parent = top;
						top = symbol_table_create(parent); }
			strategy_body '}'	{$$ = create_strategy($<str>2, $5, top);
						top = parent;
						symbol_table_put_value(top, STRAT_SYM, $<str>2, $$);
						}
	  	;

strategy_body	: variable_declaration_list statement_list strategy_block	{ $$ = $3; }
	      	| variable_declaration_list strategy_block 	{ $$ = $2; }
		| strategy_block		{ $$ = $1; }
		| /* empty */			{ }
		;

strategy_block	:  action_list			{ $$ = create_strategy_block(0, $1, NULL); }
		|  process_statement_list	{ $$ = create_strategy_block(1, NULL, $1); }
		;

process_statement_list : process_statement   { $$ = create_process_statement_list($1);}
		| process_statement_list process_statement
		;

process_statement : WHEN '(' expression ')' '{' process_body '}' UNTIL '(' expression ')' { fprintf(stdout, "Process statement\n"); } 
		| WHEN '(' expression ')' '{' process_body '}'				{ $$ = create_process_statement($3,$6);
											fprintf(stdout, "Process statement\n");printf("in process_statement, num of orders: %d\n", $$->action_list->num_of_orders); }
		;

process_body	: action_list { $$ = $1; }
	     	| action_list statement_list
		;

action_list	: order_type '{' constraint_list '}'				{ fprintf(stdout, "Action List\n"); 
										 $$ = create_action_list($1,$3);}
		| action_list order_type '{' constraint_list '}'		{ fprintf(stdout, "Action List\n");
										 $$ = add_action_list($1,$2,$4);}
		;

constraint_list	: constraint							{ $$ = $1;}
		| constraint_list constraint
		;

constraint	: WHAT ':' order_item ';'					{ $$ = $3;}
	   	| WHERE ':' IDENTIFIER ';'		{ }
		;

order_item	: security '.' AMOUNT '(' INTEGER ')''.' PRICE '(' price_expr ')' 	{ fprintf(stdout, "Order Item\n"); 
											$$ = create_order_item($1, $<int_val>5, $<str>10);
											}
		;


price_expr	: PRICEXP
		| currency
		| IDENTIFIER
		;

variable_declaration_list : variable_declaration			{ }
		| variable_declaration_list variable_declaration	
		;

variable_declaration : type_specifier IDENTIFIER ';'	{ if( install_symbol($<int_val>1, $<str>2, top) != 0 )
		    						strat_error_msg("Duplicated Symbol", 1, yylineno); }
		;

type_specifier	: INT					{ $$ = INT_T; }
		| LONG					{ $$ = LONG_T; }
		| DOUBLE				{ $$ = DOUBLE_T; }
		| BOOLEAN				{ $$ = BOOLEAN_T; }
		| SECURITY				{ $$ = SECURITY_T; }
		| PRICE					{ $$ = PRICE_T; }
		| VOID					{ $$ = VOID_T; }
		| ACCOUNT				{ $$ = ACCOUNT_T; }
		| DATAFEED				{ $$ = DATAFEED_T; }
		| DATABASE				{ $$ = DATABASE_T; }
		| EXCHANGE				{ $$ = EXCHANGE_T; }
		;

security_type 	: EQTY					{$$ = EQTY_T;}
		;

currency_type	: USD
		| EUR
		| JPY
		;

order_type	: BUY					{ $$ = BUY_ORDER;}
		| SELL					{ $$ = SELL_ORDER;}
		;

statement	: expression_statement		{ $$ = $1;}
	  	| compound_statement		{ $$ = create_compound_statement($1); }
		| selection_statement		{ $$ = $1; }
		| iteration_statement		{ }
		| set_statement			{ $$ = $1; }
		;

expression_statement : expression ';'			{ $$ = create_expression_statement($1); }
		| ';'					{ }
		;

compound_statement : '{' variable_declaration_list statement_list '}'	{ $$ = $3; }
		| '{' statement_list '}'	{ $$ = $2; }
		| '{' '}'			{ }
		;

statement_list	: statement			{ $$ = create_statement_list($1); }
		| statement_list statement	{ $$ = add_statement_list($1, $2);}
		;

selection_statement : IF '(' expression ')' statement   { $$ = create_selection_statement($3, $5); }
		;

iteration_statement : WHILE '(' expression ')' statement
		;

set_statement 	: SET '{' argument_expression_list '}' IF ':' '{' expression '}'	{ $$ = create_set_statement(0,$3,$8); }
		;

expression	: assignment_expression				{ $$ = $1; }
            	| expression ',' assignment_expression
		;

assignment_expression : logical_OR_expression 			{ $$ = $1; }
            	| unary_expression '=' logical_OR_expression	{ $$ = create_opr('=', 2, $1, $3); }
		;

logical_OR_expression :  logical_AND_expression 		{ $$ = $1; }
            	| logical_OR_expression OR logical_AND_expression
		;

logical_AND_expression : equality_expression 				{ $$ = $1;}
           	| logical_AND_expression AND equality_expression
		;

equality_expression : relation_expression 				{ $$ = $1;}
		| equality_expression IS relation_expression		{ $$ = create_opr(OP_IS, 2, $1, $3);}
		| equality_expression ISNOT relation_expression
		;

relation_expression :  additive_expression 				{ $$ = $1;}
	        | relation_expression '<' additive_expression
       		| relation_expression '>' additive_expression
       		| relation_expression '<''=' additive_expression
        	| relation_expression '>''=' additive_expression
		;

additive_expression : multiplicative_expression				{ $$ = $1; }
        	| additive_expression '+' multiplicative_expression { $$= create_opr('+', 2, $1, $3);}
	        | additive_expression '-' multiplicative_expression
		;

multiplicative_expression : unary_expression { $$ = $1; }
	        | multiplicative_expression '*' unary_expression
        	| multiplicative_expression '/' unary_expression
		;
	
unary_expression : postfix_expression { $$ = $1;}
		| unary_operator unary_expression { $$ = create_opr($1,1,$2,NULL);}
		;

unary_operator 	: '-'  { $$ = OP_UNARY_MINUS; }
		| '#'  { $$ = OP_UNARY_SHARP; }
		| NOT  { $$ = OP_UNARY_NOT; }
		;

postfix_expression : primary_expression 			{ $$ = $1; }
	        | postfix_expression '(' ')'			{ $$ = create_opr(OP_FUNC, 1, $1, NULL);}
       		| postfix_expression '(' argument_expression_list ')'  { $$ = create_opr(OP_FUNC, 2, $1, $3);}
		;

argument_expression_list : assignment_expression   { $$ = create_argument_expression_list($1);}
		| argument_expression_list ',' assignment_expression  { $$ = add_argument_expression_list($1, $3);}
		;

primary_expression : type_name		{ $$ = $1;}
		| INTEGER		{ $$ = create_const($1);}
		| PRICEXP		{ 	}
		| security		{ }
		| currency		{ }
		| position		{ }
		| TRUE_S		{ $$ = create_keyword("TRUE");}
		| FALSE_S		{ }
		| '(' expression ')'	{ }
		;

type_name	: IDENTIFIER		{ $$ = create_id($1, top);}
	  	| type_name '.' IDENTIFIER
		| type_name '.' attribute
		;

position 	: POS '(' IDENTIFIER ')'
	  	;

security	: security_type '(' IDENTIFIER ')' {$$ = create_security($1, $<str>3);}
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
   run_interp(root);
   return 0;
}




#ifndef _AST_H
#define _AST_H
#include <stdarg.h>
#include "symtab.h"
#define NAMEBUF    32      /* Max size of an identifier or name */
/*typedef enum {BUY_ORDER, SELL_ORDER} basic_type;*/

typedef enum {typeConst, typeOper, typeID, typeKeyword, typeArgulist} nodeType;
typedef enum {expression_ST, compound_ST, selection_ST, iteration_ST, set_ST} stmtType;

typedef struct{
    int type;  /*1ACCOUNT, 2DATAFEED, 3DATABASE, 4EXCHANGE*/
    char * name;
}use_define;

typedef struct{
   int type_specifier;
   int has_sharp;
   char name[NAMEBUF];
}parameter;

/********************AST NODES***********************/

struct ast_exp;
typedef struct {
	int value;
} ast_const;

typedef struct {
	char value[NAMEBUF];
	struct symbol_table* sym;
} ast_str;

typedef struct {
	int oper;
	int nops;
	struct ast_exp *op1;
	struct ast_exp *op2;
} ast_oper;

typedef struct {
    int num_of_argument_expression_list;
    struct ast_exp ** exp;
}ast_argument_expression_list;

typedef struct {
    int num_of_para;
    parameter ** para_list;
}ast_parameter_list;

typedef struct ast_exp{
	nodeType type;
	union {
		ast_const con;
		ast_oper oper;
		ast_str key;
		ast_str id;
		ast_argument_expression_list argu_list;
	};
} ast_exp;

typedef struct {
    char * name;
}ast_primary_expression;

typedef struct {
    ast_primary_expression *primary_expression;
}ast_postfix_expression;

typedef struct {
    ast_postfix_expression *postfix_expression;
}ast_unary_expression;

typedef struct {
    ast_unary_expression *unary_expression;
}ast_multiplicative_expression;

typedef struct {
    ast_multiplicative_expression *multiplicative_expression;
}ast_additive_expression;

typedef struct {
    ast_additive_expression *additive_expression;
}ast_relation_expression;

typedef struct {
    ast_relation_expression *relation_expression;
}ast_equality_expression;

typedef struct {
    ast_equality_expression *equality_expression;
}ast_logical_AND_expression;

typedef struct {
    ast_logical_AND_expression *logical_AND_expression;
}ast_logical_OR_expression;

typedef struct {
    int this_type;
    ast_unary_expression * unary_expression;
    ast_logical_OR_expression * logical_OR_expression;
}ast_assignment_expression;

typedef struct {
    int num_of_assignment_expressions;
    ast_assignment_expression ** assignment_expression;
}ast_expression;


/***********************statement member******************************/
typedef struct ast_statement ast_statement;

typedef struct ast_selection_statement{
	ast_exp *exp;
	ast_statement *statement;
}ast_selection_statement;  /*if exp stmt*/

typedef struct {
    int num_of_statement;
    ast_statement ** statement;
}ast_statement_list;

typedef struct {
    int this_type;
    ast_exp *argu_list;
    ast_exp *exp;
}ast_set_statement;

typedef struct ast_statement{
    int type;
    union {
		ast_exp *expression_statement;
		ast_selection_statement selection_statement;
		ast_statement_list statement_list;   /*compound_statement*/
		ast_set_statement set_statement;
	}; 
}ast_statement;

/*****************************************************/
typedef struct {
    int type;
}ast_arithmetic_type;

typedef struct {
    ast_arithmetic_type * arithmetic_type;
}ast_type_specifier;

typedef struct{
    ast_type_specifier *type_specifier;
    char * name;
}type_spec;

typedef struct {
    ast_type_specifier * type_specifier;
    char *name;
}ast_variable_declaration;

typedef struct {
    int num_of_variable_declaration;
    ast_variable_declaration ** variable_declaration;
}ast_variable_declaration_list;

typedef struct {
    ast_variable_declaration_list * variable_declaration_list;
    ast_statement_list * statement_list;
}ast_compound_statement;

typedef struct {
    int num_of_type_specs;
    type_spec ** typespec;
}ast_target_list;

typedef struct {
    char * name;
    ast_target_list * target_list;
}ast_algorithm_parameter_list;

typedef struct {
    char name[NAMEBUF];
    int num_of_para;
    parameter ** para_list;
}ast_algorithm_header;

typedef struct {
    char name[NAMEBUF];
    int num_of_para;
    parameter ** para_list;
    int num_of_statement;
    ast_statement ** statement;
    struct symbol_table * sym;
}ast_algorithm;

typedef struct {
    int num_of_algos;
    ast_algorithm ** algo_list;
}ast_algorithm_list;

typedef struct {
    ast_algorithm_list * algorithm_list;
}ast_decision_list;

typedef struct {
    int num_of_use_defines;
    use_define ** usedefine;
}ast_use_others;

typedef struct{
    char * first_acc_name;
    ast_use_others * use_others;
}ast_use_list;


/*******strategy*******/

typedef struct {
    int type;
}ast_security_type;

typedef struct {
    int type;
    char  name[NAMEBUF];
}ast_security;

typedef struct {
    int security_type;
    char security_name[NAMEBUF];
    int number;
    char price[NAMEBUF];
    int type; /*BUY SELL*/
}ast_order_item;

typedef struct {
    ast_order_item * order_item;
}ast_constraint;

typedef struct {
    int num_of_constraints;
    ast_constraint ** constraint;
}ast_constraint_list;

typedef struct {
    int type;
}ast_order_type;

typedef struct {
    ast_order_type *order_type;
    ast_constraint_list *constraint_list;
}ast_order;

typedef struct {
    int num_of_orders;
    ast_order_item ** order;
}ast_action_list;

typedef struct {
   /* int type;*/
    ast_exp *expression;
    ast_action_list *action_list;
   /* ast_expression *expression2; */
}ast_process_statement;

typedef struct {
    int num_of_process_statement;
    ast_process_statement **process_statement;
}ast_process_statement_list;

typedef struct {
    int type;
    int num_of_orders;
    ast_order_item ** order_list;
    int num_of_process_statement;
    ast_process_statement **process_statement;
}ast_strategy_block;

typedef struct {
    char name[NAMEBUF];
    int num_of_orders;
    ast_order_item ** order_list;
    int num_of_process_statement;
    ast_process_statement **process_statement;
    struct symbol_table *sym;
}ast_strategy;

typedef struct {
    int num_of_strategies;
    ast_strategy ** strategy;
}ast_strategy_list;


/*****************************************/

typedef struct {
    int num_of_algos;
    ast_algorithm ** algo_list;
    int num_of_strategies;
    ast_strategy ** strategy_list;
    struct symbol_table *sym;
}ast_program;

ast_exp *
create_id(char* value, struct symbol_table *top);

ast_exp *
create_keyword(char* value);

ast_exp *
create_opr(int oper, int nops, ast_exp* op1, ast_exp* op2);

ast_exp *
create_const(int value);

ast_statement*
create_selection_statement(ast_exp *exp, ast_statement *statement);

ast_statement*
create_expression_statement(ast_exp *exp);

ast_statement *
create_set_statement(int this_type, ast_exp *argu_list, ast_exp *exp);

ast_statement *
create_compound_statement(ast_statement_list * statement_list);

ast_program *
create_program(ast_use_list * use_list, ast_algorithm_list * algorithm_list,ast_strategy_list* strategy_list, struct symbol_table* sym);

ast_parameter_list *
create_parameter_list(int type_specifier, int has_sharp, char * name);

ast_parameter_list *
add_parameter_list(ast_parameter_list * list, int type_specifier, int has_sharp, char * name);

ast_use_list *
create_use_list(char* first_acc_name, ast_use_others * use_others);

ast_use_others *
create_use_others();

ast_use_others *
add_use_others(ast_use_others *list, int type, char * name);

ast_decision_list *
create_decision_list(ast_algorithm_list * algorithm_list);

ast_algorithm_list *
create_algorithm_list();

ast_algorithm_list *
add_algorithm_list(ast_algorithm_list *list, ast_algorithm * algorithm_function);

ast_algorithm *
create_algorithm_ast(ast_algorithm_header * algorithm_header,ast_statement_list * statement_list, struct symbol_table* sym);

ast_algorithm_header *
create_algorithm_header(char * name, ast_parameter_list * parameter_list);

ast_algorithm_parameter_list *
create_algorithm_parameter_list(char* name, ast_target_list * target_list);

ast_target_list *
create_target_list();

ast_target_list *
add_target_list(ast_target_list * list, ast_type_specifier *type_specifier, char * name);


ast_variable_declaration_list *
create_variable_declaration_list();

ast_variable_declaration_list *
add_variable_declaration_list(ast_variable_declaration_list * list, ast_variable_declaration * variable_declaration);


ast_variable_declaration *
create_variable_declaration(ast_type_specifier * type_specifier, char *name);

ast_type_specifier *
create_type_specifier(ast_arithmetic_type * arithmetic_type);

ast_arithmetic_type *
create_arithmetic_type(int type);

ast_statement_list *
create_statement_list(ast_statement *statement);

ast_statement_list *
add_statement_list(ast_statement_list *list, ast_statement *statement);

ast_exp *
create_argument_expression_list(ast_exp * exp);

ast_exp *
add_argument_expression_list(ast_exp * p, ast_exp * exp);

ast_unary_expression *
create_unary_expression(ast_postfix_expression *postfix_expression);

ast_postfix_expression *
create_postfix_expression(ast_primary_expression *primary_expression);

ast_primary_expression *
create_primary_expression(char * name);

ast_logical_OR_expression *
create_logical_OR_expression(ast_logical_AND_expression *logical_AND_expression);

ast_logical_AND_expression *
create_logical_AND_expression(ast_equality_expression *equality_expression);

ast_equality_expression *
create_equality_expression(ast_relation_expression *relation_expression);

ast_relation_expression *
create_relation_expression(ast_additive_expression *additive_expression);

ast_additive_expression *
create_additive_expression(ast_multiplicative_expression *multiplicative_expression);

ast_multiplicative_expression *
create_multiplicative_expression(ast_unary_expression *unary_expression);

ast_assignment_expression *
create_assignment_expression(int this_type, ast_unary_expression * unary_expression, ast_logical_OR_expression * logical_OR_expression);

ast_expression *
create_expression(ast_assignment_expression * assignment_expression);

ast_expression *
add_expression(ast_expression * list, ast_assignment_expression * assignment_expression);

ast_strategy_list *
create_strategy_list(ast_strategy * strategy);

ast_strategy_list *
add_strategy_list(ast_strategy_list * list, ast_strategy * strategy);

ast_strategy*
create_strategy( char * name, ast_strategy_block *strategy_body, struct symbol_table * sym);

/*
ast_strategy_body*
create_strategy_body( ast_variable_declaration_list *variable_declaration_list, ast_strategy_block *strategy_block);
*/

ast_strategy_block*
create_strategy_block( int type, ast_action_list * action_list, ast_process_statement_list * process_statement_list);

ast_action_list *
create_action_list(int type, ast_order_item * order);

ast_action_list *
add_action_list(ast_action_list* list, int type, ast_order_item * order);
/*
ast_order*
create_order( ast_order_type *order_type, ast_constraint_list *constraint_list);
*/
ast_order_type*
create_order_type( int type);

ast_constraint_list *
create_constraint_list(ast_constraint * constraint);

ast_constraint_list *
add_constraint_list(ast_constraint_list * list, ast_constraint * constraint);

ast_constraint *
create_constraint(ast_order_item * order_item);

ast_order_item *
create_order_item(ast_security *security, int number, char * price_name);
ast_security *
create_security(int security_type, char * name);
ast_security_type *
create_security_type(int type);

ast_process_statement_list *
create_process_statement_list(ast_process_statement * process_statement);

ast_process_statement_list *
add_process_statement_list(ast_process_statement_list * list, ast_process_statement * process_statement);


/*ast_process_statement *
create_process_statement(int type, ast_expression *expression, ast_action_list *action_list, ast_expression *expression2);*/

ast_process_statement *
create_process_statement(ast_exp *expression, ast_action_list *action_list);

void print_ast(ast_program *program);
void print_strategy(ast_strategy * strategy);
void print_order(ast_order_item * order_item);
void print_process_statement(ast_process_statement * process_statement);
void print_exp(ast_exp *exp);
void print_algorithm(ast_algorithm * algorithm);
void print_statement(ast_statement *statement);

int install_symbol(int id_type, const char *id, struct symbol_table *symtab);

/////////root node for the program
ast_program * root;

void run_interp(ast_program * program);
void ex_strategy(ast_strategy * strategy);
void *strategy_handler(void *arg);
void ex_order_item(ast_order_item * order_item);
void *order_handler(void *arg);
void ex_process_statement(ast_process_statement * process_statement);
void *algorithm_handler(void *arg);
void ex_action_list(ast_action_list * action_list);

#define DEBUG 1

#ifdef DEBUG
#define PRINT(x)  do { if (DEBUG) dbg_printf x; } while (0)
#else
#define PRINT(x) do {} while(0)
#endif

void dbg_printf(const char *fmt, ...);
#endif





#ifndef _AST_H
#define _AST_H
#include <stdarg.h>
typedef enum {ast_program_type ,ast_uselist_type ,ast_stratlist_type \
		,ast_strat_type ,ast_actionlist_type ,ast_order_type \
		,ast_order_item_type} nodeEnum;

typedef struct {
    char * account;
}ast_uselist;

typedef struct {
    char equity_identifier[16];
    int amount;
    int order_type;
    char price[16];
}ast_order_item;

typedef struct {
    int order_type;
    ast_order_item * order_item;
}ast_order;

typedef struct {
    ast_order ** order;
    int num_of_orders;
}ast_actionlist;

typedef struct {
    char * strategy_name;
    ast_actionlist * actionlist;
}ast_strat;

typedef struct {
    ast_strat * strat;
}ast_stratlist;

typedef struct {
    ast_uselist * uselist;
    ast_stratlist * stratlist;
}ast_program;

typedef struct nodeTypeTag {
    nodeEnum type;
    
    union {
        ast_program program;
        ast_uselist uselist;
        ast_stratlist stratlist;
        ast_strat strat;
        ast_actionlist actionlist;
        ast_order order;
        ast_order_item order_item;
    };
} nodeType;

ast_program *
create_node_program(ast_uselist * uselist, ast_stratlist * stratlist);

ast_uselist *
create_node_uselist(char * name);

ast_stratlist *
create_node_stratlist(ast_strat * strat);

ast_strat *
create_node_strat(char * name, ast_actionlist * actionlist);

ast_actionlist *
create_node_actionlist(ast_order * order);

ast_actionlist *
add_order(ast_actionlist* list, ast_order * order);

ast_order *
create_node_order(int order_type, ast_order_item * order_item);

ast_order_item *
create_node_order_item(char * equity_identifier, int amount, char* price);  // should be one more para(identifier)

void
print_ast(ast_program* prog);


//#define DEBUG 1

#ifdef DEBUG
#define PRINT(x)  do { if (DEBUG) dbg_printf x; } while (0)
#else
#define PRINT(x) do {} while(0)
#endif

void dbg_printf(const char *fmt, ...);
#endif





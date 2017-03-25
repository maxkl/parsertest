
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "../mem.h"
#include "runtime.h"

enum runtime_value_type {
	RT_TYPE_VOID = 0,
	RT_TYPE_BOOL,
	RT_TYPE_CHAR,
	RT_TYPE_INT,
	RT_TYPE_FLOAT,
	RT_TYPE_STRING
};
typedef enum runtime_value_type runtime_value_type_t;

static const runtime_value_type_t runtime_ast_type_map[] = {
	RT_TYPE_VOID,
	RT_TYPE_INT,
	RT_TYPE_FLOAT,
	RT_TYPE_BOOL,
	RT_TYPE_CHAR,
	RT_TYPE_STRING
};

struct runtime_string {
	size_t length;
	char *chars;
};
typedef struct runtime_string runtime_string_t;

struct runtime_value {
	runtime_value_type_t type;
	union {
		bool bool_value;
		char char_value;
		int int_value;
		float float_value;
		runtime_string_t *string_value;
	};
};
typedef struct runtime_value runtime_value_t;

struct runtime_var {
	char *name;
	runtime_value_type_t type;
	runtime_value_t value;
};
typedef struct runtime_var runtime_var_t;

struct stack_frame {
	size_t size;
	runtime_var_t *vars;
};
typedef struct stack_frame stack_frame_t;

void copy_value(runtime_value_t *target, runtime_value_t *source) {
	target->type = source->type;
	switch(source->type) {
		case RT_TYPE_VOID:
			break;
		case RT_TYPE_BOOL:
			target->bool_value = source->bool_value;
			break;
		case RT_TYPE_CHAR:
			target->char_value = source->char_value;
			break;
		case RT_TYPE_INT:
			target->int_value = source->int_value;
			break;
		case RT_TYPE_FLOAT:
			target->float_value = source->float_value;
			break;
		case RT_TYPE_STRING:
			assert(0 && "Strings not implemented");
			// target->_value = source->_value;
			break;
		default:
			fprintf(stderr, "Type: %i\n", source->type);
			assert(0);
	}
}

int run_function(ast_node_t root, ast_node_t fn, runtime_value_t *return_value);

ast_node_t find_function(char *name, ast_node_t root) {
	for(size_t i = 0; i < root->child_count; i++) {
		if(strcmp(root->children[i]->function.name, name) == 0) {
			return root->children[i];
		}
	}
	return NULL;
}

int cast_value(runtime_value_t *value, runtime_value_type_t type) {
	printf("Cast from %i to %i\n", value->type, type);
	if(value->type == RT_TYPE_VOID) {
		fprintf(stderr, "Invalid cast from `void`\n");
		return 1;
	}
	if(type == RT_TYPE_VOID) {
		fprintf(stderr, "Invalid cast to `void`\n");
		return 1;
	}
	if(value->type == type) {
		return 0;
	}
	switch(type) {
		case RT_TYPE_BOOL:
			switch(value->type) {
				case RT_TYPE_CHAR:
					value->bool_value = (bool) value->char_value;
					break;
				case RT_TYPE_INT:
					value->bool_value = (bool) value->int_value;
					break;
				case RT_TYPE_FLOAT:
					value->bool_value = (bool) value->float_value;
					break;
				case RT_TYPE_STRING:
					assert(0 && "Strings not implemented");
					break;
				default:
					assert(0);
					break;
			}
			return 0;
		case RT_TYPE_CHAR:
			assert(0);
			return 0;
		case RT_TYPE_INT:
			assert(0);
			return 0;
		case RT_TYPE_FLOAT:
			assert(0);
			return 0;
		case RT_TYPE_STRING:
			assert(0);
			return 0;
		default:
			assert(0);
	}
	value->type = type;
	return 0;
}

runtime_var_t *declare_var(stack_frame_t *frame, runtime_value_type_t type, char *name) {
	for(size_t i = 0; i < frame->size; i++) {
		if(strcmp(frame->vars[i].name, name) == 0) {
			fprintf(stderr, "Variable already declared: %s\n", name);
			return NULL;
		}
	}
	frame->size++;
	frame->vars = xrealloc(frame->vars, sizeof(*frame->vars) * frame->size);
	runtime_var_t *var = &frame->vars[frame->size - 1];
	var->type = type;
	var->name = name;
	return var;
}

runtime_var_t *get_var(stack_frame_t *frame, char *name) {
	for(size_t i = 0; i < frame->size; i++) {
		runtime_var_t *var = &frame->vars[i];
		if(strcmp(var->name, name) == 0) {
			return var;
		}
	}
	return NULL;
}

int stack_frame_cleanup(stack_frame_t *frame) {
	// TODO
	return 0;
}

// runtime_stack_t create_stack(size_t size) {
// 	runtime_stack_t stack = xmalloc(sizeof(*stack));
// 	stack->size = size;
// 	stack->next_index = 0;
// 	stack->frames = xmalloc(sizeof(*stack->frames) * size);
// 	stack->top = &stack->frames[stack->next_index];
// 	return stack;
// }
//
// int push_stack(runtime_stack_t stack) {
// 	if(stack->next_index >= stack->size) {
// 		return 1;
// 	}
// 	stack->top = &stack->frames[stack->next_index];
// 	stack->next_index++;
// 	return 0;
// }
//
// int pop_stack(runtime_stack_t stack) {
// 	if(stack->next_index == 0) {
// 		return 1;
// 	}
// 	stack->next_index--;
// 	if(stackframe_cleanup(&stack->frames[stack->next_index])) {
// 		return 1;
// 	}
// 	return 0;
// }
//
// void free_stack(runtime_stack_t stack) {
// 	while(stack->next_index > 0) {
// 		pop_stack(stack);
// 	}
// 	free(stack->frames);
// 	free(stack);
// }

int declare_variables(ast_node_t root, ast_node_t declaration, stack_frame_t *frame) {
	runtime_value_type_t type = runtime_ast_type_map[declaration->declaration.type];
	for(size_t i = 0; i < declaration->child_count; i++) {
		ast_node_t declarator = declaration->children[i];
		runtime_var_t *var = declare_var(frame, type, declarator->declarator.name);
		if(var == NULL) {
			return 1;
		}
		if(declarator->child_count > 0) {
			assert(declarator->child_count == 1);
			if(eval_expression(root, declarator->children[0], frame, &var->value)) {
				return 1;
			}
			if(var->value.type != type) {
				cast_value(&var->value, type);
			}
		}
	}
	return 0;
}

int eval_unary_expr(ast_node_t root, ast_node_t expr, stack_frame_t *frame, runtime_value_t *result) {
	assert(expr->child_count == 1);
	if(eval_expression(root, expr->children[0], frame, result)) {
		return 1;
	}
	switch(expr->unop.op) {
		case AST_UNOP_MINUS:
			switch(result->type) {
				case RT_TYPE_CHAR:
					result->char_value = -result->char_value;
					break;
				case RT_TYPE_INT:
					result->int_value = -result->int_value;
					break;
				case RT_TYPE_FLOAT:
					result->float_value = -result->float_value;
					break;
				default:
					fprintf(stderr, "Invalid operand for operator `-`\n");
					return 1;
			}
			return 0;
		case AST_UNOP_PLUS:
			switch(result->type) {
				case RT_TYPE_CHAR:
				case RT_TYPE_INT:
				case RT_TYPE_FLOAT:
					// No-op
					break;
				default:
					fprintf(stderr, "Invalid operand for operator `+`\n");
					return 1;
			}
			return 0;
		case AST_UNOP_NOT:
			switch(result->type) {
				case RT_TYPE_CHAR:
					result->type = RT_TYPE_BOOL;
					result->bool_value = result->char_value == '\0';
					break;
				case RT_TYPE_INT:
					result->type = RT_TYPE_BOOL;
					result->bool_value = result->int_value == 0;
					break;
				case RT_TYPE_FLOAT:
					result->type = RT_TYPE_BOOL;
					result->bool_value = result->float_value == 0.0f;
					break;
				default:
					fprintf(stderr, "Invalid operand for operator `+`\n");
					return 1;
			}
			return 0;
		default:
			assert(0);
	}
	return 0;
}

int eval_binary_expr(ast_node_t root, ast_node_t expr, stack_frame_t *frame, runtime_value_t *result) {
	int ret = 0;
	assert(expr->child_count == 2);
	runtime_value_t *value1 = xmalloc(sizeof(*value1));
	runtime_value_t *value2 = xmalloc(sizeof(*value2));
	if(eval_expression(root, expr->children[0], frame, value1)) {
		ret = 1;
		goto out;
	}
	if(eval_expression(root, expr->children[1], frame, value2)) {
		ret = 1;
		goto out;
	}
	runtime_value_type_t type = value1->type;
	if(type == RT_TYPE_VOID) {
		fprintf(stderr, "Bad operation type `void`\n");
		ret = 1;
		goto out;
	}
	if(value2->type != type) {
		cast_value(value2, value1->type);
	}
	if(result) {
		result->type = type;
		switch(expr->binop.op) {
			case AST_BINOP_ADD:
				switch(type) {
					case RT_TYPE_BOOL:
						assert(0);
						break;
					case RT_TYPE_CHAR:
						result->char_value = value1->char_value + value2->char_value;
						break;
					case RT_TYPE_INT:
						result->int_value = value1->int_value + value2->int_value;
						break;
					case RT_TYPE_FLOAT:
						assert(0);
						break;
					case RT_TYPE_STRING:
						assert(0);
						break;
					default:
						assert(0);
				}
				break;
			case AST_BINOP_SUBTRACT:
				assert(0);
				break;
			case AST_BINOP_MULTIPLY:
				assert(0);
				break;
			case AST_BINOP_DIVIDE:
				assert(0);
				break;
			case AST_BINOP_MODULO:
				assert(0);
				break;
			case AST_BINOP_SHIFT_LEFT:
				assert(0);
				break;
			case AST_BINOP_SHIFT_RIGHT:
				assert(0);
				break;
			case AST_BINOP_BIT_AND:
				assert(0);
				break;
			case AST_BINOP_BIT_OR:
				assert(0);
				break;
			case AST_BINOP_BIT_XOR:
				assert(0);
				return 0;
			case AST_BINOP_AND:
				assert(0);
				break;
			case AST_BINOP_OR:
				assert(0);
				break;
			default:
				assert(0);
		}
	}
out:
	free(value1);
	free(value2);
	return ret;
}

int eval_comparison_expr(ast_node_t root, ast_node_t expr, stack_frame_t *frame, runtime_value_t *result) {
	switch(expr->comp.op) {
		case AST_COMP_LESS:
			assert(0);
			return 0;
		case AST_COMP_GREATER:
			assert(0);
			return 0;
		case AST_COMP_LESS_EQUAL:
			assert(0);
			return 0;
		case AST_COMP_GREATER_EQUAL:
			assert(0);
			return 0;
		case AST_COMP_EQUAL:
			assert(0);
			return 0;
		case AST_COMP_NOT_EQUAL:
			assert(0);
			return 0;
		default:
			assert(0);
	}
	return 0;
}

int eval_expression(ast_node_t root, ast_node_t expr, stack_frame_t *frame, runtime_value_t *result) {
	switch (expr->type) {
		case AST_STRING_LITERAL:
			assert(0 && "String literals not implemented");
			return 0;
		case AST_INT_LITERAL:
			if(result) {
				result->type = RT_TYPE_INT;
				result->int_value = expr->int_literal.value;
			}
			return 0;
		case AST_CHAR_LITERAL:
			if(result) {
				result->type = RT_TYPE_CHAR;
				result->char_value = expr->char_literal.value;
			}
			return 0;
		case AST_IDENTIFIER:
			if(result) {
				runtime_var_t *ident_var = get_var(frame, expr->identifier.name);
				if(ident_var == NULL) {
					fprintf(stderr, "Variable not defined: %s\n", expr->identifier.name);
					return 1;
				}
				copy_value(result, &ident_var->value);
			}
			return 0;
		case AST_FUNCTION_CALL: ;
			// TODO: arguments
			ast_node_t function = find_function(expr->function_call.name, root);
			if(!function) {
				fprintf(stderr, "Function %s is not defined\n", expr->function_call.name);
				return 1;
			}
			if(run_function(root, function, result)) {
				return 1;
			}
			return 0;
		case AST_UNOP_EXPR:
			return eval_unary_expr(root, expr, frame, result);
		case AST_BINOP_EXPR:
			return eval_binary_expr(root, expr, frame, result);
		case AST_COMP_EXPR:
			return eval_comparison_expr(root, expr, frame, result);
		case AST_ASSIGN_EXPR:
			assert(expr->child_count == 2);
			ast_node_t lhs = expr->children[0];
			ast_node_t rhs = expr->children[1];
			if(lhs->type != AST_IDENTIFIER) {
				fprintf(stderr, "Invalid left-hand-side\n");
				return 1;
			}
			runtime_var_t *var = get_var(frame, lhs->identifier.name);
			if(var == NULL) {
				fprintf(stderr, "Variable not defined: %s\n", lhs->identifier.name);
				return 1;
			}
			if(eval_expression(root, rhs, frame, &var->value)) {
				return 1;
			}
			if(var->value.type != var->type) {
				cast_value(&var->value, var->type);
			}
			if(result) {
				copy_value(result, &var->value);
			}
			return 0;
		default:
			printf("Expr: %s\n", ast_node_type_names[expr->type]);
			assert(0);
	}
}

int exec_return_statement(ast_node_t root, ast_node_t stmt, stack_frame_t *frame, runtime_value_t *return_value) {
	assert(stmt->type == AST_RETURN);
	if(stmt->child_count == 0) {
		return_value->type = RT_TYPE_VOID;
		return 0;
	} else {
		assert(stmt->child_count == 1);
		return eval_expression(root, stmt->children[0], frame, return_value);
	}
}

int exec_statement(ast_node_t root, ast_node_t stmt, stack_frame_t *frame) {
	switch(stmt->type) {
		case AST_DECLARATION:
			return declare_variables(root, stmt, frame);
		case AST_STRING_LITERAL:
		case AST_INT_LITERAL:
		case AST_CHAR_LITERAL:
		case AST_IDENTIFIER:
		case AST_FUNCTION_CALL:
		case AST_UNOP_EXPR:
		case AST_BINOP_EXPR:
		case AST_COMP_EXPR:
		case AST_ASSIGN_EXPR:
			return eval_expression(root, stmt, frame, NULL);
		case AST_RETURN:
			// we have `exec_return_statement` for that
			assert(0);
		default:
			printf("Statement: %s\n", ast_node_type_names[stmt->type]);
			assert(0);
	}
	return 0;
}

int run_function(ast_node_t root, ast_node_t fn, runtime_value_t *return_value) {
	int ret = 0;

	stack_frame_t *frame = xmalloc(sizeof(*frame));
	frame->size = 0;
	frame->vars = NULL;

	if(return_value) {
		return_value->type = RT_TYPE_VOID;
	}

	for(size_t i = 0; i < fn->child_count; i++) {
		ast_node_t stmt = fn->children[i];
		if(stmt->type == AST_RETURN) {
			if(exec_return_statement(root, stmt, frame, return_value)) {
				ret = 1;
				goto out;
			}
		} else {
			if(exec_statement(root, stmt, frame)) {
				ret = 1;
				goto out;
			}
		}
	}

	if(return_value) {
		enum runtime_value_type expected_type = runtime_ast_type_map[fn->function.type];
		// TODO: implement (implicit) type casting
		assert(return_value->type == expected_type);
	}

out:
	stack_frame_cleanup(frame);
	if(frame->vars != NULL) {
		free(frame->vars);
	}
	free(frame);

	return ret;
}

int runtime_run_ast(ast_node_t root, int *exit_code) {
	int ret = 0;

	ast_node_t main_function = find_function("main", root);
	if(!main_function) {
		fprintf(stderr, "No `main` function\n");
		ret = 1;
		goto out;
	}
	if(main_function->function.type != AST_TYPE_INT) {
		fprintf(stderr, "Return type of `main` is not `int`\n");
		ret = 1;
		goto out;
	}

	runtime_value_t *main_ret = xmalloc(sizeof(*main_ret));
	if(run_function(root, main_function, main_ret)) {
		ret = 1;
		goto free_main_ret;
	}
	*exit_code = main_ret->int_value;

free_main_ret:
	free(main_ret);
out:
	return ret;
}

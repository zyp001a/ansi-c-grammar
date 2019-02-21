%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>		
#include "ast.h"		

extern char yytext[];
extern int row;
extern int funcrow;
extern int column;
int yylex (void);	

void yyerror(YYSTYPE* ret, const char *s)
{
	fflush(stdout);
	printf("\n%*s\n%*s\n", column, "^", column, s);
	print(*ret);
  printf("\n");
}
 
%}

%parse-param {YYSTYPE* ret}

%token IDENTIFIER CONSTANT STRING_LITERAL SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%start start_unit
%%

primary_expression
	: IDENTIFIER
	{
		$$ = initnode("id");
		addnode($$, $1);
	}
	| CONSTANT
	| STRING_LITERAL
	| '(' expression ')'
	;

postfix_expression
	: primary_expression
	| postfix_expression '[' expression ']'
	| postfix_expression '(' ')'
	| postfix_expression '(' argument_expression_list ')'
	| postfix_expression '.' IDENTIFIER
	| postfix_expression PTR_OP IDENTIFIER
	| postfix_expression INC_OP
	| postfix_expression DEC_OP
	;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' assignment_expression
	;

unary_expression
	: postfix_expression
	| INC_OP unary_expression
	| DEC_OP unary_expression
	| unary_operator cast_expression
	| SIZEOF unary_expression
	| SIZEOF '(' type_name ')'
	;

unary_operator
	: '&'
	| '*'
	| '+'
	| '-'
	| '~'
	| '!'
	;

cast_expression
	: unary_expression
	| '(' type_name ')' cast_expression
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' cast_expression
	| multiplicative_expression '/' cast_expression
	| multiplicative_expression '%' cast_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression
	| additive_expression '-' multiplicative_expression
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_OP additive_expression
	| shift_expression RIGHT_OP additive_expression
	;

relational_expression
	: shift_expression
	| relational_expression '<' shift_expression
	| relational_expression '>' shift_expression
	| relational_expression LE_OP shift_expression
	| relational_expression GE_OP shift_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
	;

assignment_operator
	: '='
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	| SUB_ASSIGN
	| LEFT_ASSIGN
	| RIGHT_ASSIGN
	| AND_ASSIGN
	| XOR_ASSIGN
	| OR_ASSIGN
	;

expression
	: assignment_expression
 	| expression ',' assignment_expression
	;

constant_expression
	: conditional_expression
	;

declaration
	: declaration_specifiers ';'
	{
		$$ = initnode("decln");
		addnode($$, $1);
	}
	| declaration_specifiers init_declarator_list ';'
	{
		$$ = initnode("decln");
		addnode($$, $1);
		addnode($$, $2);		
	}	
	;

declaration_specifiers
	: storage_class_specifier
	{
		$$ = initnode("declnSpec");
		addnode($$, $1);		
	}
	| storage_class_specifier declaration_specifiers
	| type_specifier
	{
		$$ = initnode("declnSpec");
		addnode($$, $1);
	}
	| type_specifier declaration_specifiers
	| type_qualifier
	{
		$$ = initnode("declnSpec");
		addnode($$, $1);		
	}	
	| type_qualifier declaration_specifiers
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;

init_declarator
	: declarator
	| declarator '=' initializer
	;

storage_class_specifier
	: TYPEDEF
	| EXTERN
	| STATIC
	| AUTO
	| REGISTER
	;

type_specifier
	: VOID{$$ = initstr("void");}	
	| CHAR{$$ = initstr("char");}	
	| SHORT
	| INT{$$ = initstr("int");}	
	| LONG
	| FLOAT
	| DOUBLE
	| SIGNED
	| UNSIGNED
	| struct_or_union_specifier
	| enum_specifier
	| TYPE_NAME
	;

struct_or_union_specifier
	: struct_or_union IDENTIFIER '{' struct_declaration_list '}'
	| struct_or_union '{' struct_declaration_list '}'
	| struct_or_union IDENTIFIER
	;

struct_or_union
	: STRUCT
	| UNION
	;

struct_declaration_list
	: struct_declaration
	| struct_declaration_list struct_declaration
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';'
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list
	| type_specifier
	| type_qualifier specifier_qualifier_list
	| type_qualifier
	;

struct_declarator_list
	: struct_declarator
	| struct_declarator_list ',' struct_declarator
	;

struct_declarator
	: declarator
	| ':' constant_expression
	| declarator ':' constant_expression
	;

enum_specifier
	: ENUM '{' enumerator_list '}'
	| ENUM IDENTIFIER '{' enumerator_list '}'
	| ENUM IDENTIFIER
	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator
	;

enumerator
	: IDENTIFIER
	| IDENTIFIER '=' constant_expression
	;

type_qualifier
	: CONST
	| VOLATILE
	;

declarator
	: pointer direct_declarator
	| direct_declarator
	{
		$$ = $1;
	}
	;

direct_declarator
	: IDENTIFIER
	{
		$$ = initnode("direDeclr");
	  addnode($$, $1);
	}
	| '(' declarator ')'
	| direct_declarator '[' constant_expression ']'
	| direct_declarator '[' ']'
	| direct_declarator '(' parameter_type_list ')'
	{
		$$ = $1;
		addnode($$, $3);
	}
	| direct_declarator '(' identifier_list ')'
	| direct_declarator '(' ')'
	;

pointer
	: '*'
	| '*' type_qualifier_list
	| '*' pointer
	| '*' type_qualifier_list pointer
	;

type_qualifier_list
	: type_qualifier
	| type_qualifier_list type_qualifier
	;

parameter_type_list
	: parameter_list
	{
		$$ = $1;		
	}
	| parameter_list ',' ELLIPSIS
	;

parameter_list
	: parameter_declaration
	{
		$$ = initnode("params");
		addnode($$, $1);
	}	
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	{
		$$ = initnode("paramDecln");
		addnode($$, $1);
	}
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;

type_name
	: specifier_qualifier_list
	| specifier_qualifier_list abstract_declarator
	;

abstract_declarator
	: pointer
	| direct_abstract_declarator
	| pointer direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' constant_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' constant_expression ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
	;

initializer
	: assignment_expression
	| '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	;

initializer_list
	: initializer
	| initializer_list ',' initializer
	;

//http://www.parsifalsoft.com/ifelse.html
statement
  : open_statement
	| closed_statement
	;

open_statement
	: IF '(' expression ')' statement
  | IF '(' expression ')' closed_statement ELSE open_statement
	| loop_header open_statement
	;

closed_statement
  : simple_statement
  | IF '(' expression ')' closed_statement ELSE closed_statement
  | loop_header closed_statement
	;


simple_statement
  : compound_statement
	| expression_statement
	| jump_statement
	| DO statement WHILE '(' expression ')' ';'	
	;

//loop_statement = loop_header + statement
loop_header
  : labeled_header
  | iteration_header
	| selection_header
	;

labeled_header
	: IDENTIFIER ':' 
	| CASE constant_expression ':'
	| DEFAULT ':' 
	;

iteration_header
	: WHILE '(' expression ')' 
	| FOR '(' expression_statement expression_statement ')' 
	| FOR '(' expression_statement expression_statement expression ')' 
	;

selection_header
	: SWITCH '(' expression ')'
	;

compound_statement
: '{' '}'
{
	$$ = initnode("comp");
}
	| '{' statement_list '}'
	| '{' declaration_list '}'
	| '{' declaration_list statement_list '}'
	;

declaration_list
	: declaration
	| declaration_list declaration
	;

statement_list
	: statement
	| statement_list statement
	;

expression_statement
	: ';'
	| expression ';'
	;

jump_statement
	: GOTO IDENTIFIER ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	;

start_unit
	: translation_unit
	{
		*ret = $$;		
	}
	;

translation_unit
	: external_declaration
	{
		$$ = initnode("trans");
		addnode($$, $1);
	}
	| translation_unit external_declaration
	{
		$$ = $1;
		addnode($$, $2);		
	}
	;

external_declaration:
function_definition
{
	$$ = $1;
	addint($$, row-funcrow);
	funcrow = 0;
}
| declaration
{
	$$ = $1;
}
;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	{
		$$ = initnode("func");
	}
	| declaration_specifiers declarator compound_statement
	{
		$$ = initnode("func");
		addnode($$, $1);	
		addnode($$, $2);
		addnode($$, $3);
	}
	| declarator declaration_list compound_statement
	| declarator compound_statement
	;

%%
void main()
{
	Ast *ast;
  if(yyparse(&ast)){
		fprintf(stderr, "error!\n");
	}
	printpretty(ast, 1);
}	

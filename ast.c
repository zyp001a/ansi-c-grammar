#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
/*
 generate ast 
 ["main",
   ["func", ""]
 ]
*/
Ast* initnode(char *str)
{
	Ast* p = (Ast*)malloc(sizeof(Ast));
	memset (p, 0, sizeof(Ast));
	p->str = str;
	p->type = TNODE;
	return p;
}
Ast* initstr(char *str)
{
	Ast* p = (Ast*)malloc(sizeof(Ast));
	memset (p, 0, sizeof(Ast));
	p->str = str;
	p->len = strlen(str);//store strlen, so that strdup is not need in lex
	p->type = TSTR;
	return p;
}
Ast* initint(int i)
{
	Ast* p = (Ast*)malloc(sizeof(Ast));
	memset (p, 0, sizeof(Ast));
	p->len = i;
	p->type = TINT;	
	return p;
}
void print(Ast *ast)
{
	int i;
	if(ast->type == TNODE){//is ast []
		putchar('[');				
  	printf("\"%s\"", ast->str);
		for(i=0; i<ast->len; i++){
			putchar(',');
			print(ast->arr[i]);
		}
		putchar(']');
	}else if(ast->type == TSTR){//is str
		putchar('"');
  	fprintf(stdout, "%.*s", ast->len, ast->str);
		putchar('"');
	}else{
  	printf("%d", ast->len);				
	}
}
char* inds = "                                          ";
void printpretty(Ast *ast, int ind)
{
	int i;
	if(ast->type == TNODE){//is ast []
		putchar('[');
		if(ast->len > 0){
			printf("\n%.*s", ind, inds);
		}
  	printf("\"%s\"", ast->str);
		for(i=0; i<ast->len; i++){
			putchar(',');
			printf("\n%.*s", ind, inds);						
			printpretty(ast->arr[i], ind+1);
		}
		if(ast->len > 0){
			printf("\n%.*s", ind-1, inds);
		}
		putchar(']');
	}else if(ast->type == TSTR){//is str
		putchar('"');
  	fprintf(stdout, "%.*s", ast->len, ast->str);
		putchar('"');
	}else{
  	printf("%d", ast->len);				
	}
}
void addnode(Ast *ast, Ast *subast)
{
	if(ast->len == 0){
		ast->arr = (Ast**)malloc(sizeof(Ast*));
	}else{
		ast->arr = realloc(ast->arr, (ast->len+1)*sizeof(Ast*));		
	}
	ast->arr[ast->len] = subast;
	ast->len ++;
} 
void addstr(Ast *ast, char* str)
{
	Ast *a = initstr(str);
	addnode(ast, a);
}
void addint(Ast *ast, int i)
{
	Ast *a = initint(i);
	addnode(ast, a);
}


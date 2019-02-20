lex lex.l
yacc -d yacc.y
gcc lex.yy.c y.tab.c -o parser

LEX=lex
YACC=bison
CFLAGS=-Wall -g
CC=gcc

all:parse

parse:grammar.c scanner.c type.c hash.c expression.c statement.c
	$(CC) $(CFLAGS) -o $@ $^

grammar.c:grammar.y
	$(YACC) -t -d -o $@ --defines=grammar.tab.h $^

%.c:%.l
	$(LEX) -o $@ $^

clean:
	rm -f grammar.c scanner.c *~

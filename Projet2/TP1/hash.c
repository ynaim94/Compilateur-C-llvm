#include <stdio.h>
#include <string.h>
#define SIZE 1013 

typedef struct {
  char *name;
  int type;
  char *code;
  char *var;
} symbol_t;

symbol_t EMPTY={"",0,"",""}; // un symbole vide
symbol_t hachtab[SIZE];

int hachage(char *s) {
  unsigned int hash = 0; 
  while (*s!='\0') hash = hash*31 + *s++;
  return hash%SIZE;
}
symbol_t findtab(char *s) {
  if (strcmp(hachtab[hachage(s)].name,s)) return hachtab[hachage(s)];
  return EMPTY;
}
void addtab(char *s,int type) {
  symbol_t *h=&hachtab[hachage(s)];
  h->name=s; h->type=type; h->code=NULL; h->var=NULL;
}
void init() {
  int i;
  for (i=0; i<SIZE; i++) hachtab[i]=EMPTY;
}

#define _GNU_SOURCE         /* See feature_test_macros(7) */

#include <stdio.h>
#include <string.h>
#include "hash.h"
#include "expression.h"





#define SIZE 1013 




symbol_t EMPTY={"",0,NULL,NULL}; // un symbole vide
symbol_t hachtab[SIZE];


int hachage(key_t k) {
  unsigned int hash = 0; 
  while (*(k.name)!='\0') hash = hash*31 + *(k.name++);
  while (*(k.function)!='\0') hash = hash*31 + *(k.function++);
  hash = hash*31 + k.level;
  return hash%SIZE;
}

symbol_t findtab(key_t k){
  if (!(strcmp(hachtab[hachage(k)].name,k.name)))
    return hachtab[hachage(k)];
  return EMPTY;
}

int intab(char *name){
  int l = level;
  while (l != 0){
    key_t k= {name,last_function,l}; 
    if (!(strcmp(hachtab[hachage(k)].name,k.name))){
      return l;
    }
    l--;
  }
  printf("Error: the variable %s does not exit in function %s, bloc %d.\n",name,last_function,level);
  return 0;
}

void addtab(key_t k, struct Type *type) {
  symbol_t *h=&hachtab[hachage(k)];
  h->name=k.name; h->type=type; h->code=NULL; h->var=new_var(); h->level = k.level;
  asprintf (&h->last_function, "%s", k.function);
}

void init() {
  int i;
  for (i=0; i<SIZE; i++) hachtab[i]=EMPTY;
}

void printtab(){
  int i;
  for (i=0; i<SIZE; i++)
    if ((strcmp(hachtab[i].name,"")))
      printf("%s:%d |",hachtab[i].name, hachtab[i].type->type);
  printf("\n");
}

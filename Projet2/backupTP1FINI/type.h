#ifndef TYPE_H
#define TYPE_H

int nb_parameter;
struct Type last_type;
int level;
char* last_function;
int niv; //debugg

enum EnumType{
  FUNCTION,INTEGER,DOUBLE,VOIDD
};


struct Function;
 

/* Elle permet de mettre la variable dans la même zone mémoire, 
 * qu'elle soit int, double ou string.
 */

/*union Value{
  int i;
  double d;
  struct Function f;
  };*/


/*Pour mettre la valeur de la variable et son type
 */

struct Type{
  enum EnumType type;
  struct Function* f;
};


/*Structure contenant les données d'une fonction
 */

struct Function{
  struct Type return_type; // Contient le type de retour
  int nbParam;              // Nombre de parametre
  struct Type **param_type; // Tableau des types des arguments
};


struct Type* create_symbol_function(const struct Type , struct Type**);
struct Type* create_symbol(const struct Type );
struct Type** param_append(struct Type**,  struct Type *);


#endif //TYPE_H

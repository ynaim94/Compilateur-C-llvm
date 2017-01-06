#ifndef __EXPRESSION_SYMBOLS_H_
#define __EXPRESSION_SYMBOLS_H_

enum simple_type
{
    ENTIER = 0,
    FLOTTANT = 1,
};

union value
{
    int n;
    float f;
};

struct expression_symbol 
{
    enum simple_type t;
    union value v;
};

struct expression_symbol* create_expression_symbol_int(int n); 
struct expression_symbol* create_expression_symbol_float(float f); 

#endif // __EXPRESSION_SYMBOLS_H_

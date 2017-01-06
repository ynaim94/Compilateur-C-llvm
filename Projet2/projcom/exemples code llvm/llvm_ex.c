#include <stdio.h>

void pile()
{
  int a, b, c;
  a = 5; b = 6;
  c = a + b;
}

/*
define void @f()
label 0:
 %a=alloca i32
 %b=alloca i32
 %c=alloca i32
 %x0=add i32 0,5
 store i32 %x0, i32* %a
 %x1=add i32 0,5
 store i32 %x1, i32* %b
 %x2=load i32, i32%* %a
 %x3=load i32, i32%* %b
 %x4=add i32 %x2,%x3
 store i32 %x4, i32* %c

clang -s -emit-llvm file.c -0 file.ll
 */

int ifthenelse(int x)
{
  int ret;
  ret = 0;
  if (x > 0) {
    ret  = 1;
  } else {
    ret = 2;
  }

  return ret;
}

/*
  define i32 @ifthenelse (i32 %x)
label 0:
%x.addr=alloca i32
store i32 %x, i32* %x.addr
%ret = alloca i32
%x0=add i32 0, 0
store i32 %x0, i32* %ret
%x1 =load i32 %x.addr
%x2=icmp sgt i32 %x1, %x0
br i1 %x2, label %label1, label %label2
label1:
 store i32 1, i32* %ret
 br label %label
label2:
 store i32 2,i32* %ret
 br label %label3
label3:
 %x3=load i32, i32* ret
 ret i32 %x3
*/

int loop(int x)
{
  int sum;
  int i;

  sum = 0;
  for (i=0; i<x; i++)
    sum += 1;

  return sum;
}

void add_int_double()
{
  int a;
  double b;
  double c;
  a = 1;
  b = 2.0;
  c = a + b;
}

void add_double_int()
{
  double a;
  int b;
  int c;
  a = 1.0;
  b = 3;
  c = a + b;
}

int main()
{
  int n;
  pile();
  n = ifthenelse(42);
  printf("%d\n", n);
  n = loop(10);
  printf("%d\n", n);
  return 0;
}

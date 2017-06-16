

double square(double x) {
  double a,b;
  //  a=b;

    a/b;
  a+b;
  a-b;
  a=b;
 
  square(a);
  (a = b);
  { int y;
    y-b;
    y = x;
  }
  return x*x;
}


int add(int x,int y) {
  x*square(1);
  x%y;
  x+y;
  if ( x == 0)
    {}
  add(x,y);
  return x+y;
}



int main() {
  int i,x;
  {
    int i;
    i++;
  }
  for (i=0; i<1000; i++) {
    x = add(i,x);
    x= square(x);
  }
  do x+1;  while ((i<0) || (x << 1) ||(x >> 1) ) ;
  return x;
}
  

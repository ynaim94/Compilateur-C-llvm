
int square(double x) {
  double a,b;
  square(a);
  (a = b);
  { int y;
    y = x;
    a;
  }
  return x*x;
}


int add(int x,int y) {
  x*square(x,y,x);
  add(x,y);
  return x+y;
}



int main() {
  double i,x;
  {
    int i;
    i++;
  }
  //for (i=0; i<1000; i++) x = add(i,x);
  do x+1;  while (i<0) ;
  return x;
}

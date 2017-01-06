
int square(double x) {
  double a,b;
  return x*x;
}
int add(int x,int y) {
  return x+y;
}
int main() {
  double i,x;
  {
    int i;
    double i;
  }
  for (i=0; i<1000; i++) x = add(i,x);
  do x+1;  while (i<0) ;
  return x;
}

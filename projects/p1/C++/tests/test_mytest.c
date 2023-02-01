#include <stdio.h>
#include <math.h>

int compare(float a, float b, float epsilon) {
  return fabs(a - b) < epsilon;
}


float mytest(); // this comes form your code generator


float mytest_tester()
{
  // C implementation of your test case
  return 0;
}

int main()
{
  float ret = mytest();
  float sol = mytest_tester();
  if ( !compare(ret,sol,0.0001) ) {
    printf("test_mytest should be %f, but got %f.\n",sol,ret);
    return 1;
  }
    
  return 0;
}

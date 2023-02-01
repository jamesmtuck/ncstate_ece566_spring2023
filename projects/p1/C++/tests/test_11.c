#include <stdio.h>

int compare(float a, float b, float epsilon) {
  return (a - b) < epsilon;
}

float test_11(float a, float b, float c, float d);

float test_11_tester(float a, float b, float c, float d)

{
  float det = a * d - b * c;
  float _a = d / det;
  float _b = -b / det;
  float _c = -c / det;
  float _d = a / det;

  float __a = a*_a + b*_c;
  float __b = a*_b + b*_d;
  float __c = c*_a + d*_c;
  float __d = c*_b + d*_d;
  
  float sum = __a + __b + __c + __d;
  return sum;
}

int main()
{

  for(int i=0; i<100; i++)
    {
      float ret = test_11(i,i+1,i+2,i+3);
      float sol = test_11_tester(i,i+1, i+2,i+3);
      if ( !compare(ret,sol,0.0001) ) {
	printf("test_11 at %d should be %f, but got %f.\n",i,sol,ret);
	return 1;
      }
    }
    
  return 0;
}

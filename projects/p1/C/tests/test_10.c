#include <stdio.h>
#include <math.h>

int compare(float a, float b, float epsilon) {
  return fabs(a - b) < epsilon;
}

float test_10(float a, float b, float c, float d, float e, float f,
	      float h, float i, float j);

float test_10_tester(float a, float b, float c, float d, float e, float f,
	      float h, float i, float j)

{
  return a*(e*j-f*i) - b*(d*j-f*h) + c*(d*i-e*h);
}

int main()
{

  for(int i=0; i<100; i++)
    {
      float ret = test_10(i,i+1,i+2,i+3,i+4,i+5,i+6,i+7,i+8);
      float sol = test_10_tester(i,i+1,i+2,i+3,i+4,i+5,i+6,i+7,i+8);
      if ( !compare(ret,sol,0.0001) ) {
	printf("test_10 at %d should be %f, but got %f.\n",i,sol,ret);
	return 1;
      }
    }
    
  return 0;
}



#include <stdio.h>

int compare(float a, float b, float epsilon) {
  return (a - b) < epsilon;
}

float test_15(float a, float b, float c, float d,
	     float e, float f, float g, float h);

float test_15_tester(float a, float b, float c, float d,
		    float e, float f, float g, float h)
{
  return 0.0;
}

int main()
{

  for(int i=0; i<100; i++)
    {
      float ret = test_15(i,i+2,i*2,i*3,i,i+1,0,1);
      float sol = test_15_tester(i,i+2,i*2,i*3,i,i+1,0,1);
      if ( !compare(ret,sol,0.0001) ) {
	printf("test_15(%d) should be %f, but got %f.\n",i,sol,ret);
	return 1;
      }
    }
    
  return 0;
}



#include <stdio.h>

int compare(float a, float b, float epsilon) {
  return (a - b) < epsilon;
}

float test_7(float a, float b, float c, float d);

float test_7_tester(float a, float b, float c, float d)
{
  return d;
}

int main()
{

  for(int i=0; i<100; i++)
    {
      float ret = test_7(i,i+2,i*2,i*3);
      float sol = test_7_tester(i,i+2,i*2,i*3);
      if ( !compare(ret,sol,0.0001) ) {
	printf("test_7(%d) should be %f, but got %f.\n",i,sol,ret);
	return 1;
      }

    }
    
  return 0;
}


